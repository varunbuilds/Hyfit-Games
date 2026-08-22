//
//  RaceFormatView.swift
//  HYFIT
//

import SwiftUI

struct RaceFormatView: View {
    let definition: RaceDefinition
    let onStartRace: () -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            HYFITTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 20)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(definition.stations.enumerated()), id: \.element.id) { index, station in
                            StationTimelineRow(
                                station: station,
                                isFirst: index == 0,
                                isLast: index == definition.stations.count - 1,
                                isHighlighted: index == 0
                            )
                        }
                    }
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.bottom, 120)
                }
            }

            VStack {
                Spacer()
                HYFITPrimaryButton(title: "START RACE", action: onStartRace)
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        HStack(spacing: 14) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(HYFITTheme.primaryText)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)

            Text("RACE FORMAT")
                .hyfitTitle()

            Spacer()
        }
    }
}

private struct StationTimelineRow: View {
    let station: RaceStation
    let isFirst: Bool
    let isLast: Bool
    let isHighlighted: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            timelineRail

            Group {
                if isHighlighted {
                    highlightedCard
                } else {
                    compactRow
                }
            }
            .padding(.bottom, isLast ? 0 : 14)
        }
    }

    private var timelineRail: some View {
        VStack(spacing: 0) {
            Circle()
                .stroke(isHighlighted ? HYFITTheme.lime : HYFITTheme.borderStrong, lineWidth: 1.5)
                .background(
                    Circle().fill(isHighlighted ? HYFITTheme.lime : HYFITTheme.surface)
                )
                .frame(width: 14, height: 14)
                .padding(.top, 18)

            if !isLast {
                Rectangle()
                    .fill(HYFITTheme.border)
                    .frame(width: 1)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 14)
    }

    private var highlightedCard: some View {
        HYFITBorderedCard(accentBorder: true, padding: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text("\(station.stationNumber)")
                        .font(HYFITTypography.label)
                        .foregroundStyle(HYFITTheme.lime)
                    Text(station.name)
                        .font(HYFITTypography.heading)
                        .foregroundStyle(HYFITTheme.primaryText)
                        .textCase(.uppercase)
                }

                Text(station.shortDescription)
                    .font(HYFITTypography.caption)
                    .foregroundStyle(HYFITTheme.secondaryText)

                Text(station.type == .distance ? "DISTANCE" : "REPETITIONS")
                    .hyfitLabel(HYFITTheme.tertiaryText)
                    .padding(.top, 2)
            }
        }
    }

    private var compactRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("\(station.stationNumber)")
                    .font(HYFITTypography.label)
                    .foregroundStyle(HYFITTheme.tertiaryText)
                Text(station.name)
                    .font(HYFITTypography.bodyEmphasized)
                    .foregroundStyle(HYFITTheme.primaryText)
                    .textCase(.uppercase)
            }
            Text(station.shortDescription)
                .font(HYFITTypography.caption)
                .foregroundStyle(HYFITTheme.secondaryText)
                .padding(.leading, 22)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    RaceFormatView(
        definition: MaleDoublesRaceDefinition.race,
        onStartRace: {},
        onBack: {}
    )
}
