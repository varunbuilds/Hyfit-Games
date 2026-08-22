//
//  TimeFormatting.swift
//  HYFIT
//

import Foundation

enum TimeFormatting {
    /// Formats as M:SS.t or MM:SS.t (tenths of a second).
    static func raceClock(_ interval: TimeInterval) -> String {
        let clamped = max(0, interval)
        let totalTenths = Int((clamped * 10).rounded(.down))
        let tenths = totalTenths % 10
        let totalSeconds = totalTenths / 10
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d.%d", minutes, seconds, tenths)
    }

    /// Formats as MM:SS.t with zero-padded minutes.
    static func paddedRaceClock(_ interval: TimeInterval) -> String {
        let clamped = max(0, interval)
        let totalTenths = Int((clamped * 10).rounded(.down))
        let tenths = totalTenths % 10
        let totalSeconds = totalTenths / 10
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d.%d", minutes, seconds, tenths)
    }

    static func distanceLabel(value: Double, unit: DistanceUnit) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value)) \(unit.shortLabel)"
        }
        return String(format: "%.1f %@", value, unit.shortLabel)
    }

    static func kilometersLabel(_ meters: Double) -> String {
        String(format: "%.2f KM", meters / 1000.0)
    }
}
