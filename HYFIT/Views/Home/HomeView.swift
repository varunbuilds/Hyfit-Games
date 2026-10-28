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

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(HomeTab.race.title, systemImage: HomeTab.race.systemImage, value: .race) {
                NavigationStack(path: $path) {
                    raceLanding
                        .hyfitPageHeader(title: HomeTab.race.title, onOpenProfile: openProfile)
                        .navigationDestination(for: RaceRoute.self, destination: destination)
                }
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

    private var raceLanding: some View {
        ZStack {
            AthleticBackdrop()
                .ignoresSafeArea()
                .opacity(0.55)

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    branding

                    VStack(alignment: .leading, spacing: 14) {
                        Text("RACE SIMULATOR")
                            .hyfitLabel(HYFITTheme.lime)

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

                    HYFITPrimaryButton(title: "START RACE →", action: onStartRace)
                        .padding(.top, 8)
                }
                .padding(.horizontal, HYFITTheme.horizontalPadding)
                .padding(.top, 20)
                .padding(.bottom, 32)
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
        path: .constant(NavigationPath()),
        onStartRace: {},
        onSelectHistoryResult: { _ in },
        historyResults: [],
        onRefreshResults: {},
        destination: { _ in EmptyView() }
    )
    .preferredColorScheme(.dark)
}
