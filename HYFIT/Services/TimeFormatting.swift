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

    /// Formats signed cognitive penalty: −00:30 / +00:30 / 00:00 / +01:00
    static func signedPenaltyClock(_ interval: TimeInterval) -> String {
        if interval == 0 { return "00:00" }
        let sign = interval < 0 ? "−" : "+"
        let totalSeconds = Int(abs(interval).rounded())
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%@%02d:%02d", sign, minutes, seconds)
    }

    /// History date: 25 AUG 2026
    static func historyDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date).uppercased()
    }
}
