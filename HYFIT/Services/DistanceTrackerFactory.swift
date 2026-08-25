//
//  DistanceTrackerFactory.swift
//  HYFIT
//

import Foundation

/// Development/testing choice for how distance segments are measured.
nonisolated enum DistanceTrackingMode: String, CaseIterable, Codable, Sendable, Hashable {
    case simulated
    case gps

    var displayName: String {
        switch self {
        case .simulated: "SIMULATOR"
        case .gps: "GPS"
        }
    }
}

/// Builds a `DistanceTracking` implementation. RaceSession stays mode-agnostic.
enum DistanceTrackerFactory {
    @MainActor
    static func make(_ mode: DistanceTrackingMode) -> any DistanceTracking {
        switch mode {
        case .simulated:
            SimulatedDistanceTracker()
        case .gps:
            GPSDistanceTracker()
        }
    }
}
