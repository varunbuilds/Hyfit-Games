//
//  GPSDistanceTracker.swift
//  HYFIT
//
//  Core Location + Core Motion distance tracker.
//  Inject via DistanceTrackerFactory when DistanceTrackingMode.gps is selected.
//  Permissions are prepared BEFORE the active race — start() does not request them.
//

import CoreLocation
import CoreMotion
import Foundation
import os

/// Minimal GPS readiness signal for race UI. Independent of RaceSession progression.
enum GPSDistanceTrackerStatus: Equatable, Sendable {
    case idle
    case waitingForFix
    case tracking
    case stationary
    case poorAccuracy
    case permissionDenied
    case unavailable
}

/// Compact presentation model for distance screens (no Core Location types in views).
struct GPSDistanceUIState: Equatable, Sendable {
    let statusLabel: String
    /// True until warmup lock — do not present active 0 m tracking as live progress.
    let isWaitingForFix: Bool
    /// Permission denied / services off / unavailable — no fake distance.
    let isUnavailable: Bool
}

/// Accumulates outdoor traveled distance from successive CLLocation fixes,
/// gated by Core Motion so a stationary phone does not path-integrate GPS jitter.
/// Reaching `targetDistance` sets `isComplete` but does **not** advance the race.
@MainActor
final class GPSDistanceTracker: NSObject, DistanceTracking {
    // MARK: - DistanceTracking

    private(set) var currentDistance: Double = 0
    private(set) var targetDistance: Double = 0
    private(set) var unit: DistanceUnit = .meters

    private(set) var status: GPSDistanceTrackerStatus = .idle

    /// True after warmup lock (enough consistent usable fixes).
    private(set) var hasAcquiredFix: Bool = false

    /// Future hook: allow GPS-only filtering if Motion is unavailable mid-session.
    /// Prep currently requires Motion; leave this for a later degraded mode.
    var allowsDegradedGPSOnlyMode: Bool = false

    var uiState: GPSDistanceUIState {
        GPSDistanceUIState(
            statusLabel: statusLabel,
            isWaitingForFix: isWaitingForUsableFix,
            isUnavailable: isUnavailable
        )
    }

    // MARK: - Engines / filter

    private let locationManager = CLLocationManager()
    private let activityManager = CMMotionActivityManager()
    private let motionManager = CMMotionManager()
    private let filter = DistanceAcceptanceFilter()
    private let logger = Logger(subsystem: "com.varunrewadi.HYFIT", category: "GPSDistance")

    private var accumulatedMeters: Double = 0
    private var previousLocation: CLLocation?
    private var warmupFixesAccepted: Int = 0
    private var isRunning = false
    private var forcedComplete = false
    private var targetMeters: Double = 0

    private var latestActivityStationary: Bool?
    private var latestActivityConfidenceLow = true
    private var latestAccelerationEnergy: Double = 0

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.activityType = .fitness
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    // MARK: - DistanceTracking

