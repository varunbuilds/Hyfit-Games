//
//  RaceView.swift
//  HYFIT
//

import SwiftUI

/// Active race container — driven by RaceSession stage machine.
struct RaceView: View {
    @Bindable var session: RaceSession
    let onRaceCompleted: () -> Void

    var body: some View {
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
                Color.clear.onAppear(perform: onRaceCompleted)

            case .idle, .ready:
                Color.clear
            }
        }
        .animation(.easeInOut(duration: 0.22), value: stageAnimationKey)
        .onChange(of: session.stage) { _, newStage in
            if newStage == .completed {
                onRaceCompleted()
            }
        }
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
                totalTimeHeader
                    .padding(.top, 12)

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

    private var totalTimeHeader: some View {
        VStack(spacing: 6) {
            Text("TOTAL TIME")
                .hyfitLabel(HYFITTheme.secondaryText)
            Text(TimeFormatting.raceClock(session.totalElapsed))
                .font(HYFITTypography.timerLarge)
                .foregroundStyle(HYFITTheme.primaryText)
                .monospacedDigit()
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
        onRaceCompleted: {}
    )
}
