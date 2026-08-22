//
//  RaceSession.swift
//  HYFIT
//

import Foundation
import Observation

enum RacePhase: Equatable, Sendable {
    case idle
    case ready
    case active
    case completed
}

@Observable
@MainActor
final class RaceSession {
    let definition: RaceDefinition
    let setup: RaceSetupConfiguration

    private(set) var phase: RacePhase = .idle
    private(set) var currentStationIndex: Int = 0
    private(set) var raceStartDate: Date?
    private(set) var stationStartDate: Date?
    private(set) var raceEndDate: Date?
    private(set) var completedStations: [CompletedStationRecord] = []
    private(set) var displayNow: Date = Date()

    /// Injected tracker — swap for GPS implementation later.
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
        self.phase = .ready
    }

    // MARK: - Derived state

    var currentStation: RaceStation? {
        definition.station(at: currentStationIndex)
    }

    var nextStation: RaceStation? {
        definition.station(at: currentStationIndex + 1)
    }

    var isOnFinalStation: Bool {
        currentStationIndex >= definition.stationCount - 1
    }

    var totalElapsed: TimeInterval {
        guard let raceStartDate else { return 0 }
        let end = raceEndDate ?? displayNow
        return end.timeIntervalSince(raceStartDate)
    }

    var stationElapsed: TimeInterval {
        guard phase == .active, let stationStartDate else { return 0 }
        return displayNow.timeIntervalSince(stationStartDate)
    }

    var performanceSummary: RacePerformanceSummary {
        let total = totalElapsed
        var running: TimeInterval = 0
        var stationWork: TimeInterval = 0
        var distanceMeters: Double = 0

        for record in completedStations {
            if record.station.movement.countsAsRunning {
                running += record.duration
            } else {
                stationWork += record.duration
            }
            if let meters = record.distanceCompletedMeters {
                distanceMeters += meters
            } else if let target = record.station.targetDistanceMeters {
                distanceMeters += target
            }
        }

        let transition = max(0, total - running - stationWork)
        return RacePerformanceSummary(
            totalTime: total,
            runningTime: running,
            stationTime: stationWork,
            transitionTime: transition,
            totalDistanceMeters: distanceMeters
        )
    }

    // MARK: - Lifecycle

    func startRace() {
        guard phase == .ready || phase == .idle else { return }
        let now = Date()
        raceStartDate = now
        stationStartDate = now
        raceEndDate = nil
        completedStations = []
        currentStationIndex = 0
        phase = .active
        displayNow = now
        beginCurrentStationTracking(at: now)
        startTicker()
    }

    func completeCurrentStation() {
        guard phase == .active, let station = currentStation, let stationStartDate else { return }
        let now = Date()
        displayNow = now

        if station.type == .distance {
            distanceTracker.markComplete()
        }

        let distanceMeters: Double?
        if station.type == .distance {
            let value = distanceTracker.currentDistance
            let unit = distanceTracker.unit
            distanceMeters = unit.meters(from: value)
        } else {
            distanceMeters = nil
        }

        let record = CompletedStationRecord(
            id: "\(station.id)-\(completedStations.count)",
            station: station,
            startedAt: stationStartDate,
            endedAt: now,
            distanceCompletedMeters: distanceMeters
        )
        completedStations.append(record)
        distanceTracker.stop()

        if isOnFinalStation {
            finishRace(at: now)
        } else {
            advanceToNextStation(at: now)
        }
    }

    func resetToIdle() {
        stopTicker()
        distanceTracker.stop()
        phase = .idle
        currentStationIndex = 0
        raceStartDate = nil
        stationStartDate = nil
        raceEndDate = nil
        completedStations = []
    }

    func prepareAgain() {
        stopTicker()
        distanceTracker.stop()
        phase = .ready
        currentStationIndex = 0
        raceStartDate = nil
        stationStartDate = nil
        raceEndDate = nil
        completedStations = []
    }

    // MARK: - Private

    private func advanceToNextStation(at now: Date) {
        currentStationIndex += 1
        stationStartDate = now
        beginCurrentStationTracking(at: now)
    }

    private func finishRace(at now: Date) {
        raceEndDate = now
        phase = .completed
        stopTicker()
    }

    private func beginCurrentStationTracking(at now: Date) {
        guard let station = currentStation else { return }
        guard station.type == .distance,
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
                if self.phase == .active, self.currentStation?.type == .distance {
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
