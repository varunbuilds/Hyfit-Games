//
//  HomeView.swift
//  HYFIT
//

import SwiftUI

struct HomeView: View {
    let onStartRace: () -> Void
    let onSelectHistoryResult: (RaceResult) -> Void
    let historyResults: [RaceResult]
    var onRefreshResults: () -> Void = {}
    var onProfileSaved: (AthleteProfile) -> Void = { _ in }

    @State private var selectedTab: HomeTab = .race

    var body: some View {
        ZStack {
            HYFITTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .race:
                        raceLanding
                    case .history:
                        RaceHistoryView(
                            results: historyResults,
                            onSelect: onSelectHistoryResult,
                            onStartRace: {
                                selectedTab = .race
                                onStartRace()
                            }
                        )
                    case .stats:
                        StatsView(
                            results: historyResults,
                            onStartRace: {
                                selectedTab = .race
                                onStartRace()
                            },
                            onRefresh: onRefreshResults
                        )
                    case .profile:
                        ProfileView(
                            results: historyResults,
                            onProfileSaved: onProfileSaved,
                            onOpenStats: { selectedTab = .stats },
                            onRefreshResults: onRefreshResults
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                BottomNavBar(selected: $selectedTab)
            }
        }
        .onChange(of: selectedTab) { _, tab in
            if tab == .stats || tab == .history || tab == .profile {
                onRefreshResults()
            }
        }
    }

    private var raceLanding: some View {
        ZStack {
            AthleticBackdrop()
                .ignoresSafeArea()
                .opacity(0.55)

            VStack(spacing: 0) {
                Spacer(minLength: 24)

                VStack(alignment: .leading, spacing: 28) {
                    branding

                    VStack(alignment: .leading, spacing: 14) {
                        Text("RACE SIMULATOR")
                            .hyfitLabel(HYFITTheme.lime)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("TRAIN.")
                                .hyfitDisplay()
                            Text("RACE.")
                                .hyfitDisplay()
                            Text("OUTPERFORM.")
                                .font(HYFITTypography.display)
                                .foregroundStyle(HYFITTheme.lime)
                                .textCase(.uppercase)
                                .tracking(-0.5)
                        }

                        Text("Simulate the race.\nKnow your performance.")
                            .font(HYFITTypography.body)
                            .foregroundStyle(HYFITTheme.secondaryText)
                            .lineSpacing(4)
                            .padding(.top, 4)
                    }

                    HYFITPrimaryButton(title: "START RACE →", action: onStartRace)
                        .padding(.top, 8)
                }
                .padding(.horizontal, HYFITTheme.horizontalPadding)

                Spacer()
            }
        }
    }

    private var branding: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(HYFITTheme.lime)
                .frame(width: 18, height: 18)
            Text("HYFIT")
                .font(HYFITTypography.heading)
                .foregroundStyle(HYFITTheme.primaryText)
                .tracking(2)
            Text("GAMES")
                .font(HYFITTypography.heading)
                .foregroundStyle(HYFITTheme.secondaryText)
                .tracking(2)
            Spacer()
        }
    }
}

/// Subtle editorial backdrop — black field with lime accent geometry.
private struct AthleticBackdrop: View {
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topTrailing) {
                HYFITTheme.background

                ForEach(0..<6, id: \.self) { index in
                    Rectangle()
                        .fill(Color.white.opacity(index.isMultiple(of: 2) ? 0.03 : 0.015))
                        .frame(width: geo.size.width * 0.18)
                        .offset(x: CGFloat(index) * geo.size.width * 0.16 - geo.size.width * 0.1)
                        .rotationEffect(.degrees(-18))
                }

                Circle()
                    .fill(HYFITTheme.lime.opacity(0.06))
                    .frame(width: geo.size.width * 0.9, height: geo.size.width * 0.9)
                    .blur(radius: 60)
                    .offset(x: geo.size.width * 0.25, y: -geo.size.height * 0.05)
            }
            .clipped()
        }
    }
}

#Preview {
    HomeView(
        onStartRace: {},
        onSelectHistoryResult: { _ in },
        historyResults: [],
        onRefreshResults: {}
    )
}
