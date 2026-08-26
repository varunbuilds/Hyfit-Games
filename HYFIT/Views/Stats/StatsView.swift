//
//  StatsView.swift
//  HYFIT
//

import SwiftUI

struct StatsView: View {
    let results: [RaceResult]
    let onStartRace: () -> Void
    let onRefresh: () -> Void

    private var summary: StatsSummary {
        StatsCalculator.summarize(results)
    }

    var body: some View {
        ZStack {
            HYFITTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("STATS")
                    .hyfitTitle()
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                if summary.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 28) {
                            performanceSection
                            progressSection
                            if !summary.runRows.isEmpty {
                                runPerformanceSection
                            }
                            if !summary.stationRows.isEmpty {
                                stationPerformanceSection
                            }
                            if let cognitive = summary.cognitive {
                                cognitiveSection(cognitive)
                            }
                            if let bests = summary.personalBests {
                                personalBestsSection(bests)
                            }
                        }
                        .padding(.horizontal, HYFITTheme.horizontalPadding)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .onAppear(perform: onRefresh)
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("NO RACE DATA YET")
                .font(HYFITTypography.heading)
                .foregroundStyle(HYFITTheme.primaryText)
            Text("Complete your first HYFIT race\nto start building your stats.")
                .font(HYFITTypography.body)
                .foregroundStyle(HYFITTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
            HYFITPrimaryButton(title: "START RACE", action: onStartRace)
                .padding(.horizontal, HYFITTheme.horizontalPadding)
                .padding(.top, 8)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Performance

    private var performanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("PERFORMANCE")

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                metricCell(
                    "BEST TIME",
                    summary.bestAdjustedFinishTime.map { TimeFormatting.raceClock($0) } ?? "—"
                )
                metricCell(
                    "AVERAGE TIME",
                    summary.averageAdjustedFinishTime.map { TimeFormatting.raceClock($0) } ?? "—"
                )
                metricCell("RACES", "\(summary.raceCount)")
                metricCell(
                    "DISTANCE",
                    TimeFormatting.kilometersLabel(summary.totalDistanceMeters)
                )
            }
        }
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("PROGRESS")

            HYFITBorderedCard(padding: 16) {
                if summary.progressPoints.count == 1, let only = summary.progressPoints.first {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(TimeFormatting.raceClock(only.adjustedFinishTime))
                            .font(HYFITTypography.metric)
                            .foregroundStyle(HYFITTheme.lime)
                            .monospacedDigit()
                        Text("FINAL TIME · \(TimeFormatting.historyDate(only.completedAt))")
                            .hyfitLabel(HYFITTheme.tertiaryText)
                        Text("Complete more races to see your trend.")
                            .font(HYFITTypography.caption)
                            .foregroundStyle(HYFITTheme.secondaryText)
                            .padding(.top, 4)
                    }
                } else if summary.progressPoints.count > 1 {
                    VStack(alignment: .leading, spacing: 12) {
                        StatsProgressChart(points: summary.progressPoints)
                            .frame(height: 140)

                        HStack {
                            Text(TimeFormatting.historyDate(summary.progressPoints.first!.completedAt))
                                .hyfitLabel(HYFITTheme.tertiaryText)
                            Spacer()
                            Text("NEWEST")
                                .hyfitLabel(HYFITTheme.lime)
                            Text(TimeFormatting.historyDate(summary.progressPoints.last!.completedAt))
                                .hyfitLabel(HYFITTheme.tertiaryText)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Runs

    private var runPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("RUN PERFORMANCE")

            HYFITBorderedCard(padding: 14) {
                VStack(spacing: 12) {
                    ForEach(summary.runRows) { row in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("RUN \(String(format: "%02d", row.runNumber))")
                                .font(HYFITTypography.bodyEmphasized)
                                .foregroundStyle(HYFITTheme.primaryText)
                                .frame(width: 72, alignment: .leading)

                            Spacer(minLength: 8)

                            compactStat("BEST", TimeFormatting.paddedRaceClock(row.best))
                            compactStat("AVG", TimeFormatting.paddedRaceClock(row.average))
                                .frame(minWidth: 88, alignment: .trailing)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Stations

    private var stationPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("STATION PERFORMANCE")

            VStack(spacing: 10) {
                ForEach(summary.stationRows) { row in
                    HYFITBorderedCard(padding: 14) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("\(String(format: "%02d", row.stationNumber))  \(row.name)")
                                .font(HYFITTypography.bodyEmphasized)
                                .foregroundStyle(HYFITTheme.primaryText)
                                .textCase(.uppercase)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack {
                                compactStat("BEST", TimeFormatting.paddedRaceClock(row.best))
                                Spacer()
                                compactStat("AVG", TimeFormatting.paddedRaceClock(row.average))
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Cognitive

    private func cognitiveSection(_ cognitive: StatsCognitiveSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("COGNITIVE")

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                metricCell(
                    "AVERAGE RECALL",
                    String(format: "%.1f / %d", cognitive.averageRecall, cognitive.recallSequenceLength)
                )
                metricCell(
                    "BEST RECALL",
                    "\(cognitive.bestRecall) / \(cognitive.recallSequenceLength)"
                )
                metricCell(
                    "AVERAGE PENALTY",
                    TimeFormatting.signedPenaltyClock(cognitive.averagePenaltySeconds)
                )
                metricCell("PERFECT RECALLS", "\(cognitive.perfectRecallCount)")
            }
        }
    }

    // MARK: - Personal bests

    private func personalBestsSection(_ bests: StatsPersonalBests) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("PERSONAL BESTS")

            HYFITBorderedCard(padding: 16) {
                VStack(spacing: 12) {
                    personalBestRow("FINAL TIME", TimeFormatting.raceClock(bests.finalTime))
                    personalBestRow("FASTEST 200 M", TimeFormatting.paddedRaceClock(bests.fastest200m))
                    VStack(alignment: .leading, spacing: 4) {
                        personalBestRow(
                            "FASTEST STATION",
                            TimeFormatting.paddedRaceClock(bests.fastestStationDuration)
                        )
                        Text(bests.fastestStationName)
                            .hyfitLabel(HYFITTheme.tertiaryText)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    personalBestRow(
                        "BEST RECALL",
                        "\(bests.bestRecallCorrect) / \(bests.recallSequenceLength)"
                    )
                }
            }
        }
    }

    // MARK: - Shared chrome

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .hyfitLabel(HYFITTheme.lime)
    }

    private func metricCell(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .hyfitLabel(HYFITTheme.tertiaryText)
            Text(value)
                .font(HYFITTypography.heading)
                .foregroundStyle(HYFITTheme.primaryText)
                .monospacedDigit()
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HYFITTheme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous)
                .stroke(HYFITTheme.border, lineWidth: HYFITTheme.borderWidth)
        )
        .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous))
    }

    private func compactStat(_ label: String, _ value: String) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .hyfitLabel(HYFITTheme.tertiaryText)
            Text(value)
                .font(HYFITTypography.bodyEmphasized)
                .foregroundStyle(HYFITTheme.primaryText)
                .monospacedDigit()
        }
    }

    private func personalBestRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .hyfitLabel(HYFITTheme.tertiaryText)
            Spacer(minLength: 12)
            Text(value)
                .font(HYFITTypography.heading)
                .foregroundStyle(HYFITTheme.lime)
                .monospacedDigit()
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
    }
}

