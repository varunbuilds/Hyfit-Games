//
//  RaceView.swift
//  HYFIT
//

import SwiftUI

/// Active race container — driven by RaceSession stage machine.
struct RaceView: View {
    @Bindable var session: RaceSession
    let onRaceCompleted: () -> Void
    let onAbortRace: () -> Void

    @State private var showExitConfirmation = false
    @State private var isAborting = false
    /// Ensures completion navigation is reported once per finished session.
    @State private var didNotifyCompletion = false

    private var isActiveRace: Bool {
        switch session.stage {
        case .cognitivePreview, .physical, .cognitiveRecall:
            true
        case .completed, .idle, .ready:
            false
        }
    }

    var body: some View {
        Group {
            if isActiveRace {
                VStack(spacing: 0) {
                    raceHeader
                        .padding(.horizontal, HYFITTheme.horizontalPadding)
                        .padding(.top, 8)
                        .padding(.bottom, 4)

                    stageContent
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(HYFITTheme.background.ignoresSafeArea())
            } else {
                stageContent
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .disableInteractivePopGesture()
        .alert("Exit Race?", isPresented: $showExitConfirmation) {
            Button("Continue Race", role: .cancel) {}
            Button("Exit Race", role: .destructive, action: confirmAbort)
        } message: {
            Text("Your current race will be lost.")
        }
        .onChange(of: session.stage) { _, newStage in
            // Single authoritative completion trigger — do not also fire from .completed onAppear.
            if newStage == .completed {
                showExitConfirmation = false
                notifyCompletionIfNeeded()
            }
        }
    }

    /// Shared chrome — same position for every active stage.
    private var raceHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 16) {
                Text("TOTAL TIME")
                    .hyfitLabel(HYFITTheme.secondaryText)

                Spacer(minLength: 12)

                exitButton
            }

            Text(TimeFormatting.raceClock(session.totalElapsed))
                .font(HYFITTypography.timerLarge)
                .foregroundStyle(HYFITTheme.primaryText)
                .monospacedDigit()
                .minimumScaleFactor(0.7)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var exitButton: some View {
        Button {
            guard !isAborting else { return }
            showExitConfirmation = true
        } label: {
            Text("EXIT")
                .hyfitLabel(HYFITTheme.secondaryText)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isAborting)
        .accessibilityLabel("Exit Race")
    }

    @ViewBuilder
    private var stageContent: some View {
        Group {
            switch session.stage {
            case .cognitivePreview:
                CognitivePreviewView(
                    sequence: session.cognitiveSequence,
                    totalElapsed: session.totalElapsed,
                    onRemember: {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            session.completeCognitivePreview()
                        }
                    }
                )
                .transition(.opacity)

            case .physical:
                if let station = session.currentStation {
                    physicalContent(for: station)
                        .id(station.id)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }

            case .cognitiveRecall:
                CognitiveRecallView(session: session)
                    .transition(.opacity)

            case .completed:
                // Navigation is owned by onChange(stage → .completed). Keep a blank
                // placeholder so we do not fire onRaceCompleted a second time via onAppear.
                Color.clear

            case .idle, .ready:
                Color.clear
            }
        }
        .animation(.easeInOut(duration: 0.22), value: stageAnimationKey)
    }

    private var stageAnimationKey: String {
        switch session.stage {
        case .cognitivePreview: "preview"
        case .physical(let index): "physical-\(index)"
        case .cognitiveRecall: "recall"
        case .completed: "completed"
        case .idle: "idle"
        case .ready: "ready"
        }
    }

    @ViewBuilder
    private func physicalContent(for station: RaceStation) -> some View {
        switch station.type {
        case .distance where station.movement == .run:
            DistanceRaceStationView(
                session: session,
                station: station,
                onDone: completeStation
            )
        case .distance, .repetitions:
            StationDetailView(
                station: station,
                totalWorkStations: session.definition.workStationCount,
                totalElapsed: session.totalElapsed,
                stationElapsed: session.stationElapsed,
                distanceCurrent: station.type == .distance
                    ? session.distanceTracker.currentDistance
                    : nil,
                onDone: completeStation
            )
        }
    }

    private func completeStation() {
        withAnimation(.easeInOut(duration: 0.22)) {
            session.completeCurrentStation()
        }
    }

    private func notifyCompletionIfNeeded() {
        guard !isAborting else { return }
        guard !didNotifyCompletion else { return }
        guard session.stage == .completed else { return }
        didNotifyCompletion = true
        onRaceCompleted()
    }

    private func confirmAbort() {
        guard !isAborting else { return }
        guard isActiveRace else { return }
        isAborting = true
        showExitConfirmation = false
        onAbortRace()
    }
}

struct DistanceRaceStationView: View {
    @Bindable var session: RaceSession
    let station: RaceStation
    let onDone: () -> Void

    private var tracker: any DistanceTracking { session.distanceTracker }

    var body: some View {
        ZStack {
            HYFITTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 12)

                VStack(spacing: 10) {
                    Text("CURRENT")
                        .hyfitLabel(HYFITTheme.tertiaryText)

                    Text(station.name)
                        .font(HYFITTypography.title)
                        .foregroundStyle(HYFITTheme.primaryText)
                        .textCase(.uppercase)
                        .multilineTextAlignment(.center)

                    Text(station.shortDescription.isEmpty ? "RUN" : station.shortDescription)
                        .hyfitLabel(HYFITTheme.lime)
                }

                Spacer(minLength: 16)

                CircularDistanceProgress(
                    current: tracker.currentDistance,
                    target: tracker.targetDistance,
                    unit: tracker.unit,
                    iconSystemName: "figure.run"
                )

                Spacer(minLength: 16)

                VStack(spacing: 6) {
                    Text(TimeFormatting.paddedRaceClock(session.stationElapsed))
                        .font(HYFITTypography.timer)
                        .foregroundStyle(HYFITTheme.lime)
                        .monospacedDigit()
                    Text("TIME ELAPSED")
                        .hyfitLabel(HYFITTheme.tertiaryText)
                }

                Spacer(minLength: 20)

                upNextCard
                    .padding(.horizontal, HYFITTheme.horizontalPadding)

                HYFITPrimaryButton(title: "I'M DONE", action: onDone)
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.top, 14)
                    .padding(.bottom, 24)
            }
        }
    }

    private var upNextCard: some View {
        HYFITBorderedCard(padding: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("UP NEXT")
                    .hyfitLabel(HYFITTheme.tertiaryText)
                Text(session.nextUpTitle ?? "NEXT")
                    .font(HYFITTypography.heading)
                    .foregroundStyle(HYFITTheme.primaryText)
                    .textCase(.uppercase)
                if let summary = session.nextUpSummary, !summary.isEmpty {
                    Text(summary)
                        .font(HYFITTypography.caption)
                        .foregroundStyle(HYFITTheme.lime)
                        .textCase(.uppercase)
                }
            }
        }
    }
}

#Preview {
    RaceView(
        session: {
            let session = RaceSession(
                definition: MaleDoublesRaceDefinition.race,
                setup: .maleDoublesPlaceholder
            )
            session.startRace()
            return session
        }(),
        onRaceCompleted: {},
        onAbortRace: {}
    )
}
