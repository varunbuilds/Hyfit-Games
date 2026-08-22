//
//  RaceStation.swift
//  HYFIT
//

import Foundation

struct StationMetric: Hashable, Codable, Sendable {
    let value: String
    let label: String
}

struct RaceStation: Identifiable, Codable, Sendable, Hashable {
    let id: String
    /// Work station number 1...6, or run index for runs.
    let stationNumber: Int
    let name: String
    let type: StationType
    let movement: StationMovement
    let shortDescription: String
    let instructions: [String]

    let distance: Double?
    let distanceUnit: DistanceUnit?

    let reps: Int?
    /// Display caption for reps (REPS / SQUATS / FLIPS).
    let repsLabel: String?
    let equipment: String?
    let load: Double?
    let loadUnit: LoadUnit?
    let loadNote: String?
    let boxHeight: String?
    let boxLabel: String?

    /// Explicit format-card metrics. When empty, derived from fields.
    let metrics: [StationMetric]

    var formattedWorkStationNumber: String {
        String(format: "%02d", stationNumber)
    }

    var displayMetrics: [StationMetric] {
        if !metrics.isEmpty { return metrics }
        return derivedMetrics
    }

    var targetSummary: String {
        let parts = displayMetrics.map { "\($0.value) \($0.label)" }
        if !parts.isEmpty { return parts.joined(separator: " · ") }
        return shortDescription.isEmpty ? name : shortDescription
    }

    var targetDistanceMeters: Double? {
        guard let distance, let distanceUnit else { return nil }
        return distanceUnit.meters(from: distance)
    }

    private var derivedMetrics: [StationMetric] {
        var items: [StationMetric] = []
        if let load, let loadUnit {
            items.append(StationMetric(
                value: "\(Int(load)) \(loadUnit.shortLabel.lowercased() == "kg" ? "kg" : loadUnit.shortLabel)",
                label: loadNote ?? "LOAD"
            ))
        }
        if let reps {
            items.append(StationMetric(value: "\(reps)", label: repsLabel ?? "REPS"))
        }
        if let boxHeight {
            items.append(StationMetric(value: boxHeight, label: boxLabel ?? "BOX"))
        }
        if let distance, let distanceUnit {
            let formatted = distance.truncatingRemainder(dividingBy: 1) == 0
                ? "\(Int(distance)) \(distanceUnit == .meters ? "m" : distanceUnit.shortLabel)"
                : String(format: "%.0f %@", distance, distanceUnit == .meters ? "m" : distanceUnit.shortLabel)
            items.append(StationMetric(value: formatted, label: "DISTANCE"))
        }
        return items
    }
}

extension RaceStation {
    static func run(
        id: String,
        runNumber: Int
    ) -> RaceStation {
        RaceStation(
            id: id,
            stationNumber: runNumber,
            name: "200 m",
            type: .distance,
            movement: .run,
            shortDescription: "RUN",
            instructions: [
                "Run the marked 200 meter course.",
                "Stay on the course path."
            ],
            distance: 200,
            distanceUnit: .meters,
            reps: nil,
            repsLabel: nil,
            equipment: nil,
            load: nil,
            loadUnit: nil,
            loadNote: nil,
            boxHeight: nil,
            boxLabel: nil,
            metrics: []
        )
    }

    static func work(
        id: String,
        number: Int,
        name: String,
        type: StationType,
        movement: StationMovement,
        shortDescription: String,
        instructions: [String] = [],
        distance: Double? = nil,
        distanceUnit: DistanceUnit? = nil,
        reps: Int? = nil,
        repsLabel: String? = nil,
        equipment: String? = nil,
        load: Double? = nil,
        loadUnit: LoadUnit? = nil,
        loadNote: String? = nil,
        boxHeight: String? = nil,
        boxLabel: String? = nil,
        metrics: [StationMetric]
    ) -> RaceStation {
        RaceStation(
            id: id,
            stationNumber: number,
            name: name,
            type: type,
            movement: movement,
            shortDescription: shortDescription,
            instructions: instructions,
            distance: distance,
            distanceUnit: distanceUnit,
            reps: reps,
            repsLabel: repsLabel,
            equipment: equipment,
            load: load,
            loadUnit: loadUnit,
            loadNote: loadNote,
            boxHeight: boxHeight,
            boxLabel: boxLabel,
            metrics: metrics
        )
    }
}
