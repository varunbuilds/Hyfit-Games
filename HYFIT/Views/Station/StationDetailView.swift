//
//  StationDetailView.swift
//  HYFIT
//

import SwiftUI

/// Reusable station presentation driven entirely by `RaceStation`.
struct StationDetailView: View {
    let station: RaceStation
    let stationIndex: Int
    let totalStations: Int
    let totalElapsed: TimeInterval
    let stationElapsed: TimeInterval
    var distanceCurrent: Double? = nil
    var onDone: () -> Void

    var body: some View {
        ZStack {
            HYFITTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.top, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        titleBlock
                        specsRow
                        if station.type == .distance {
                            distanceBlock
                        }
                        howToBlock
                    }
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.top, 20)
                    .padding(.bottom, 120)
                }
            }

            VStack {
                Spacer()
                HYFITPrimaryButton(title: "I'M DONE", action: onDone)
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.bottom, 24)
            }
        }
    }

    private var topBar: some View {
        HStack {
            Text("STATION \(stationIndex + 1) OF \(totalStations)")
                .hyfitLabel(HYFITTheme.lime)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("TOTAL")
                    .hyfitLabel(HYFITTheme.tertiaryText)
                Text(TimeFormatting.paddedRaceClock(totalElapsed))
                    .font(HYFITTypography.heading)
                    .foregroundStyle(HYFITTheme.primaryText)
                    .monospacedDigit()
            }
        }
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(station.name)
                .font(HYFITTypography.title)
                .foregroundStyle(HYFITTheme.primaryText)
                .textCase(.uppercase)
                .fixedSize(horizontal: false, vertical: true)

            Rectangle()
                .fill(HYFITTheme.lime)
                .frame(width: 56, height: 3)
                .clipShape(Capsule())
        }
    }

    private var specsRow: some View {
        HStack(alignment: .top, spacing: 12) {
            if let load = station.load, let unit = station.loadUnit {
                SpecCell(
                    icon: "dumbbell.fill",
                    value: "\(Int(load)) \(unit.shortLabel)",
                    caption: station.loadNote ?? "LOAD"
                )
            }

            if let boxHeight = station.boxHeight {
                SpecCell(
                    icon: "square.stack.3d.up",
                    value: boxHeight,
                    caption: "BOX HEIGHT"
                )
            }

            if let reps = station.reps, station.type == .repetitions {
                SpecCell(
                    icon: "arrow.counterclockwise",
                    value: "\(reps)",
                    caption: "REPS"
                )
            }

            if station.type == .distance, let distance = station.distance, let unit = station.distanceUnit {
                SpecCell(
                    icon: distanceIcon,
                    value: TimeFormatting.distanceLabel(value: distance, unit: unit),
                    caption: "DISTANCE"
                )
            }

            if let equipment = station.equipment, station.load == nil {
                SpecCell(
                    icon: "wrench.and.screwdriver",
                    value: equipment.uppercased(),
                    caption: "EQUIPMENT"
                )
            }
        }
    }

    @ViewBuilder
    private var distanceBlock: some View {
        if let current = distanceCurrent,
           let target = station.distance,
           let unit = station.distanceUnit {
            VStack(alignment: .leading, spacing: 14) {
                Text("PROGRESS")
                    .hyfitLabel(HYFITTheme.tertiaryText)

                if station.movement == .run {
                    HStack {
                        Spacer()
                        CircularDistanceProgress(
                            current: current,
                            target: target,
                            unit: unit,
                            iconSystemName: distanceIcon
                        )
                        Spacer()
                    }
                } else {
                    SegmentedDistanceBar(current: current, target: target, unit: unit)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(TimeFormatting.paddedRaceClock(stationElapsed))
                        .font(HYFITTypography.timer)
                        .foregroundStyle(HYFITTheme.lime)
                        .monospacedDigit()
                    Text("TIME ELAPSED")
                        .hyfitLabel(HYFITTheme.tertiaryText)
                }
            }
            .padding(.top, 4)
        }
    }

    private var howToBlock: some View {
        Group {
            if !station.instructions.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("HOW TO")
                        .hyfitLabel(HYFITTheme.lime)

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(Array(station.instructions.enumerated()), id: \.offset) { _, line in
                            HStack(alignment: .top, spacing: 10) {
                                Text("•")
                                    .foregroundStyle(HYFITTheme.lime)
                                Text(line)
                                    .font(HYFITTypography.body)
                                    .foregroundStyle(HYFITTheme.secondaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
        }
    }

    private var distanceIcon: String {
        switch station.movement {
        case .run: "figure.run"
        case .crawl: "figure.climbing"
        case .carry: "figure.walk"
        case .sled: "line.horizontal.3"
        default: "arrow.right"
        }
    }
}

private struct SpecCell: View {
    let icon: String
    let value: String
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(HYFITTheme.lime)

            Text(value)
                .font(HYFITTypography.heading)
                .foregroundStyle(HYFITTheme.primaryText)
                .textCase(.uppercase)
                .minimumScaleFactor(0.7)
                .lineLimit(2)

            Text(caption)
                .hyfitLabel(HYFITTheme.tertiaryText)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HYFITTheme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: HYFITTheme.cornerRadiusSmall, style: .continuous)
                .stroke(HYFITTheme.border, lineWidth: HYFITTheme.borderWidth)
        )
        .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadiusSmall, style: .continuous))
    }
}

#Preview("Reps") {
    StationDetailView(
        station: MaleDoublesRaceDefinition.race.stations[1],
        stationIndex: 1,
        totalStations: 6,
        totalElapsed: 112.4,
        stationElapsed: 0,
        onDone: {}
    )
}

#Preview("Distance") {
    StationDetailView(
        station: MaleDoublesRaceDefinition.race.stations[3],
        stationIndex: 3,
        totalStations: 6,
        totalElapsed: 400,
        stationElapsed: 28,
        distanceCurrent: 14,
        onDone: {}
    )
}
