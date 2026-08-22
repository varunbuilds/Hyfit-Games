//
//  MaleDoublesRaceDefinition.swift
//  HYFIT
//

import Foundation

/// Placeholder Male Doubles race sequence.
/// Replace or extend stations here — UI reads from this definition only.
enum MaleDoublesRaceDefinition {
    static let race = RaceDefinition(
        id: "male-doubles-v1",
        name: "HYFIT Male Doubles",
        category: .maleDoubles,
        stations: [
            .distance(
                id: "md-1-run",
                number: 1,
                name: "200M RUN",
                movement: .run,
                distance: 200,
                unit: .meters,
                shortDescription: "Run 200 meters",
                instructions: [
                    "Run the marked 200 meter course.",
                    "Stay on the course path.",
                    "Finish at the station start line."
                ]
            ),
            .repetitions(
                id: "md-2-stepups",
                number: 2,
                name: "DUMBBELL STEP-UPS",
                movement: .stepUp,
                reps: 30,
                equipment: "Dumbbells",
                load: 10,
                loadUnit: .kilograms,
                loadNote: "EACH HAND",
                boxHeight: "16\"",
                shortDescription: "30 reps • 10kg each hand • 16\" box",
                instructions: [
                    "Step onto the box with one foot.",
                    "Stand fully upright.",
                    "Step back down.",
                    "Repeat alternating legs."
                ]
            ),
            .distance(
                id: "md-3-run",
                number: 3,
                name: "200M RUN",
                movement: .run,
                distance: 200,
                unit: .meters,
                shortDescription: "Run 200 meters",
                instructions: [
                    "Run the marked 200 meter course.",
                    "Finish at the next station."
                ]
            ),
            .distance(
                id: "md-4-bear-crawl",
                number: 4,
                name: "BEAR CRAWL",
                movement: .crawl,
                distance: 20,
                unit: .meters,
                shortDescription: "Crawl 20 meters",
                instructions: [
                    "Start in a bear-crawl position.",
                    "Keep hips low and move forward under control.",
                    "Cover the full 20 meter distance."
                ]
            ),
            .distance(
                id: "md-5-farmers",
                number: 5,
                name: "FARMER CARRY",
                movement: .carry,
                distance: 40,
                unit: .meters,
                equipment: "Kettlebells",
                load: 24,
                loadUnit: .kilograms,
                loadNote: "EACH HAND",
                shortDescription: "Carry 40 meters • 24kg each hand",
                instructions: [
                    "Pick up a kettlebell in each hand (24 kg).",
                    "Walk the marked 40 meter course.",
                    "Set the bells down only after finishing."
                ]
            ),
            .distance(
                id: "md-6-run",
                number: 6,
                name: "200M RUN",
                movement: .run,
                distance: 200,
                unit: .meters,
                shortDescription: "Run 200 meters to the finish",
                instructions: [
                    "Final run to the finish line.",
                    "Sprint the last stretch if you can."
                ]
            )
        ]
    )
}

enum RaceCatalog {
    static func definition(for category: RaceCategory) -> RaceDefinition {
        switch category {
        case .maleDoubles:
            MaleDoublesRaceDefinition.race
        }
    }
}
