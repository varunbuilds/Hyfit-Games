//
//  DistanceTracking.swift
//  HYFIT
//

import Foundation

/// Abstraction for distance progress during a station.
/// Implementations: `SimulatedDistanceTracker` (default), `GPSDistanceTracker` (opt-in via factory).
protocol DistanceTracking: AnyObject {
    var currentDistance: Double { get }
    var targetDistance: Double { get }
    var unit: DistanceUnit { get }
    var isComplete: Bool { get }
    var progress: Double { get }

    func start(target: Double, unit: DistanceUnit)
    func tick(now: Date)
    func stop()
    func markComplete()
}

extension DistanceTracking {
    var progress: Double {
        guard targetDistance > 0 else { return 0 }
        return min(1, max(0, currentDistance / targetDistance))
    }

    var isComplete: Bool {
        currentDistance >= targetDistance && targetDistance > 0
    }
}

/// Local simulator that advances distance over time.
/// Replace with a GPS-backed tracker later — RaceSession only depends on DistanceTracking.
@MainActor
final class SimulatedDistanceTracker: DistanceTracking {
    private(set) var currentDistance: Double = 0
    private(set) var targetDistance: Double = 0
    private(set) var unit: DistanceUnit = .meters

    private var startedAt: Date?
    private var metersPerSecond: Double = 0
    private var isRunning = false
    private var forcedComplete = false

    /// Approximate pace so a 200m station fills in ~45–70s depending on distance.
    func start(target: Double, unit: DistanceUnit) {
        self.targetDistance = target
        self.unit = unit
        self.currentDistance = 0
        self.forcedComplete = false
        self.startedAt = Date()
        self.isRunning = true

        let meters = unit.meters(from: target)
        // Aim for roughly 3.5 m/s for runs, slower for crawls/carries via caller override if needed.
        self.metersPerSecond = max(0.8, meters / 55.0)
    }

    func configurePace(metersPerSecond: Double) {
        self.metersPerSecond = max(0.1, metersPerSecond)
    }

    func tick(now: Date) {
        guard isRunning, !forcedComplete, let startedAt else { return }
        let elapsed = now.timeIntervalSince(startedAt)
        let meters = min(unit.meters(from: targetDistance), elapsed * metersPerSecond)
        currentDistance = unit == .meters ? meters : meters / 1000.0
    }

    func stop() {
        isRunning = false
    }

    func markComplete() {
        forcedComplete = true
        currentDistance = targetDistance
        isRunning = false
    }
}
