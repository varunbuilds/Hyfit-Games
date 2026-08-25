//
//  CompletedStationRecord.swift
//  HYFIT
//

import Foundation

nonisolated struct CompletedStationRecord: Identifiable, Hashable, Sendable, Codable {
    let id: String
    let station: RaceStation
    let startedAt: Date
    let endedAt: Date
    let distanceCompletedMeters: Double?

    var duration: TimeInterval {
        endedAt.timeIntervalSince(startedAt)
    }
}

struct RacePerformanceSummary: Hashable, Sendable {
    let totalTime: TimeInterval
    let runningTime: TimeInterval
    let stationTime: TimeInterval
    let transitionTime: TimeInterval
    let totalDistanceMeters: Double
    let rawFinishTime: TimeInterval
    let cognitivePenaltySeconds: TimeInterval
    let cognitivePenaltyType: CognitivePenaltyType?
    let adjustedFinishTime: TimeInterval
    let correctRecallPositions: Int?

    var totalDistanceKilometers: Double {
        totalDistanceMeters / 1000.0
    }
}