    func start(target: Double, unit: DistanceUnit) {
        stopSensors()

        self.targetDistance = target
        self.unit = unit
        self.targetMeters = unit.meters(from: target)
        self.accumulatedMeters = 0
        self.currentDistance = 0
        self.previousLocation = nil
        self.warmupFixesAccepted = 0
        self.hasAcquiredFix = false
        self.forcedComplete = false
        self.isRunning = true
        self.status = .idle
        self.latestActivityStationary = nil
        self.latestActivityConfidenceLow = true
        self.latestAccelerationEnergy = 0

        // Prefer authorizationStatus + delegate — do not call locationServicesEnabled()
        // on the main thread (can cause UI unresponsiveness).
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            beginTrackingAfterAuthorization()
        case .notDetermined:
            status = .waitingForFix
            locationManager.requestWhenInUseAuthorization()
            // Motion prompt (if needed) is triggered when authorization succeeds.
        case .denied, .restricted:
            status = .permissionDenied
            debugLog("start blocked: location permission denied/restricted")
        @unknown default:
            status = .unavailable
        }
    }

    /// Continues start() once Location When In Use is authorized.
    private func beginTrackingAfterAuthorization() {
        guard isRunning, !forcedComplete else { return }

        if !motionAuthorizationAllowsTracking() && !allowsDegradedGPSOnlyMode {
            // Trigger Motion & Fitness prompt when still not determined.
            if CMMotionActivityManager.isActivityAvailable(),
               CMMotionActivityManager.authorizationStatus() == .notDetermined {
                status = .waitingForFix
                activityManager.startActivityUpdates(to: .main) { [weak self] activity in
                    Task { @MainActor in
                        self?.handleActivity(activity)
                        self?.continueAfterMotionAuthorizationChange()
                    }
                }
                return
            }
            status = .permissionDenied
            debugLog("start blocked: motion permission required")
            return
        }

        startMotionUpdates()
        startLocationUpdates()
        status = .waitingForFix
    }

    private func continueAfterMotionAuthorizationChange() {
        guard isRunning, !forcedComplete else { return }
        switch CMMotionActivityManager.authorizationStatus() {
        case .authorized:
            startMotionUpdates()
            startLocationUpdates()
            status = .waitingForFix
        case .denied, .restricted:
            if allowsDegradedGPSOnlyMode {
                startLocationUpdates()
                status = .waitingForFix
            } else {
                activityManager.stopActivityUpdates()
                status = .permissionDenied
            }
        case .notDetermined:
            break
        @unknown default:
            if allowsDegradedGPSOnlyMode {
                startLocationUpdates()
                status = .waitingForFix
            } else {
                status = .unavailable
            }
        }
    }

    func tick(now: Date) {}

    func stop() {
        isRunning = false
        stopSensors()
        if status == .tracking || status == .stationary || status == .poorAccuracy || status == .waitingForFix {
            status = .idle
        }
    }

    func markComplete() {
        forcedComplete = true
        isRunning = false
        accumulatedMeters = targetMeters
        publishCurrentDistance()
        stopSensors()
        if !isUnavailable {
            status = .idle
        }
    }

    // MARK: - UI helpers

    private var isUnavailable: Bool {
        switch status {
        case .permissionDenied, .unavailable:
            true
        default:
            false
        }
    }

    private var isWaitingForUsableFix: Bool {
        guard isRunning, !forcedComplete, !isUnavailable else { return false }
        return !hasAcquiredFix
    }

    private var statusLabel: String {
        switch status {
        case .idle:
            return isRunning ? "WAITING FOR GPS" : "GPS"
        case .waitingForFix:
            return "WAITING FOR GPS"
        case .tracking:
            return "GPS READY"
        case .stationary:
            return "GPS HOLD"
        case .poorAccuracy:
            return hasAcquiredFix ? "GPS ACCURACY LOW" : "WAITING FOR GPS"
        case .permissionDenied:
            return "GPS PERMISSION DENIED"
        case .unavailable:
            return "GPS UNAVAILABLE"
        }
    }

    // MARK: - Motion authorization (no mid-race prompt)

    private func motionAuthorizationAllowsTracking() -> Bool {
        guard CMMotionActivityManager.isActivityAvailable() else {
            return allowsDegradedGPSOnlyMode
        }
        switch CMMotionActivityManager.authorizationStatus() {
        case .authorized:
            return true
        case .notDetermined, .denied, .restricted:
            return allowsDegradedGPSOnlyMode
        @unknown default:
            return allowsDegradedGPSOnlyMode
        }
    }

    // MARK: - Sensor lifecycle

    private func startLocationUpdates() {
        guard isRunning, !forcedComplete else { return }
        locationManager.startUpdatingLocation()
    }

    private func startMotionUpdates() {
        if CMMotionActivityManager.isActivityAvailable(),
           CMMotionActivityManager.authorizationStatus() == .authorized {
            activityManager.startActivityUpdates(to: .main) { [weak self] activity in
                Task { @MainActor in
                    self?.handleActivity(activity)
                }
            }
        }

        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.1
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, _ in
                Task { @MainActor in
                    self?.handleDeviceMotion(motion)
                }
            }
        }
    }

    private func stopSensors() {
        locationManager.stopUpdatingLocation()
        activityManager.stopActivityUpdates()
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
    }

    private func handleActivity(_ activity: CMMotionActivity?) {
        guard let activity else { return }
        latestActivityStationary = activity.stationary
        latestActivityConfidenceLow = activity.confidence == .low
#if DEBUG
        let label: String
        if activity.stationary { label = "stationary" }
        else if activity.walking { label = "walking" }
        else if activity.running { label = "running" }
        else if activity.automotive { label = "automotive" }
        else if activity.cycling { label = "cycling" }
        else { label = "unknown" }
        logger.debug("motion activity=\(label, privacy: .public) confidence=\(String(describing: activity.confidence), privacy: .public)")
#endif
    }

    private func handleDeviceMotion(_ motion: CMDeviceMotion?) {
        guard let motion else { return }
        let a = motion.userAcceleration
        // Magnitude of user acceleration (gravity removed), in g.
        latestAccelerationEnergy = sqrt(a.x * a.x + a.y * a.y + a.z * a.z)
    }

    // MARK: - Location processing

    private func handleLocations(_ locations: [CLLocation]) {
        guard isRunning, !forcedComplete else { return }
        for location in locations {
            process(location)
        }
    }

    private func process(_ location: CLLocation) {
        let movement = filter.movementSignal(
            activityStationary: latestActivityStationary,
            activityConfidenceIsLow: latestActivityConfidenceLow,
            accelerationEnergy: latestAccelerationEnergy
        )

        if !filter.isLocationHardUsable(location) {
            if location.horizontalAccuracy >= 0,
               location.horizontalAccuracy > DistanceAcceptanceFilter.maxHorizontalAccuracyMeters {
                status = .poorAccuracy
            }
            debugLog(
                "reject ignore accuracy=\(location.horizontalAccuracy) age=\(Date().timeIntervalSince(location.timestamp)) energy=\(latestAccelerationEnergy)"
            )
            return
        }

        let decision = filter.evaluate(
            location: location,
            previous: previousLocation,
            warmupFixesAccepted: warmupFixesAccepted,
            movement: movement
        )

        switch decision {
        case .ignore:
            status = hasAcquiredFix ? .poorAccuracy : .waitingForFix
            debugLog("decision=ignore")

        case .warmupAnchor:
            previousLocation = location
            warmupFixesAccepted += 1
            if warmupFixesAccepted >= DistanceAcceptanceFilter.warmupFixCount {
                hasAcquiredFix = true
                status = movement == .stationary ? .stationary : .tracking
            } else {
                status = .waitingForFix
            }
            debugLog("decision=warmup warmupCount=\(warmupFixesAccepted) acc=\(location.horizontalAccuracy)")

        case .reanchor:
            let deltaBefore = previousLocation.map { location.distance(from: $0) } ?? 0
            previousLocation = location
            if movement == .stationary {
                status = .stationary
            } else if hasAcquiredFix {
                status = .tracking
            }
            debugLog(
                "decision=reanchor movement=\(String(describing: movement)) delta=\(deltaBefore) energy=\(latestAccelerationEnergy) acc=\(accumulatedMeters)"
            )

        case .accept(let deltaMeters):
            accumulatedMeters += deltaMeters
            previousLocation = location
            hasAcquiredFix = true
            status = .tracking
            publishCurrentDistance()
            debugLog(
                "decision=accept delta=\(deltaMeters) speedCheck ok energy=\(latestAccelerationEnergy) acc=\(accumulatedMeters)"
            )
        }
    }

    private func publishCurrentDistance() {
        let clampedMeters = min(accumulatedMeters, targetMeters)
        currentDistance = unit == .meters ? clampedMeters : clampedMeters / 1000.0
    }

    private func debugLog(_ message: String) {
#if DEBUG
        logger.debug("\(message, privacy: .public)")
#endif
    }
}

// MARK: - CLLocationManagerDelegate

extension GPSDistanceTracker: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            guard self.isRunning, !self.forcedComplete else { return }
            switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                self.beginTrackingAfterAuthorization()
            case .denied, .restricted:
                self.status = .permissionDenied
                self.stopSensors()
            case .notDetermined:
                break
            @unknown default:
                self.status = .unavailable
                self.stopSensors()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            self.handleLocations(locations)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            if (error as? CLError)?.code == .denied {
                self.status = .permissionDenied
                self.stopSensors()
                return
            }
            // Do not call locationServicesEnabled() on the main thread.
            self.status = self.hasAcquiredFix ? .poorAccuracy : .waitingForFix
        }
    }
}
