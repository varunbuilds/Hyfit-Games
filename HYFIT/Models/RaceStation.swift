//
//  RaceStation.swift
//  HYFIT
//

import Foundation

struct RaceStation: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let stationNumber: Int
    let name: String
    let type: StationType
    let movement: StationMovement
    let shortDescription: String
    let instructions: [String]

    // Distance stations
    let distance: Double?
    let distanceUnit: DistanceUnit?

    // Repetition stations
    let reps: Int?
    let equipment: String?
    let load: Double?
    let loadUnit: LoadUnit?
    let loadNote: String?
    let boxHeight: String?

    var targetSummary: String {
        switch type {
        case .distance:
            guard let distance, let distanceUnit else { return shortDescription }
            let formatted = distance.truncatingRemainder(dividingBy: 1) == 0
                ? String(Int(distance))
                : String(format: "%.1f", distance)
            return "\(formatted) \(distanceUnit.shortLabel)"
        case .repetitions:
            if let reps {
                return "\(reps) REPS"
            }
            return shortDescription
        }
    }

    var targetDistanceMeters: Double? {
        guard let distance, let distanceUnit else { return nil }
        return distanceUnit.meters(from: distance)
    }
}

extension RaceStation {
    static func distance(
        id: String,
        number: Int,
        name: String,
        movement: StationMovement = .run,
        distance: Double,
        unit: DistanceUnit = .meters,
        equipment: String? = nil,
        load: Double? = nil,
        loadUnit: LoadUnit? = nil,
        loadNote: String? = nil,
        shortDescription: String,
        instructions: [String] = []
    ) -> RaceStation {
        RaceStation(
            id: id,
            stationNumber: number,
            name: name,
            type: .distance,
            movement: movement,
            shortDescription: shortDescription,
            instructions: instructions,
            distance: distance,
            distanceUnit: unit,
            reps: nil,
            equipment: equipment,
            load: load,
            loadUnit: loadUnit,
            loadNote: loadNote,
            boxHeight: nil
        )
    }

    static func repetitions(
        id: String,
        number: Int,
        name: String,
        movement: StationMovement = .other,
        reps: Int,
        equipment: String? = nil,
        load: Double? = nil,
        loadUnit: LoadUnit? = nil,
        loadNote: String? = nil,
        boxHeight: String? = nil,
        shortDescription: String,
        instructions: [String] = []
    ) -> RaceStation {
        RaceStation(
            id: id,
            stationNumber: number,
            name: name,
            type: .repetitions,
            movement: movement,
            shortDescription: shortDescription,
            instructions: instructions,
            distance: nil,
            distanceUnit: nil,
            reps: reps,
            equipment: equipment,
            load: load,
            loadUnit: loadUnit,
            loadNote: loadNote,
            boxHeight: boxHeight
        )
    }
}
