//
//  StatsCalculator.swift
//  HYFIT
//
//  Pure derivation: [RaceResult] → StatsSummary. Not persisted.
//

import Foundation

/// Point on the final-time progress trend (chronological).
nonisolated struct StatsProgressPoint: Identifiable, Hashable, Sendable {
    let id: UUID
    let completedAt: Date
    let adjustedFinishTime: TimeInterval
    let isNewest: Bool
}

nonisolated struct StatsRunRow: Identifiable, Hashable, Sendable {
    let id: Int
    let runNumber: Int
    let best: TimeInterval
    let average: TimeInterval
}

nonisolated struct StatsStationRow: Identifiable, Hashable, Sendable {
    let id: Int
    let stationNumber: Int
    let name: String
    let best: TimeInterval
    let average: TimeInterval
}

nonisolated struct StatsPersonalBests: Hashable, Sendable {
    let finalTime: TimeInterval
    let fastest200m: TimeInterval
    let fastestStationDuration: TimeInterval
    let fastestStationName: String
    let bestRecallCorrect: Int
    let recallSequenceLength: Int
}

nonisolated struct StatsCognitiveSummary: Hashable, Sendable {
    let averageRecall: Double
    let bestRecall: Int
    let averagePenaltySeconds: TimeInterval
    let perfectRecallCount: Int
    let recallSequenceLength: Int
}

/// Derived athlete dashboard metrics from completed `RaceResult` snapshots.
nonisolated struct StatsSummary: Hashable, Sendable {
    let raceCount: Int
    let bestAdjustedFinishTime: TimeInterval?
    let averageAdjustedFinishTime: TimeInterval?
    let totalDistanceMeters: Double
    let progressPoints: [StatsProgressPoint]
    let runRows: [StatsRunRow]
    let stationRows: [StatsStationRow]
    let cognitive: StatsCognitiveSummary?
    let personalBests: StatsPersonalBests?

    var isEmpty: Bool { raceCount == 0 }
}

enum StatsCalculator {
    /// Expected cognitive sequence length for Male Doubles (and current format).
    static let expectedRecallLength = 10

    /// Maximum races shown on the progress trend (oldest → newest among the newest N).
    static let progressWindow = 10

    static func summarize(
        _ results: [RaceResult],
        definition: RaceDefinition = MaleDoublesRaceDefinition.race
    ) -> StatsSummary {
        guard !results.isEmpty else {
            return StatsSummary(
                raceCount: 0,
                bestAdjustedFinishTime: nil,
                averageAdjustedFinishTime: nil,
                totalDistanceMeters: 0,
                progressPoints: [],
                runRows: [],
                stationRows: [],
                cognitive: nil,
                personalBests: nil
            )
        }

        let chronological = results.sorted { $0.completedAt < $1.completedAt }
        let finishTimes = chronological.map(\.adjustedFinishTime)
        let bestFinish = finishTimes.min()!
        let averageFinish = finishTimes.reduce(0, +) / Double(finishTimes.count)
        let totalDistance = chronological.reduce(0.0) { $0 + $1.totalDistanceMeters }

        return StatsSummary(
            raceCount: chronological.count,
            bestAdjustedFinishTime: bestFinish,
            averageAdjustedFinishTime: averageFinish,
            totalDistanceMeters: totalDistance,
            progressPoints: makeProgressPoints(chronological),
            runRows: makeRunRows(chronological),
            stationRows: makeStationRows(chronological, definition: definition),
            cognitive: makeCognitive(chronological),
            personalBests: makePersonalBests(chronological, definition: definition)
        )
    }

    // MARK: - Progress

    private static func makeProgressPoints(_ chronological: [RaceResult]) -> [StatsProgressPoint] {
        let window = Array(chronological.suffix(progressWindow))
        guard let newestID = window.last?.id else { return [] }
        return window.map { result in
            StatsProgressPoint(
                id: result.id,
                completedAt: result.completedAt,
                adjustedFinishTime: result.adjustedFinishTime,
                isNewest: result.id == newestID
            )
        }
    }

    // MARK: - Runs

    private static func makeRunRows(_ races: [RaceResult]) -> [StatsRunRow] {
        var durationsByRun: [Int: [TimeInterval]] = [:]
        for race in races {
            for record in race.completedStations where isRunSegment(record) {
                let number = record.station.stationNumber
                guard (1...6).contains(number) else { continue }
                durationsByRun[number, default: []].append(record.duration)
            }
        }

        return (1...6).compactMap { number in
            guard let values = durationsByRun[number], !values.isEmpty else { return nil }
            return StatsRunRow(
                id: number,
                runNumber: number,
                best: values.min()!,
                average: values.reduce(0, +) / Double(values.count)
            )
        }
    }

