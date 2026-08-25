//
//  RaceHistoryView.swift
//  HYFIT
//

import SwiftUI

struct RaceHistoryView: View {
    let results: [RaceResult]
    let onSelect: (RaceResult) -> Void
    let onStartRace: () -> Void

    var body: some View {
        ZStack {
            HYFITTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("RACE HISTORY")
                    .hyfitTitle()
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                if results.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(results) { result in
                                Button {
                                    onSelect(result)
                                } label: {
                                    RaceHistoryCard(result: result)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, HYFITTheme.horizontalPadding)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("NO RACES YET")
                .font(HYFITTypography.heading)
                .foregroundStyle(HYFITTheme.primaryText)
            Text("Complete your first HYFIT race\nto see your results here.")
                .font(HYFITTypography.body)
                .foregroundStyle(HYFITTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
            HYFITPrimaryButton(title: "START RACE →", action: onStartRace)
                .padding(.horizontal, HYFITTheme.horizontalPadding)
                .padding(.top, 8)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

private struct RaceHistoryCard: View {
    let result: RaceResult

    var body: some View {
        HYFITBorderedCard(padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                Text(TimeFormatting.historyDate(result.completedAt))
                    .hyfitLabel(HYFITTheme.lime)

                VStack(alignment: .leading, spacing: 4) {
                    Text(TimeFormatting.raceClock(result.adjustedFinishTime))
                        .font(HYFITTypography.metric)
                        .foregroundStyle(HYFITTheme.primaryText)
                        .monospacedDigit()
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    Text("FINAL TIME")
                        .hyfitLabel(HYFITTheme.tertiaryText)
                }

                VStack(spacing: 8) {
                    historyRow("RAW TIME", TimeFormatting.paddedRaceClock(result.rawFinishTime))
                    historyRow("PENALTY", TimeFormatting.signedPenaltyClock(result.penaltySeconds))
                    historyRow("RECALL", "\(result.correctPositions) / 10")
                }
            }
        }
    }

    private func historyRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .hyfitLabel(HYFITTheme.tertiaryText)
            Spacer()
            Text(value)
                .font(HYFITTypography.bodyEmphasized)
                .foregroundStyle(HYFITTheme.primaryText)
                .monospacedDigit()
        }
    }
}

#Preview {
    RaceHistoryView(results: [], onSelect: { _ in }, onStartRace: {})
}