// MARK: - Progress chart (no third-party libs)

private struct StatsProgressChart: View {
    let points: [StatsProgressPoint]

    var body: some View {
        GeometryReader { geo in
            let times = points.map(\.adjustedFinishTime)
            let minT = times.min() ?? 0
            let maxT = times.max() ?? 1
            let span = max(maxT - minT, 0.1)
            let w = geo.size.width
            let h = geo.size.height
            let count = points.count

            ZStack {
                // Baseline
                Path { path in
                    path.move(to: CGPoint(x: 0, y: h - 1))
                    path.addLine(to: CGPoint(x: w, y: h - 1))
                }
                .stroke(HYFITTheme.border, lineWidth: 1)

                // Trend line
                Path { path in
                    for (index, point) in points.enumerated() {
                        let x = xPosition(index: index, count: count, width: w)
                        let y = yPosition(time: point.adjustedFinishTime, minT: minT, span: span, height: h)
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(HYFITTheme.lime.opacity(0.55), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                // Points
                ForEach(Array(points.enumerated()), id: \.element.id) { index, point in
                    let x = xPosition(index: index, count: count, width: w)
                    let y = yPosition(time: point.adjustedFinishTime, minT: minT, span: span, height: h)
                    Circle()
                        .fill(point.isNewest ? HYFITTheme.lime : HYFITTheme.primaryText)
                        .frame(width: point.isNewest ? 10 : 6, height: point.isNewest ? 10 : 6)
                        .position(x: x, y: y)
                }
            }
        }
        .accessibilityLabel("Final time progress chart")
    }

    private func xPosition(index: Int, count: Int, width: CGFloat) -> CGFloat {
        guard count > 1 else { return width / 2 }
        return CGFloat(index) / CGFloat(count - 1) * width
    }

    private func yPosition(time: TimeInterval, minT: TimeInterval, span: TimeInterval, height: CGFloat) -> CGFloat {
        // Faster (lower) times plot higher on the chart.
        let normalized = (time - minT) / span
        let topPad: CGFloat = 10
        let bottomPad: CGFloat = 10
        let usable = height - topPad - bottomPad
        return topPad + CGFloat(normalized) * usable
    }
}

#Preview("Empty") {
    StatsView(results: [], onStartRace: {}, onRefresh: {})
}

#Preview("With data") {
    StatsView(
        results: [],
        onStartRace: {},
        onRefresh: {}
    )
}
