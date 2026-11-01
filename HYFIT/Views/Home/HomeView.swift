//
//  HomeView.swift
//  HYFIT
//

import SwiftUI

struct HomeView<Destination: View>: View {
    @Binding var path: NavigationPath
    let onStartRace: () -> Void
    let onSelectHistoryResult: (RaceResult) -> Void
    let historyResults: [RaceResult]
    var onRefreshResults: () -> Void = {}
    var onProfileSaved: (AthleteProfile) -> Void = { _ in }
    @ViewBuilder var destination: (RaceRoute) -> Destination

    @State private var selectedTab: HomeTab = .race
    @State private var historyPath = NavigationPath()
    @State private var isShowingProfile = false

    /// Tab bar hides/returns in step with the push/pop so it never "pops in".
    private static var tabBarAnimation: Animation { .easeInOut(duration: 0.3) }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(HomeTab.race.title, systemImage: HomeTab.race.systemImage, value: .race) {
                NavigationStack(path: $path) {
                    raceLanding
                        .hyfitPageHeader(title: HomeTab.race.title, onOpenProfile: openProfile)
                        .navigationDestination(for: RaceRoute.self, destination: destination)
                }
                .toolbar(path.isEmpty ? .visible : .hidden, for: .tabBar)
                .animation(Self.tabBarAnimation, value: path.isEmpty)
            }

            Tab(HomeTab.history.title, systemImage: HomeTab.history.systemImage, value: .history) {
                NavigationStack(path: $historyPath) {
                    RaceHistoryView(
                        results: historyResults,
                        onSelect: { result in
                            onSelectHistoryResult(result)
                            historyPath.append(RaceRoute.raceDetail(result.id))
                        },
                        onStartRace: {
                            selectedTab = .race
                            onStartRace()
                        }
                    )
                    .hyfitPageHeader(title: HomeTab.history.title, onOpenProfile: openProfile)
                    .navigationDestination(for: RaceRoute.self, destination: destination)
                }
                .toolbar(historyPath.isEmpty ? .visible : .hidden, for: .tabBar)
                .animation(Self.tabBarAnimation, value: historyPath.isEmpty)
            }

            Tab(HomeTab.stats.title, systemImage: HomeTab.stats.systemImage, value: .stats) {
                NavigationStack {
                    StatsView(
                        results: historyResults,
                        onStartRace: {
                            selectedTab = .race
                            onStartRace()
                        },
                        onRefresh: onRefreshResults
                    )
                    .hyfitPageHeader(title: HomeTab.stats.title, onOpenProfile: openProfile)
                }
            }

            Tab(HomeTab.events.title, systemImage: HomeTab.events.systemImage, value: .events) {
                NavigationStack {
                    EventsView(
                        onStartRace: {
                            selectedTab = .race
                            onStartRace()
                        }
                    )
                    .hyfitPageHeader(title: HomeTab.events.title, onOpenProfile: openProfile)
                }
            }
        }
        .tint(HYFITTheme.lime)
        .sheet(isPresented: $isShowingProfile) {
            NavigationStack {
                ProfileView(
                    results: historyResults,
                    onProfileSaved: onProfileSaved,
                    onOpenStats: {
                        isShowingProfile = false
                        selectedTab = .stats
                    },
                    onRefreshResults: onRefreshResults
                )
            }
            .preferredColorScheme(.dark)
            .tint(HYFITTheme.lime)
        }
        .onChange(of: selectedTab) { _, tab in
            if tab == .stats || tab == .history {
                onRefreshResults()
            }
        }
    }

    private func openProfile() {
        onRefreshResults()
        isShowingProfile = true
    }

    private var latestResult: RaceResult? {
        historyResults.max(by: { $0.completedAt < $1.completedAt })
    }

    private var raceLanding: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Race Simulator")
                            .font(HYFITTypography.sora(size: 14, weight: .semibold))
                            .foregroundStyle(HYFITTheme.lime)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("RUN.")
                                .hyfitDisplay()
                            Text("LIFT.")
                                .hyfitDisplay()
                            Text("LIVE.")
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

                    VStack(alignment: .leading, spacing: 16) {
                        HYFITPrimaryButton(title: "START RACE →", action: onStartRace)

                        if let latest = latestResult {
                            latestRaceCard(latest)
                        }
                    }
                }
                .padding(.horizontal, HYFITTheme.horizontalPadding)
                .padding(.top, 20)
                .padding(.bottom, 32)
                // Vertically center the landing content in the visible area.
                .frame(minHeight: geo.size.height, alignment: .center)
            }
        }
        .background(HYFITTheme.background.ignoresSafeArea())
    }

    private func latestRaceCard(_ result: RaceResult) -> some View {
        Button {
            onSelectHistoryResult(result)
            selectedTab = .history
            historyPath.append(RaceRoute.raceDetail(result.id))
        } label: {
            HYFITGroupCard(padding: 20) {
                HStack(spacing: 16) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 20))
                        .foregroundStyle(HYFITTheme.lime)
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Last race")
                            .font(HYFITTypography.sora(size: 16, weight: .semibold))
                            .foregroundStyle(HYFITTheme.primaryText)
                        Text("\(result.category.title) · \(TimeFormatting.historyDate(result.completedAt))")
                            .font(HYFITTypography.caption)
                            .foregroundStyle(HYFITTheme.secondaryText)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 8)

                    Text(TimeFormatting.raceClock(result.adjustedFinishTime))
                        .font(HYFITTypography.sora(size: 16, weight: .semibold))
                        .foregroundStyle(HYFITTheme.lime)
                        .monospacedDigit()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(HYFITTheme.tertiaryText)
                }
            }
        }
        .buttonStyle(HYFITPressableStyle())
    }
}

#Preview {
    HomeView(
        path: .constant(NavigationPath()),
        onStartRace: {},
        onSelectHistoryResult: { _ in },
        historyResults: [],
        onRefreshResults: {},
        destination: { _ in EmptyView() }
    )
    .preferredColorScheme(.dark)
}
