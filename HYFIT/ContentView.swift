//
//  ContentView.swift
//  HYFIT
//

import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()
    @State private var setup = RaceSetupConfiguration.maleDoublesPlaceholder
    @State private var session: RaceSession?

    var body: some View {
        NavigationStack(path: $path) {
            HomeView {
                path.append(RaceRoute.setup)
            }
            .navigationDestination(for: RaceRoute.self) { route in
                destination(for: route)
            }
        }
        .preferredColorScheme(.dark)
        .tint(HYFITTheme.lime)
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
                RaceView(session: session) {
                    path.append(RaceRoute.completion)
                }
            } else {
                Color.clear.onAppear { path = NavigationPath() }
            }
        case .completion:
            if let session {
                RaceCompletionView(
                    session: session,
                    onDone: finishAndGoHome,
                    onRaceAgain: raceAgain
                )
            } else {
                Color.clear.onAppear { path = NavigationPath() }
            }
        }
    }

    private func startActiveRace() {
        let raceSession = RaceSession(
            definition: RaceCatalog.definition(for: setup.category),
            setup: setup
        )
        session = raceSession
        raceSession.startRace()
        path.append(RaceRoute.activeRace)
    }

    private func finishAndGoHome() {
        session?.resetToIdle()
        session = nil
        path = NavigationPath()
    }

    private func raceAgain() {
        // Drop previous session so START RACE creates a fresh sequence.
        session?.prepareAgain()
        session = nil
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

#Preview {
    ContentView()
}
