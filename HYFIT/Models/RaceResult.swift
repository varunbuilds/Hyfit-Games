//
//  RaceResult.swift
//  HYFIT
//

import Foundation

/// Immutable snapshot of a successfully completed race.
/// Built once at Cognitive Recall submit — not a live timing system.
struct RaceResult: Identifiable, Hashable, Sendable, Codable {
    let id: UUID
    let completedAt: Date

    // MARK: Metadata

    let definitionID: String
    let definitionName: String
    let category: RaceCategory
    let setup: RaceSetupConfiguration

    // MARK: Overall timing (from existing cognitivePenaltyResult)

    let rawFinishTime: TimeInterval
    let penaltySeconds: TimeInterval
    let adjustedFinishTime: TimeInterval

    // MARK: Physical segments (existing CompletedStationRecord — all 12)

    let completedStations: [CompletedStationRecord]

    // MARK: Cognitive Start / Recall

    let cognitiveStartDuration: TimeInterval
    let cognitiveRecallDuration: TimeInterval
    let originalSequence: [CognitiveColor]
    let submittedSequence: [CognitiveColor]
    let correctPositions: Int
    let penaltyType: CognitivePenaltyType

    // MARK: Aggregates (from existing performanceSummary)

    let runningTime: TimeInterval
    let stationTime: TimeInterval
    let transitionTime: TimeInterval
    let totalDistanceMeters: Double
}

extension RaceResult {
    /// Freezes the completed race from an existing RaceSession at finish.
    /// Uses existing timestamps and penalty result — does not re-time the race.
    @MainActor
    static func snapshot(
        from session: RaceSession,
        submittedSequence: [CognitiveColor],
        completedAt: Date
    ) -> RaceResult? {
        guard let penalty = session.cognitivePenaltyResult else { return nil }
        guard let raceStart = session.raceStartDate else { return nil }

        // Cognitive Start: raceStart → first physical segment start.
        let cognitiveStartDuration: TimeInterval
        if let firstPhysical = session.completedStations.first {
            cognitiveStartDuration = max(
                0,
                firstPhysical.startedAt.timeIntervalSince(raceStart)
            )
        } else {
            cognitiveStartDuration = 0
        }

        // Cognitive Recall: segmentStartDate set when entering recall → submit/completedAt.
        let cognitiveRecallDuration: TimeInterval
        if let recallStart = session.segmentStartDate {
            cognitiveRecallDuration = max(0, completedAt.timeIntervalSince(recallStart))
        } else {
            cognitiveRecallDuration = 0
        }

        let summary = session.performanceSummary

        return RaceResult(
            id: UUID(),
            completedAt: completedAt,
            definitionID: session.definition.id,
            definitionName: session.definition.name,
            category: session.definition.category,
            setup: session.setup,
            rawFinishTime: penalty.rawFinishTime,
            penaltySeconds: penalty.penaltySeconds,
            adjustedFinishTime: penalty.adjustedFinishTime,
            completedStations: session.completedStations,
            cognitiveStartDuration: cognitiveStartDuration,
            cognitiveRecallDuration: cognitiveRecallDuration,
            originalSequence: session.cognitiveSequence,
            submittedSequence: submittedSequence,
            correctPositions: penalty.correctPositions,
            penaltyType: penalty.penaltyType,
            runningTime: summary.runningTime,
            stationTime: summary.stationTime,
            transitionTime: summary.transitionTime,
            totalDistanceMeters: summary.totalDistanceMeters
        )
    }
}
