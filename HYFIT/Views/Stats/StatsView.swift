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
        ScrollView {
            if summary.isEmpty {
                HYFITEmptyState(
                    symbol: "chart.bar.xaxis",
                    title: "No Race Data Yet",
                    message: "Complete your first HYFIT race\nto start building your stats.",
                    actionTitle: "Start Race",
                    action: onStartRace
                )
                .containerRelativeFrame(.vertical)
            } else {
                VStack(alignment: .leading, spacing: 28) {
                    overviewSection
                    progressSection
                    if let bests = summary.personalBests {
                        personalBestsSection(bests)
                    }
                    if !summary.runRows.isEmpty {
                        runPerformanceSection
                    }
                    if !summary.stationRows.isEmpty {
                        stationPerformanceSection
                    }
                    if let cognitive = summary.cognitive {
                        cognitiveSection(cognitive)
                    }
                }
                .padding(.horizontal, HYFITTheme.horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
        .background(HYFITTheme.background.ignoresSafeArea())
        .onAppear(perform: onRefresh)
    }

    // MARK: - Overview

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HYFITSectionHeader(title: "Overview")

            HYFITGroupCard(padding: 20) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Best time")
                            .font(HYFITTypography.caption)
                            .foregroundStyle(HYFITTheme.secondaryText)
                        Text(summary.bestAdjustedFinishTime.map { TimeFormatting.raceClock($0) } ?? "—")
                            .font(HYFITTypography.sora(size: 44, weight: .bold))
                            .foregroundStyle(HYFITTheme.lime)
                            .monospacedDigit()
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                    }

                    Divider().overlay(Color.white.opacity(0.08))

                    HStack(alignment: .top, spacing: 12) {
                        summaryStat("Races", "\(summary.raceCount)")
                        summaryStat(
                            "Average",
                            summary.averageAdjustedFinishTime.map { TimeFormatting.raceClock($0) } ?? "—"
                        )
                        summaryStat("Distance", TimeFormatting.kilometersLabel(summary.totalDistanceMeters))
                    }
                }
            }
        }
    }

    // MARK: - Progress

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HYFITSectionHeader(title: "Progress", subtitle: "Final time per race")

            HYFITGroupCard(padding: 20) {
                if summary.progressPoints.count == 1, let only = summary.progressPoints.first {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(TimeFormatting.raceClock(only.adjustedFinishTime))
                            .font(HYFITTypography.sora(size: 34, weight: .bold))
                            .foregroundStyle(HYFITTheme.lime)
                            .monospacedDigit()
                        Text(TimeFormatting.historyDate(only.completedAt))
                            .font(HYFITTypography.caption)
                            .foregroundStyle(HYFITTheme.secondaryText)
                        Text("Complete more races to see your trend.")
                            .font(HYFITTypography.caption)
                            .foregroundStyle(HYFITTheme.tertiaryText)
                            .padding(.top, 6)
                    }
                } else if summary.progressPoints.count > 1 {
                    VStack(alignment: .leading, spacing: 12) {
                        StatsProgressChart(points: summary.progressPoints)
                            .frame(height: 150)

                        HStack {
                            Text(TimeFormatting.historyDate(summary.progressPoints.first!.completedAt))
                            Spacer()
                            Text(TimeFormatting.historyDate(summary.progressPoints.last!.completedAt))
                        }
                        .font(HYFITTypography.caption)
                        .foregroundStyle(HYFITTheme.secondaryText)
                    }
                }
            }
        }
    }

    // MARK: - Personal bests

    private func personalBestsSection(_ bests: StatsPersonalBests) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HYFITSectionHeader(title: "Personal Bests")

            HYFITGroupCard {
                VStack(spacing: 0) {
                    bestRow(icon: "trophy.fill", "Final time", TimeFormatting.raceClock(bests.finalTime))
                    HYFITCardDivider(inset: 68)
                    bestRow(icon: "bolt.fill", "Fastest 200 m", TimeFormatting.paddedRaceClock(bests.fastest200m))
                    HYFITCardDivider(inset: 68)
                    bestRow(
                        icon: "stopwatch.fill",
                        "Fastest station",
                        TimeFormatting.paddedRaceClock(bests.fastestStationDuration),
                        detail: bests.fastestStationName.capitalized
                    )
                    HYFITCardDivider(inset: 68)
                    bestRow(
                        icon: "brain.head.profile",
                        "Best recall",
                        "\(bests.bestRecallCorrect) / \(bests.recallSequenceLength)"
                    )
                }
            }
        }
    }

    // MARK: - Runs

    private var runPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HYFITSectionHeader(title: "Runs", subtitle: "Best and average per 200 m run")

            HYFITGroupCard {
                VStack(spacing: 0) {
                    columnHeader()
                    ForEach(summary.runRows) { row in
                        HYFITCardDivider()
                        tableRow(
                            title: "Run \(String(format: "%02d", row.runNumber))",
                            best: TimeFormatting.paddedRaceClock(row.best),
                            average: TimeFormatting.paddedRaceClock(row.average)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Stations

    private var stationPerformanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HYFITSectionHeader(title: "Stations", subtitle: "Best and average per station")

            HYFITGroupCard {
                VStack(spacing: 0) {
                    columnHeader()
                    ForEach(summary.stationRows) { row in
                        HYFITCardDivider()
                        tableRow(
                            title: "\(String(format: "%02d", row.stationNumber))  \(row.name.capitalized)",
                            best: TimeFormatting.paddedRaceClock(row.best),
                            average: TimeFormatting.paddedRaceClock(row.average)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Cognitive

    private func cognitiveSection(_ cognitive: StatsCognitiveSummary) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HYFITSectionHeader(title: "Cognitive", subtitle: "Recall accuracy under fatigue")

            HYFITGroupCard {
                VStack(spacing: 0) {
                    valueRow(
                        "Average recall",
                        String(format: "%.1f / %d", cognitive.averageRecall, cognitive.recallSequenceLength)
                    )
                    HYFITCardDivider()
                    valueRow("Best recall", "\(cognitive.bestRecall) / \(cognitive.recallSequenceLength)")
                    HYFITCardDivider()
                    valueRow("Average penalty", TimeFormatting.signedPenaltyClock(cognitive.averagePenaltySeconds))
                    HYFITCardDivider()
                    valueRow("Perfect recalls", "\(cognitive.perfectRecallCount)")
                }
            }
        }
    }

    // MARK: - Building blocks

    private func summaryStat(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(HYFITTypography.caption)
                .foregroundStyle(HYFITTheme.secondaryText)
            Text(value)
                .font(HYFITTypography.sora(size: 17, weight: .semibold))
                .foregroundStyle(HYFITTheme.primaryText)
                .monospacedDigit()
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func valueRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(HYFITTypography.body)
                .foregroundStyle(HYFITTheme.secondaryText)
            Spacer(minLength: 12)
            Text(value)
                .font(HYFITTypography.sora(size: 16, weight: .semibold))
                .foregroundStyle(HYFITTheme.primaryText)
                .monospacedDigit()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private func bestRow(icon: String, _ label: String, _ value: String, detail: String? = nil) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(HYFITTheme.lime)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(HYFITTypography.sora(size: 16, weight: .semibold))
                    .foregroundStyle(HYFITTheme.primaryText)
                if let detail {
                    Text(detail)
                        .font(HYFITTypography.caption)
                        .foregroundStyle(HYFITTheme.secondaryText)
                }
            }
            Spacer(minLength: 8)
            Text(value)
                .font(HYFITTypography.sora(size: 16, weight: .semibold))
                .foregroundStyle(HYFITTheme.lime)
                .monospacedDigit()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private func columnHeader() -> some View {
        HStack(spacing: 8) {
            Spacer()
            Text("Best")
                .frame(width: 72, alignment: .trailing)
            Text("Average")
                .frame(width: 72, alignment: .trailing)
        }
        .font(HYFITTypography.caption)
        .foregroundStyle(HYFITTheme.secondaryText)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }

    private func tableRow(title: String, best: String, average: String) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(HYFITTypography.sora(size: 14, weight: .semibold))
                .foregroundStyle(HYFITTheme.primaryText)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 4)
            Text(best)
                .font(HYFITTypography.sora(size: 13, weight: .semibold))
                .foregroundStyle(HYFITTheme.lime)
                .monospacedDigit()
                .frame(width: 72, alignment: .trailing)
            Text(average)
                .font(HYFITTypography.sora(size: 13, weight: .regular))
                .foregroundStyle(HYFITTheme.secondaryText)
                .monospacedDigit()
                .frame(width: 72, alignment: .trailing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
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
