//
//  RaceCompletionView.swift
//  HYFIT
//

import SwiftUI

struct RaceCompletionView: View {
    let session: RaceSession
    let onDone: () -> Void
    let onRaceAgain: () -> Void

    private var summary: RacePerformanceSummary {
        session.performanceSummary
    }

    var body: some View {
        ZStack {
            HYFITTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 28) {
                        header
                        trophyBlock
                        summaryGrid
                    }
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.top, 28)
                    .padding(.bottom, 140)
                }

                Spacer(minLength: 0)
            }

            VStack(spacing: 12) {
                Spacer()
                HYFITPrimaryButton(title: "DONE", action: onDone)
                HYFITSecondaryButton(title: "RACE AGAIN", action: onRaceAgain)
            }
            .padding(.horizontal, HYFITTheme.horizontalPadding)
            .padding(.bottom, 24)
        }
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        VStack(spacing: 14) {
            Text("RACE COMPLETE")
                .hyfitLabel(HYFITTheme.lime)

            Text(TimeFormatting.raceClock(summary.totalTime))
                .font(HYFITTypography.metricHuge)
                .foregroundStyle(HYFITTheme.primaryText)
                .monospacedDigit()
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
    }

    private var trophyBlock: some View {
        VStack(spacing: 14) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(HYFITTheme.lime)

            Text("GREAT WORK!")
                .font(HYFITTypography.heading)
                .foregroundStyle(HYFITTheme.primaryText)

            Text("You just completed the\nHYFIT Race Simulation.")
                .font(HYFITTypography.body)
                .foregroundStyle(HYFITTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
    }

    private var summaryGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            SummaryMetricCell(
                label: "RUNNING TIME",
                value: TimeFormatting.paddedRaceClock(summary.runningTime)
            )
            SummaryMetricCell(
                label: "STATION TIME",
                value: TimeFormatting.paddedRaceClock(summary.stationTime)
            )
            SummaryMetricCell(
                label: "TRANSITION TIME",
                value: TimeFormatting.paddedRaceClock(summary.transitionTime)
            )
            SummaryMetricCell(
                label: "TOTAL DISTANCE",
                value: TimeFormatting.kilometersLabel(summary.totalDistanceMeters)
            )
        }
    }
}

private struct SummaryMetricCell: View {
    let label: String
    let value: String

    var body: some View {
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
}

#Preview {
    let session = RaceSession(
        definition: MaleDoublesRaceDefinition.race,
        setup: .maleDoublesPlaceholder
    )
    return RaceCompletionView(session: session, onDone: {}, onRaceAgain: {})
}
