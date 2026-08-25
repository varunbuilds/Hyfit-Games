//
//  RaceSession.swift
//  HYFIT
//

import Foundation
import Observation

/// Explicit race stages — prevents an accidental 7th run after Station 06.
enum RaceStage: Equatable, Sendable {
    case idle
    case ready
    case cognitivePreview
    /// Index into `definition.physicalSegments` (run/station pairs only).
    case physical(Int)
    case cognitiveRecall
    case completed
}

@Observable
@MainActor
final class RaceSession {
    let definition: RaceDefinition
    let setup: RaceSetupConfiguration

    private(set) var stage: RaceStage = .idle
    private(set) var raceStartDate: Date?
    private(set) var segmentStartDate: Date?
    private(set) var raceEndDate: Date?
    private(set) var completedStations: [CompletedStationRecord] = []
    private(set) var displayNow: Date = Date()

    /// Generated once at race start; never regenerated until a new session.
    private(set) var cognitiveSequence: [CognitiveColor] = []
    /// Retained after Submit for RaceResult snapshot (not used for live scoring re-runs).
    private(set) var submittedCognitiveSequence: [CognitiveColor] = []
    private(set) var recallAttemptFailed: Bool = false
    /// Persisted after first Submit — never recalculated on re-render.
    private(set) var cognitivePenaltyResult: CognitiveRecallPenaltyResult?
    private(set) var hasSubmittedCognitiveRecall: Bool = false
    /// Immutable completed-race snapshot — created once; never mutated.
    private(set) var raceResult: RaceResult?

    private(set) var distanceTracker: any DistanceTracking

    private var tickTask: Task<Void, Never>?

    init(
        definition: RaceDefinition,
        setup: RaceSetupConfiguration,
        distanceTracker: (any DistanceTracking)? = nil
    ) {
        self.definition = definition
        self.setup = setup
        self.distanceTracker = distanceTracker ?? SimulatedDistanceTracker()
        self.stage = .ready
    }

    // MARK: - Derived state

    var currentPhysicalSegment: RaceSegment? {
        guard case .physical(let index) = stage else { return nil }
        return definition.physicalSegment(at: index)
    }

    var currentStation: RaceStation? {
        currentPhysicalSegment?.station
    }

    var nextPhysicalSegment: RaceSegment? {
        guard case .physical(let index) = stage else {
            if stage == .cognitivePreview {
                return definition.physicalSegment(at: 0)
            }
            return nil
        }
        return definition.physicalSegment(at: index + 1)
    }

    var nextUpTitle: String? {
        switch stage {
        case .cognitivePreview:
            return definition.physicalSegment(at: 0)?.title
        case .physical(let index):
            let physical = definition.physicalSegments
            if index + 1 < physical.count {
                let next = physical[index + 1]
                if next.kind == .run {
                    return "200 m RUN"
                }
                return next.title
            }
            return "COGNITIVE FINISH"
        case .cognitiveRecall:
            return "FINISH LINE"
        default:
            return nil
        }
    }

    var nextUpSummary: String? {
        switch stage {
        case .cognitivePreview:
            return definition.physicalSegment(at: 0)?.shortDescription
        case .physical(let index):
            let physical = definition.physicalSegments
            if index + 1 < physical.count {
                let next = physical[index + 1]
                if next.kind == .run {
                    return "RUN"
                }
                return next.station?.targetSummary ?? next.shortDescription
            }
            return "Recall the sequence"
        case .cognitiveRecall:
            return "Race complete"
        default:
            return nil
        }
    }

    var totalElapsed: TimeInterval {
        guard let raceStartDate else { return 0 }
        let end = raceEndDate ?? displayNow
        return end.timeIntervalSince(raceStartDate)
    }

    var segmentElapsed: TimeInterval {
        switch stage {
        case .cognitivePreview, .physical, .cognitiveRecall:
            guard let segmentStartDate else { return 0 }
            return displayNow.timeIntervalSince(segmentStartDate)
        default:
            return 0
        }
    }

    /// Alias used by existing station/run views.
    var stationElapsed: TimeInterval { segmentElapsed }

    var performanceSummary: RacePerformanceSummary {
        let rawTotal = totalElapsed
        var running: TimeInterval = 0
        var stationWork: TimeInterval = 0
        var runningDistanceMeters: Double = 0

        for record in completedStations {
            if record.station.movement.countsAsRunning {
                running += record.duration
                if let meters = record.distanceCompletedMeters {
                    runningDistanceMeters += meters
                } else if let target = record.station.targetDistanceMeters {
                    runningDistanceMeters += target
                }
            } else {
                stationWork += record.duration
            }
        }

        let transition = max(0, rawTotal - running - stationWork)
        let penalty = cognitivePenaltyResult
        return RacePerformanceSummary(
            totalTime: rawTotal,
            runningTime: running,
            stationTime: stationWork,
            transitionTime: transition,
            totalDistanceMeters: runningDistanceMeters,
            rawFinishTime: penalty?.rawFinishTime ?? rawTotal,
            cognitivePenaltySeconds: penalty?.penaltySeconds ?? 0,
            cognitivePenaltyType: penalty?.penaltyType,
            adjustedFinishTime: penalty?.adjustedFinishTime ?? rawTotal,
            correctRecallPositions: penalty?.correctPositions
        )
    }

    // MARK: - Lifecycle