    // MARK: - Stations

    private static func makeStationRows(
        _ races: [RaceResult],
        definition: RaceDefinition
    ) -> [StatsStationRow] {
        let namesByNumber = workStationNames(from: definition)
        var durationsByStation: [Int: [TimeInterval]] = [:]
        var namesFromData: [Int: String] = [:]

        for race in races {
            for record in race.completedStations where isWorkStationSegment(record) {
                let number = record.station.stationNumber
                guard (1...6).contains(number) else { continue }
                durationsByStation[number, default: []].append(record.duration)
                namesFromData[number] = record.station.name
            }
        }

        return (1...6).compactMap { number in
            guard let values = durationsByStation[number], !values.isEmpty else { return nil }
            let name = namesByNumber[number] ?? namesFromData[number] ?? "STATION \(String(format: "%02d", number))"
            return StatsStationRow(
                id: number,
                stationNumber: number,
                name: name,
                best: values.min()!,
                average: values.reduce(0, +) / Double(values.count)
            )
        }
    }

    // MARK: - Cognitive

    private static func makeCognitive(_ races: [RaceResult]) -> StatsCognitiveSummary {
        let corrects = races.map(\.correctPositions)
        let penalties = races.map(\.penaltySeconds)
        let length = races.first.map { max($0.originalSequence.count, expectedRecallLength) } ?? expectedRecallLength
        let perfect = races.filter { $0.correctPositions == length }.count

        return StatsCognitiveSummary(
            averageRecall: Double(corrects.reduce(0, +)) / Double(corrects.count),
            bestRecall: corrects.max()!,
            averagePenaltySeconds: penalties.reduce(0, +) / Double(penalties.count),
            perfectRecallCount: perfect,
            recallSequenceLength: length
        )
    }

    // MARK: - Personal bests

    private static func makePersonalBests(
        _ races: [RaceResult],
        definition: RaceDefinition
    ) -> StatsPersonalBests? {
        let finalTime = races.map(\.adjustedFinishTime).min()!

        var fastestRun: TimeInterval?
        var fastestStation: TimeInterval?
        var fastestStationName: String?
        let namesByNumber = workStationNames(from: definition)

        for race in races {
            for record in race.completedStations {
                if isRunSegment(record) {
                    let d = record.duration
                    if fastestRun == nil || d < fastestRun! {
                        fastestRun = d
                    }
                } else if isWorkStationSegment(record) {
                    let d = record.duration
                    if fastestStation == nil || d < fastestStation! {
                        fastestStation = d
                        let number = record.station.stationNumber
                        fastestStationName = namesByNumber[number] ?? record.station.name
                    }
                }
            }
        }

        guard let fastestRun, let fastestStation, let fastestStationName else {
            // Incomplete station payload — still surface final + recall.
            let bestRecall = races.map(\.correctPositions).max()!
            let length = races.first.map { max($0.originalSequence.count, expectedRecallLength) } ?? expectedRecallLength
            return StatsPersonalBests(
                finalTime: finalTime,
                fastest200m: fastestRun ?? 0,
                fastestStationDuration: fastestStation ?? 0,
                fastestStationName: fastestStationName ?? "—",
                bestRecallCorrect: bestRecall,
                recallSequenceLength: length
            )
        }

        let bestRecall = races.map(\.correctPositions).max()!
        let length = races.first.map { max($0.originalSequence.count, expectedRecallLength) } ?? expectedRecallLength

        return StatsPersonalBests(
            finalTime: finalTime,
            fastest200m: fastestRun,
            fastestStationDuration: fastestStation,
            fastestStationName: fastestStationName,
            bestRecallCorrect: bestRecall,
            recallSequenceLength: length
        )
    }

    // MARK: - Segment classification

    /// 200 m runs: movement is `.run` (not Farmers Carry / Bear Crawl distance stations).
    private static func isRunSegment(_ record: CompletedStationRecord) -> Bool {
        record.station.movement.countsAsRunning
    }

    /// Work stations 01–06 (rep or distance stations that are not runs).
    private static func isWorkStationSegment(_ record: CompletedStationRecord) -> Bool {
        !record.station.movement.countsAsRunning
            && (1...6).contains(record.station.stationNumber)
    }

    private static func workStationNames(from definition: RaceDefinition) -> [Int: String] {
        var map: [Int: String] = [:]
        for segment in definition.physicalSegments {
            guard let station = segment.station,
                  !station.movement.countsAsRunning,
                  let number = segment.workStationNumber ?? Optional(station.stationNumber),
                  (1...6).contains(number) else { continue }
            map[number] = station.name
        }
        return map
    }
}
