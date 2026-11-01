//
//  RaceHistoryView.swift
//  HYFIT
//

import SwiftUI

struct RaceHistoryView: View {
    let results: [RaceResult]
    let onSelect: (RaceResult) -> Void
    let onStartRace: () -> Void

    private struct MonthGroup: Identifiable {
        let title: String
        let results: [RaceResult]
        var id: String { title }
    }

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()

    /// Newest first, grouped by month while preserving order.
    private var groups: [MonthGroup] {
        let sorted = results.sorted { $0.completedAt > $1.completedAt }
        var order: [String] = []
        var buckets: [String: [RaceResult]] = [:]
        for result in sorted {
            let key = Self.monthFormatter.string(from: result.completedAt)
            if buckets[key] == nil { order.append(key) }
            buckets[key, default: []].append(result)
        }
        return order.map { MonthGroup(title: $0, results: buckets[$0] ?? []) }
    }

    var body: some View {
        ScrollView {
            if results.isEmpty {
                HYFITEmptyState(
                    symbol: "clock.arrow.circlepath",
                    title: "No Races Yet",
                    message: "Complete your first HYFIT race\nto see your results here.",
                    actionTitle: "Start Race",
                    action: onStartRace
                )
                .containerRelativeFrame(.vertical)
            } else {
                LazyVStack(alignment: .leading, spacing: 28) {
                    ForEach(groups) { group in
                        VStack(alignment: .leading, spacing: 12) {
                            HYFITSectionHeader(
                                title: group.title,
                                subtitle: group.results.count == 1 ? "1 race" : "\(group.results.count) races"
                            )
                            VStack(spacing: 12) {
                                ForEach(group.results) { result in
                                    Button {
                                        onSelect(result)
                                    } label: {
                                        RaceHistoryCard(result: result)
                                    }
                                    .buttonStyle(HYFITPressableStyle())
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, HYFITTheme.horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
        }
        .background(HYFITTheme.background.ignoresSafeArea())
    }
}

private struct RaceHistoryCard: View {
    let result: RaceResult

    private var penaltyColor: Color {
        if result.penaltySeconds > 0 { return HYFITTheme.danger }
        if result.penaltySeconds < 0 { return HYFITTheme.lime }
        return HYFITTheme.secondaryText
    }

    var body: some View {
        HYFITGroupCard(padding: 20) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.category.title)
                            .font(HYFITTypography.sora(size: 16, weight: .semibold))
                            .foregroundStyle(HYFITTheme.primaryText)
                        Text(TimeFormatting.historyDate(result.completedAt))
                            .font(HYFITTypography.caption)
                            .foregroundStyle(HYFITTheme.secondaryText)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(HYFITTheme.tertiaryText)
                        .padding(.top, 4)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(TimeFormatting.raceClock(result.adjustedFinishTime))
                        .font(HYFITTypography.sora(size: 40, weight: .bold))
                        .foregroundStyle(HYFITTheme.lime)
                        .monospacedDigit()
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    Text("Final time")
                        .font(HYFITTypography.caption)
                        .foregroundStyle(HYFITTheme.secondaryText)
                }

                Divider().overlay(Color.white.opacity(0.08))

                HStack(alignment: .top, spacing: 12) {
                    stat("Raw time", TimeFormatting.paddedRaceClock(result.rawFinishTime))
                    stat("Penalty", TimeFormatting.signedPenaltyClock(result.penaltySeconds), color: penaltyColor)
                    stat("Recall", "\(result.correctPositions) / 10")
                }
            }
        }
    }

    private func stat(_ label: String, _ value: String, color: Color = HYFITTheme.primaryText) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(HYFITTypography.caption)
                .foregroundStyle(HYFITTheme.secondaryText)
            Text(value)
                .font(HYFITTypography.sora(size: 15, weight: .semibold))
                .foregroundStyle(color)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    RaceHistoryView(results: [], onSelect: { _ in }, onStartRace: {})
}
