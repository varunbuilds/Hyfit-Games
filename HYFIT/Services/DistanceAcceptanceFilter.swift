//
//  DistanceAcceptanceFilter.swift
//  HYFIT
//
//  Pure acceptance rules for GPS deltas. Tunable constants live here.
//

import CoreLocation
import Foundation

enum MovementSignal: Equatable, Sendable {
    case stationary
    case moving
    case unknown
}

enum DistanceAcceptanceDecision: Equatable, Sendable {
    /// Count this delta toward race distance and advance the anchor.
    case accept(deltaMeters: Double)
    /// Do not count; move the anchor to the new fix (stationary / sub-threshold / spike).
    case reanchor
    /// Do not count and do not move the anchor (unusable fix).
    case ignore
    /// First / warmup fix — establish or reinforce anchor without distance.
    case warmupAnchor
}

/// Software filter that decides whether a GPS step is real athlete movement.
struct DistanceAcceptanceFilter: Sendable {
    // MARK: - Tunable constants

    /// Reject fixes worse than this horizontal accuracy (meters).
    static let maxHorizontalAccuracyMeters: CLLocationAccuracy = 45

    /// Reject fixes older than this relative to "now".
    static let maxLocationAgeSeconds: TimeInterval = 5

    /// Fixed floor for accepted displacement (meters).
    static let fixedMinimumDisplacementMeters: Double = 4

    /// Minimum step also scales with reported accuracy: `k * horizontalAccuracy`.
    static let accuracyMinimumScale: Double = 0.6

    /// Upper athletic speed with margin (~10 m/s ≈ 36 km/h).
    static let maxPlausibleSpeedMetersPerSecond: Double = 10

    /// Consecutive usable fixes required before leaving WAITING (first is always warmup).
    static let warmupFixCount: Int = 2

    /// User-acceleration magnitude (g) below which we treat the phone as still.
    static let lowAccelerationEnergyThreshold: Double = 0.035

    /// User-acceleration magnitude above which we treat the phone as moving even if activity is unknown.
    static let movingAccelerationEnergyThreshold: Double = 0.08

    func minimumDisplacementMeters(forAccuracy horizontalAccuracy: CLLocationAccuracy) -> Double {
        let accuracyComponent = max(0, horizontalAccuracy) * Self.accuracyMinimumScale
        return max(Self.fixedMinimumDisplacementMeters, accuracyComponent)
    }

    func isLocationHardUsable(_ location: CLLocation, now: Date = Date()) -> Bool {
        guard location.horizontalAccuracy >= 0 else { return false }
        guard location.horizontalAccuracy <= Self.maxHorizontalAccuracyMeters else { return false }
        let age = now.timeIntervalSince(location.timestamp)
        guard age >= 0, age <= Self.maxLocationAgeSeconds else { return false }
        return true
    }

    /// Combines activity + acceleration energy into a coarse movement signal.
    func movementSignal(
        activityStationary: Bool?,
        activityConfidenceIsLow: Bool,
        accelerationEnergy: Double?
    ) -> MovementSignal {
        let energy = accelerationEnergy ?? 0
        let energyLow = energy < Self.lowAccelerationEnergyThreshold
        let energyHigh = energy >= Self.movingAccelerationEnergyThreshold

        // Quiet phone → stationary even before activity arrives (table anti-drift).
        if energyLow, activityStationary != false {
            return .stationary
        }

        if activityStationary == true, !activityConfidenceIsLow {
            return .stationary
        }
        if activityStationary == true, energyLow {
            return .stationary
        }
        if energyHigh {
            return .moving
        }
        if activityStationary == false {
            return .moving
        }
        return .unknown
    }

    func evaluate(
        location: CLLocation,
        previous: CLLocation?,
        warmupFixesAccepted: Int,
        movement: MovementSignal,
        now: Date = Date()
    ) -> DistanceAcceptanceDecision {
        guard isLocationHardUsable(location, now: now) else {
            return .ignore
        }

        guard let previous else {
            return .warmupAnchor
        }

        if warmupFixesAccepted < Self.warmupFixCount {
            return .warmupAnchor
        }

        // Primary anti-drift: stationary phone must not path-integrate GPS wander.
        if movement == .stationary {
            return .reanchor
        }

        let delta = location.distance(from: previous)
        let dt = location.timestamp.timeIntervalSince(previous.timestamp)
        let minStep = minimumDisplacementMeters(forAccuracy: location.horizontalAccuracy)

        if dt > 0 {
            let speed = delta / dt
            if speed > Self.maxPlausibleSpeedMetersPerSecond {
                return .reanchor
            }
        } else if delta > Self.maxPlausibleSpeedMetersPerSecond * 0.5 {
            return .reanchor
        }

        if delta < minStep {
            // Tiny jitter: re-anchor so successive micro-steps cannot sum.
            return .reanchor
        }

        // Unknown movement (e.g. Bear Crawl): still accept if GPS step clears filters.
        return .accept(deltaMeters: delta)
    }
}
