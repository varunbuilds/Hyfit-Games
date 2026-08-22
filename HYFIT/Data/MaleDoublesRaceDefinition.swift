//
//  MaleDoublesRaceDefinition.swift
//  HYFIT
//

import Foundation

/// Official Male Doubles race sequence — single source of truth.
enum MaleDoublesRaceDefinition {
    static let race: RaceDefinition = {
        // Six 200 m runs: before Station 01, then between each station pair. None after Station 06.
        let run1 = RaceStation.run(id: "md-run-1", runNumber: 1)
        let run2 = RaceStation.run(id: "md-run-2", runNumber: 2)
        let run3 = RaceStation.run(id: "md-run-3", runNumber: 3)
        let run4 = RaceStation.run(id: "md-run-4", runNumber: 4)
        let run5 = RaceStation.run(id: "md-run-5", runNumber: 5)
        let run6 = RaceStation.run(id: "md-run-6", runNumber: 6)

        let station01 = RaceStation.work(
            id: "md-station-01",
            number: 1,
            name: "DUMBBELL STEP-UPS",
            type: .repetitions,
            movement: .stepUp,
            shortDescription: "Lower-body strength and control. Step up, drive, come down clean.",
            instructions: [
                "Step onto the box with one foot.",
                "Stand fully upright.",
                "Step back down.",
                "Repeat alternating legs."
            ],
            reps: 30,
            repsLabel: "REPS",
            equipment: "Dumbbells",
            load: 10,
            loadUnit: .kilograms,
            loadNote: "EACH HAND",
            boxHeight: "16 in",
            boxLabel: "BOX",
            metrics: [
                StationMetric(value: "10 kg", label: "EACH HAND"),
                StationMetric(value: "30", label: "REPS"),
                StationMetric(value: "16 in", label: "BOX")
            ]
        )

        let station02 = RaceStation.work(
            id: "md-station-02",
            number: 2,
            name: "FARMERS CARRY",
            type: .distance,
            movement: .carry,
            shortDescription: "Grip, posture and composure under load, over distance.",
            instructions: [
                "Pick up a kettlebell in each hand.",
                "Walk the marked course under control.",
                "Set the bells down only after finishing."
            ],
            distance: 200,
            distanceUnit: .meters,
            load: 16,
            loadUnit: .kilograms,
            loadNote: "EACH HAND",
            metrics: [
                StationMetric(value: "16 kg", label: "EACH HAND"),
                StationMetric(value: "200 m", label: "DISTANCE")
            ]
        )

        let station03 = RaceStation.work(
            id: "md-station-03",
            number: 3,
            name: "BEAR CRAWL",
            type: .distance,
            movement: .crawl,
            shortDescription: "Low, tight and relentless. Move the whole body at once.",
            instructions: [
                "Start in a bear-crawl position.",
                "Keep hips low and move forward under control.",
                "Cover the full distance."
            ],
            distance: 20,
            distanceUnit: .meters,
            metrics: [
                StationMetric(value: "20 m", label: "DISTANCE")
            ]
        )

        let station04 = RaceStation.work(
            id: "md-station-04",
            number: 4,
            name: "BURPEES TO PLATE",
            type: .repetitions,
            movement: .other,
            shortDescription: "Speed and honesty. Up, down, up, under fatigue.",
            instructions: [
                "Drop into a burpee and chest to the floor.",
                "Explode up and jump both feet forward.",
                "Touch or jump onto the plate to complete each rep.",
                "Reset and repeat for all 30 reps."
            ],
            reps: 30,
            repsLabel: "REPS",
            metrics: [
                StationMetric(value: "30", label: "REPS")
            ]
        )

        let station05 = RaceStation.work(
            id: "md-station-05",
            number: 5,
            name: "FRONT CARRY + AIR SQUATS",
            type: .repetitions,
            movement: .carry,
            shortDescription: "Carry the load, then sink and drive. Strength meets fatigue.",
            instructions: [
                "Pick up the load and hold it in the front rack / front carry position.",
                "Carry for the marked 20 m distance.",
                "At the end of the carry, complete 30 air squats.",
                "Keep the chest up and drive through the heels on every squat."
            ],
            distance: 20,
            distanceUnit: .meters,
            reps: 30,
            repsLabel: "SQUATS",
            load: 30,
            loadUnit: .kilograms,
            loadNote: "LOAD",
            metrics: [
                StationMetric(value: "30 kg", label: "LOAD"),
                StationMetric(value: "30", label: "SQUATS"),
                StationMetric(value: "20 m", label: "DISTANCE")
            ]
        )

        let station06 = RaceStation.work(
            id: "md-station-06",
            number: 6,
            name: "TYRE FLIPS",
            type: .repetitions,
            movement: .other,
            shortDescription: "Hinge, lift, flip. Raw power to finish strong.",
            instructions: [
                "Hinge at the hips and grip under the tyre.",
                "Drive through the legs and lift the tyre upright.",
                "Push through to flip it fully over.",
                "Reset and repeat for all 30 flips."
            ],
            reps: 30,
            repsLabel: "FLIPS",
            load: 50,
            loadUnit: .kilograms,
            loadNote: "LOAD",
            metrics: [
                StationMetric(value: "50 kg", label: "LOAD"),
                StationMetric(value: "30", label: "FLIPS")
            ]
        )

        func runSegment(_ station: RaceStation, number: Int) -> RaceSegment {
            RaceSegment(
                id: station.id,
                kind: .run,
                badge: "200 m",
                title: "RUN",
                shortDescription: "",
                runNumber: number,
                workStationNumber: nil,
                station: station
            )
        }

        func stationSegment(_ station: RaceStation) -> RaceSegment {
            RaceSegment(
                id: station.id,
                kind: .workStation,
                badge: "STATION \(station.formattedWorkStationNumber)",
                title: station.name,
                shortDescription: station.shortDescription,
                runNumber: nil,
                workStationNumber: station.stationNumber,
                station: station
            )
        }

        let segments: [RaceSegment] = [
            RaceSegment(
                id: "md-cognitive-start",
                kind: .cognitivePreview,
                badge: "START",
                title: "COGNITIVE START",
                shortDescription: "Memorise a pattern before the timer forgives you. The race begins in your head.",
                runNumber: nil,
                workStationNumber: nil,
                station: nil
            ),
            runSegment(run1, number: 1),
            stationSegment(station01),
            runSegment(run2, number: 2),
            stationSegment(station02),
            runSegment(run3, number: 3),
            stationSegment(station03),
            runSegment(run4, number: 4),
            stationSegment(station04),
            runSegment(run5, number: 5),
            stationSegment(station05),
            runSegment(run6, number: 6),
            stationSegment(station06),
            RaceSegment(
                id: "md-cognitive-recall",
                kind: .cognitiveRecall,
                badge: "RECALL",
                title: "COGNITIVE FINISH",
                shortDescription: "Recall the sequence from the start, now under fatigue. Mind and body, together.",
                runNumber: nil,
                workStationNumber: nil,
                station: nil
            ),
            RaceSegment(
                id: "md-finish",
                kind: .finish,
                badge: "FINISH",
                title: "FINISH LINE",
                shortDescription: "Cross the line. Your time only stops when everything is complete.",
                runNumber: nil,
                workStationNumber: nil,
                station: nil
            )
        ]

        return RaceDefinition(
            id: "male-doubles-v1",
            name: "HYFIT Male Doubles",
            category: .maleDoubles,
            segments: segments
        )
    }()
}

enum RaceCatalog {
    static func definition(for category: RaceCategory) -> RaceDefinition {
        switch category {
        case .maleDoubles:
            MaleDoublesRaceDefinition.race
        }
    }
}
