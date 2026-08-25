//
//  RaceDetailView.swift
//  HYFIT
//

import SwiftUI

struct RaceDetailView: View {
    let result: RaceResult
    let onBack: () -> Void

    private let sequenceColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)

    var body: some View {
        ZStack {
            HYFITTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 16)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        overallSection
                        cognitiveSection
                        aggregatesSection
                        breakdownSection
                    }
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.bottom, 40)
                }
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

            Text("RACE DETAIL")
                .hyfitTitle()

            Spacer()
        }
    }

    private var overallSection: some View {
        HYFITBorderedCard(padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                Text(TimeFormatting.historyDate(result.completedAt))
                    .hyfitLabel(HYFITTheme.lime)

                VStack(alignment: .leading, spacing: 4) {
                    Text(TimeFormatting.raceClock(result.adjustedFinishTime))
                        .font(HYFITTypography.metricLarge)
                        .foregroundStyle(HYFITTheme.primaryText)
                        .monospacedDigit()
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    Text("FINAL TIME")
                        .hyfitLabel(HYFITTheme.tertiaryText)
                }

                detailRow("RAW TIME", TimeFormatting.paddedRaceClock(result.rawFinishTime))
                detailRow("PENALTY", TimeFormatting.signedPenaltyClock(result.penaltySeconds))
            }
        }
    }

    private var cognitiveSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("COGNITIVE RECALL")
                .hyfitLabel(HYFITTheme.lime)

            HYFITBorderedCard(padding: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    detailRow("RECALL", "\(result.correctPositions) / 10")
                    detailRow("RESULT", result.penaltyType.displayLabel.uppercased())
                    detailRow("PENALTY", TimeFormatting.signedPenaltyClock(result.penaltySeconds))
                    detailRow(
                        "START DURATION",
                        TimeFormatting.paddedRaceClock(result.cognitiveStartDuration)
                    )
                    detailRow(
                        "RECALL DURATION",
                        TimeFormatting.paddedRaceClock(result.cognitiveRecallDuration)
                    )

                    sequenceBlock(title: "ORIGINAL", colors: result.originalSequence)
                        .padding(.top, 6)
                    sequenceBlock(title: "SUBMITTED", colors: result.submittedSequence)
                }
            }
        }
    }

    private var aggregatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PERFORMANCE")
                .hyfitLabel(HYFITTheme.lime)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                metricCell("RUNNING TIME", TimeFormatting.paddedRaceClock(result.runningTime))
                metricCell("STATION TIME", TimeFormatting.paddedRaceClock(result.stationTime))
                metricCell("TRANSITION TIME", TimeFormatting.paddedRaceClock(result.transitionTime))
                metricCell("TOTAL DISTANCE", TimeFormatting.kilometersLabel(result.totalDistanceMeters))
            }
        }
    }

    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RACE BREAKDOWN")
                .hyfitLabel(HYFITTheme.lime)

            VStack(spacing: 10) {
                ForEach(Array(result.completedStations.enumerated()), id: \.element.id) { _, record in
                    segmentRow(record)
                }
            }
        }
    }

    private func segmentRow(_ record: CompletedStationRecord) -> some View {
        HYFITBorderedCard(padding: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(segmentTitle(for: record))
                        .font(HYFITTypography.bodyEmphasized)
                        .foregroundStyle(HYFITTheme.primaryText)
                        .textCase(.uppercase)
                        .fixedSize(horizontal: false, vertical: true)

                    if let meters = record.distanceCompletedMeters {
                        Text(String(format: "%.0f M COMPLETED", meters))
                            .hyfitLabel(HYFITTheme.tertiaryText)
                    } else if let distance = record.station.distance,
                              let unit = record.station.distanceUnit,
                              record.station.movement != .run {
                        // Non-run distance targets shown when completion meters absent
                        Text(TimeFormatting.distanceLabel(value: distance, unit: unit))
                            .hyfitLabel(HYFITTheme.tertiaryText)
                    }
                }

                Spacer(minLength: 8)

                Text(TimeFormatting.paddedRaceClock(record.duration))
                    .font(HYFITTypography.heading)
                    .foregroundStyle(HYFITTheme.lime)
                    .monospacedDigit()
            }
        }
    }

    private func segmentTitle(for record: CompletedStationRecord) -> String {
        let station = record.station
        if station.movement.countsAsRunning {
            return "200 M RUN \(String(format: "%02d", station.stationNumber))"
        }
        return "STATION \(station.formattedWorkStationNumber) — \(station.name)"
    }

    private func sequenceBlock(title: String, colors: [CognitiveColor]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .hyfitLabel(HYFITTheme.tertiaryText)

            if colors.isEmpty {
                Text("—")
                    .font(HYFITTypography.body)
                    .foregroundStyle(HYFITTheme.secondaryText)
            } else {
                LazyVGrid(columns: sequenceColumns, spacing: 8) {
                    ForEach(Array(colors.enumerated()), id: \.offset) { _, color in
                        Text(color.letter)
                            .font(HYFITTypography.bodyEmphasized)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(color.displayColor)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: HYFITTheme.cornerRadiusSmall,
                                    style: .continuous
                                )
                            )
                    }
                }
            }
        }
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .hyfitLabel(HYFITTheme.tertiaryText)
            Spacer(minLength: 12)
            Text(value)
                .font(HYFITTypography.bodyEmphasized)
                .foregroundStyle(HYFITTheme.primaryText)
                .monospacedDigit()
                .multilineTextAlignment(.trailing)
                .minimumScaleFactor(0.7)
        }
    }

    private func metricCell(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .hyfitLabel(HYFITTheme.tertiaryText)
            Text(value)
                .font(HYFITTypography.heading)
                .foregroundStyle(HYFITTheme.primaryText)
                .monospacedDigit()
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HYFITTheme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous)
                .stroke(HYFITTheme.border, lineWidth: HYFITTheme.borderWidth)
        )
        .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous))
    }
}

#Preview {
    RaceDetailView(
        result: RaceResult(
            id: UUID(),
            completedAt: Date(),
            definitionID: "male-doubles-v1",
            definitionName: "HYFIT Male Doubles",
            category: .maleDoubles,
            setup: .maleDoublesPlaceholder,
            rawFinishTime: 1122,
            penaltySeconds: -30,
            adjustedFinishTime: 1092,
            completedStations: [],
            cognitiveStartDuration: 12,
            cognitiveRecallDuration: 45,
            originalSequence: CognitiveColor.randomSequence(),
            submittedSequence: CognitiveColor.randomSequence(),
            correctPositions: 10,
            penaltyType: .fullRecall,
            runningTime: 400,
            stationTime: 600,
            transitionTime: 122,
            totalDistanceMeters: 1200
        ),
        onBack: {}
    )
}
