//
//  ContentView.swift
//  HYFIT
//

import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()
    @State private var setup = RaceSetupConfiguration.maleDoublesPlaceholder
    @State private var session: RaceSession?
    /// Set together with `session`; navigation runs only after state is committed.
    @State private var pendingActiveRaceNavigation = false

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
        .onChange(of: pendingActiveRaceNavigation) { _, shouldNavigate in
            guard shouldNavigate else { return }
            // Session must already be committed in this same render pass.
            guard session != nil else { return }
            pendingActiveRaceNavigation = false
            path.append(RaceRoute.activeRace)
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
                        path.append(RaceRoute.completion)
                    },
                    onAbortRace: abortActiveRace
                )
            } else {
                // Never wipe the stack — that caused first-launch bounce-to-home.
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
        }
    }

    /// Creates and starts the session first; navigation is deferred to `onChange`
    /// so the active-race destination never mounts with a nil session.
    private func startActiveRace() {
        let raceSession = RaceSession(
            definition: RaceCatalog.definition(for: setup.category),
            setup: setup
        )
        raceSession.startRace()
        session = raceSession
        pendingActiveRaceNavigation = true
    }

    private func finishAndGoHome() {
        session?.resetToIdle()
        session = nil
        pendingActiveRaceNavigation = false
        path = NavigationPath()
    }

    /// Aborts an in-progress race without completion or penalty.
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

/// Intentional placeholder if a race route is ever reached without session state.
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
}
