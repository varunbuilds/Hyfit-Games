//
//  ContentView.swift
//  HYFIT
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var path = NavigationPath()
    @State private var setup = RaceSetupConfiguration.maleDoublesPlaceholder
    @State private var session: RaceSession?
    /// Set together with `session`; navigation runs only after state is committed.
    @State private var pendingActiveRaceNavigation = false
    @State private var historyResults: [RaceResult] = []

    private var resultStore: RaceResultStore {
        RaceResultStore(modelContext: modelContext)
    }

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
                onStartRace: {
                    path.append(RaceRoute.setup)
                },
                onSelectHistoryResult: { result in
                    path.append(RaceRoute.raceDetail(result.id))
                },
                historyResults: historyResults
            )
            .navigationDestination(for: RaceRoute.self) { route in
                destination(for: route)
            }
        }
        .preferredColorScheme(.dark)
        .tint(HYFITTheme.lime)
        .onChange(of: pendingActiveRaceNavigation) { _, shouldNavigate in
            guard shouldNavigate else { return }
            guard session != nil else { return }
            pendingActiveRaceNavigation = false
            path.append(RaceRoute.activeRace)
        }
        .onAppear {
            refreshHistory()
            resultStore.debugLogStoreCount(context: "launch")
        }
    }

    @ViewBuilder
    private func destination(for route: RaceRoute) -> some View {
        switch route {
        case .setup:
            RaceSetupView(
                configuration: $setup,
                onContinue: { path.append(RaceRoute.format) },
                onBack: { pop() }
            )
        case .format:
            RaceFormatView(
                definition: RaceCatalog.definition(for: setup.category),
                onStartRace: startActiveRace,
                onBack: { pop() }
            )
        case .activeRace:
            if let session {
                RaceView(
                    session: session,
                    onRaceCompleted: {
                        persistCompletedResultIfNeeded(from: session)
                        refreshHistory()
                        path.append(RaceRoute.completion)
                    },
                    onAbortRace: abortActiveRace
                )
            } else {
                RaceRouteLoadingView()
            }
        case .completion:
            if let session {
                RaceCompletionView(
                    session: session,
                    onDone: finishAndGoHome,
                    onRaceAgain: raceAgain
                )
            } else {
                RaceRouteLoadingView()
            }
        case .raceDetail(let id):
            if let result = resultStore.fetch(id: id) ?? historyResults.first(where: { $0.id == id }) {
                RaceDetailView(result: result, onBack: { pop() })
            } else {
                RaceRouteLoadingView()
            }
        }
    }

    private func startActiveRace() {
        let raceSession = RaceSession(
            definition: RaceCatalog.definition(for: setup.category),
            setup: setup
        )
        raceSession.startRace()
        session = raceSession
        pendingActiveRaceNavigation = true
    }

    private func persistCompletedResultIfNeeded(from session: RaceSession) {
        guard let result = session.raceResult else { return }
        resultStore.saveIfNeeded(result)
    }

    private func refreshHistory() {
        historyResults = resultStore.fetchAll()
    }

    private func finishAndGoHome() {
        session?.resetToIdle()
        session = nil
        pendingActiveRaceNavigation = false
        refreshHistory()
        path = NavigationPath()
    }

    private func abortActiveRace() {
        session?.resetToIdle()
        session = nil
        pendingActiveRaceNavigation = false
        var next = NavigationPath()
        next.append(RaceRoute.setup)
        next.append(RaceRoute.format)
        path = next
    }

    private func raceAgain() {
        session?.prepareAgain()
        session = nil
        pendingActiveRaceNavigation = false
        var next = NavigationPath()
        next.append(RaceRoute.setup)
        next.append(RaceRoute.format)
        path = next
    }

    private func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}

private struct RaceRouteLoadingView: View {
    var body: some View {
        ZStack {
            HYFITTheme.background.ignoresSafeArea()
            ProgressView()
                .tint(HYFITTheme.lime)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PersistedRaceResult.self, inMemory: true)
}