    func startRace() {
        guard stage == .ready || stage == .idle else { return }
        let now = Date()
        cognitiveSequence = CognitiveColor.randomSequence(count: 10)
        submittedCognitiveSequence = []
        recallAttemptFailed = false
        cognitivePenaltyResult = nil
        hasSubmittedCognitiveRecall = false
        raceResult = nil
        raceStartDate = now
        segmentStartDate = now
        raceEndDate = nil
        completedStations = []
        displayNow = now
        stage = .cognitivePreview
        distanceTracker.stop()
        startTicker()
    }

    func completeCognitivePreview() {
        guard stage == .cognitivePreview else { return }
        let now = Date()
        displayNow = now
        enterPhysicalSegment(index: 0, at: now)
    }

    func completeCurrentStation() {
        guard case .physical(let index) = stage,
              let segment = definition.physicalSegment(at: index),
              let station = segment.station,
              let segmentStartDate else { return }

        let now = Date()
        displayNow = now

        if station.type == .distance {
            distanceTracker.markComplete()
        }

        let distanceMeters: Double?
        if station.type == .distance {
            distanceMeters = distanceTracker.unit.meters(from: distanceTracker.currentDistance)
        } else {
            distanceMeters = nil
        }

        let record = CompletedStationRecord(
            id: "\(station.id)-\(completedStations.count)",
            station: station,
            startedAt: segmentStartDate,
            endedAt: now,
            distanceCompletedMeters: distanceMeters
        )
        completedStations.append(record)
        distanceTracker.stop()

        let physical = definition.physicalSegments
        let isLastPhysical = index >= physical.count - 1

        if isLastPhysical {
            // Station 06 → Cognitive Recall (never run 7)
            stage = .cognitiveRecall
            self.segmentStartDate = now
            recallAttemptFailed = false
        } else {
            enterPhysicalSegment(index: index + 1, at: now)
        }
    }

    /// Applies cognitive penalty once on Submit, then finishes the race and freezes RaceResult.
    /// Empty submission is treated as refusal (+60s). Partial non-empty is scored by position.
    @discardableResult
    func submitCognitiveRecall(input: String) -> Bool {
        guard stage == .cognitiveRecall else { return false }
        // Prevent duplicate penalty application and duplicate RaceResult.
        if hasSubmittedCognitiveRecall {
            return true
        }

        guard let submitted = CognitiveColor.parseSubmitted(input) else {
            recallAttemptFailed = true
            return false
        }

        let now = Date()
        displayNow = now
        let rawFinishTime = totalElapsed
        let refused = submitted.isEmpty

        let result = CognitiveRecallPenalty.calculate(
            original: cognitiveSequence,
            submitted: submitted,
            rawFinishTime: rawFinishTime,
            refused: refused
        )

        cognitivePenaltyResult = result
        submittedCognitiveSequence = submitted
        hasSubmittedCognitiveRecall = true
        recallAttemptFailed = false
        finishRace(at: now)

        // Snapshot once after finish timestamps are set; uses existing timing/penalty only.
        if raceResult == nil {
            raceResult = RaceResult.snapshot(
                from: self,
                submittedSequence: submitted,
                completedAt: now
            )
        }
        return true
    }

    func clearRecallFailure() {
        recallAttemptFailed = false
    }

    func resetToIdle() {
        stopTicker()
        distanceTracker.stop()
        stage = .idle
        raceStartDate = nil
        segmentStartDate = nil
        raceEndDate = nil
        completedStations = []
        cognitiveSequence = []
        submittedCognitiveSequence = []
        recallAttemptFailed = false
        cognitivePenaltyResult = nil
        hasSubmittedCognitiveRecall = false
        raceResult = nil
    }

    func prepareAgain() {
        stopTicker()
        distanceTracker.stop()
        stage = .ready
        raceStartDate = nil
        segmentStartDate = nil
        raceEndDate = nil
        completedStations = []
        cognitiveSequence = []
        submittedCognitiveSequence = []
        recallAttemptFailed = false
        cognitivePenaltyResult = nil
        hasSubmittedCognitiveRecall = false
        raceResult = nil
    }

    // MARK: - Private

    private func enterPhysicalSegment(index: Int, at now: Date) {
        stage = .physical(index)
        segmentStartDate = now
        beginDistanceTrackingIfNeeded(at: now)
    }

    private func finishRace(at now: Date) {
        displayNow = now
        raceEndDate = now
        stage = .completed
        stopTicker()
    }

    private func beginDistanceTrackingIfNeeded(at now: Date) {
        guard let station = currentStation,
              station.type == .distance,
              let distance = station.distance,
              let unit = station.distanceUnit else {
            distanceTracker.stop()
            return
        }

        distanceTracker.start(target: distance, unit: unit)
        if let simulated = distanceTracker as? SimulatedDistanceTracker {
            switch station.movement {
            case .run:
                simulated.configurePace(metersPerSecond: unit.meters(from: distance) / 48)
            case .crawl:
                simulated.configurePace(metersPerSecond: unit.meters(from: distance) / 35)
            case .carry, .sled:
                simulated.configurePace(metersPerSecond: unit.meters(from: distance) / 40)
            default:
                simulated.configurePace(metersPerSecond: unit.meters(from: distance) / 50)
            }
        }
        distanceTracker.tick(now: now)
    }

    private func startTicker() {
        stopTicker()
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                guard let self, !Task.isCancelled else { break }
                let now = Date()
                self.displayNow = now
                if case .physical = self.stage,
                   self.currentStation?.type == .distance {
                    self.distanceTracker.tick(now: now)
                }
            }
        }
    }

    private func stopTicker() {
        tickTask?.cancel()
        tickTask = nil
    }
}
