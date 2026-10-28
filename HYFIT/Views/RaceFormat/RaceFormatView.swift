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

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(definition.segments.enumerated()), id: \.element.id) { index, segment in
                        FormatTimelineRow(
                            segment: segment,
                            isFirst: index == 0,
                            isLast: index == definition.segments.count - 1
                        )
                    }
                }
                .padding(.horizontal, HYFITTheme.horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, 120)
            }

            VStack {
                Spacer()
                HYFITPrimaryButton(title: "START RACE", action: onStartRace)
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.bottom, 24)
            }
        }
        .navigationTitle("Race Format")
        .navigationBarTitleDisplayMode(.large)
        .toolbar(.hidden, for: .tabBar)
    }
}

private struct FormatTimelineRow: View {
    let segment: RaceSegment
    let isFirst: Bool
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            timelineRail
            content
                .padding(.bottom, isLast ? 0 : 12)
        }
    }

    private var timelineRail: some View {
        VStack(spacing: 0) {
            Circle()
                .stroke(railColor, lineWidth: 1.5)
                .background(Circle().fill(railFill))
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

    private var railColor: Color {
        switch segment.kind {
        case .cognitivePreview, .cognitiveRecall, .finish:
            return HYFITTheme.lime
        default:
            return HYFITTheme.borderStrong
        }
    }

    private var railFill: Color {
        switch segment.kind {
        case .cognitivePreview, .cognitiveRecall, .finish:
            return HYFITTheme.lime.opacity(0.25)
        default:
            return HYFITTheme.surface
        }
    }

    @ViewBuilder
    private var content: some View {
        switch segment.kind {
        case .run:
            runRow
        case .workStation:
            stationCard
        case .cognitivePreview, .cognitiveRecall, .finish:
            cognitiveCard
        }
    }

    /// Unnumbered: "200 m" + "RUN" only.
    private var runRow: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("200 m")
                .font(HYFITTypography.heading)
                .foregroundStyle(HYFITTheme.primaryText)
            Text("RUN")
                .hyfitLabel(HYFITTheme.lime)
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Same card chrome for every physical station — no selected/active treatment.
    private var stationCard: some View {
        HYFITBorderedCard(accentBorder: false, padding: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text(segment.badge)
                    .hyfitLabel(HYFITTheme.lime)

                Text(segment.title)
                    .font(HYFITTypography.heading)
                    .foregroundStyle(HYFITTheme.primaryText)
                    .textCase(.uppercase)
                    .fixedSize(horizontal: false, vertical: true)

                if !segment.shortDescription.isEmpty {
                    Text(segment.shortDescription)
                        .font(HYFITTypography.caption)
                        .foregroundStyle(HYFITTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let metrics = segment.station?.displayMetrics, !metrics.isEmpty {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(metrics, id: \.self) { metric in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(metric.value)
                                    .font(HYFITTypography.bodyEmphasized)
                                    .foregroundStyle(HYFITTheme.primaryText)
                                Text(metric.label)
                                    .hyfitLabel(HYFITTheme.tertiaryText)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    private var cognitiveCard: some View {
        HYFITBorderedCard(accentBorder: false, padding: 16) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: segment.kind == .finish ? "flag.checkered" : "brain.head.profile")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(HYFITTheme.lime)
                    Text(segment.badge)
                        .hyfitLabel(HYFITTheme.lime)
                }

                Text(segment.title)
                    .font(HYFITTypography.heading)
                    .foregroundStyle(HYFITTheme.primaryText)
                    .textCase(.uppercase)

                if !segment.shortDescription.isEmpty {
                    Text(segment.shortDescription)
                        .font(HYFITTypography.caption)
                        .foregroundStyle(HYFITTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

#Preview {
    RaceFormatView(
        definition: MaleDoublesRaceDefinition.race,
        onStartRace: {},
        onBack: {}
    )
}
