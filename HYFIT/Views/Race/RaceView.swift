//
//  RaceView.swift
//  HYFIT
//

import SwiftUI

/// Active race container — chooses distance performance UI or station detail from model data.
struct RaceView: View {
    @Bindable var session: RaceSession
    let onRaceCompleted: () -> Void

    var body: some View {
        Group {
            if let station = session.currentStation {
                switch station.type {
                case .distance where station.movement == .run:
                    DistanceRaceStationView(
                        session: session,
                        station: station,
                        onDone: completeStation
                    )
                    .id(station.id)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                case .distance, .repetitions:
                    StationDetailView(
                        station: station,
                        stationIndex: session.currentStationIndex,
                        totalStations: session.definition.stationCount,
                        totalElapsed: session.totalElapsed,
                        stationElapsed: session.stationElapsed,
                        distanceCurrent: station.type == .distance
                            ? session.distanceTracker.currentDistance
                            : nil,
                        onDone: completeStation
                    )
                    .id(station.id)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                }
            } else {
                Color.clear.onAppear(perform: onRaceCompleted)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: session.currentStationIndex)
        .onChange(of: session.phase) { _, newPhase in
            if newPhase == .completed {
                onRaceCompleted()
            }
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

    private var movementLabel: String {
        switch station.movement {
        case .run: "RUN"
        case .crawl: "CRAWL"
        case .carry: "CARRY"
        case .sled: "SLED"
        case .stepUp: "STEP-UP"
        case .other: station.type.rawValue.uppercased()
        }
    }

    private var iconName: String {
        switch station.movement {
        case .run: "figure.run"
        case .crawl: "figure.climbing"
        case .carry: "figure.walk"
        default: "arrow.right"
        }
    }

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

                    Text(movementLabel)
                        .hyfitLabel(HYFITTheme.lime)
                }

                Spacer(minLength: 16)

                CircularDistanceProgress(
                    current: tracker.currentDistance,
                    target: tracker.targetDistance,
                    unit: tracker.unit,
                    iconSystemName: iconName
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

    @ViewBuilder
    private var upNextCard: some View {
        if let next = session.nextStation {
            HYFITBorderedCard(padding: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("UP NEXT")
                        .hyfitLabel(HYFITTheme.tertiaryText)
                    Text(next.name)
                        .font(HYFITTypography.heading)
                        .foregroundStyle(HYFITTheme.primaryText)
                        .textCase(.uppercase)
                    Text(next.targetSummary)
                        .font(HYFITTypography.caption)
                        .foregroundStyle(HYFITTheme.lime)
                        .textCase(.uppercase)
                }
            }
        } else {
            HYFITBorderedCard(padding: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("UP NEXT")
                        .hyfitLabel(HYFITTheme.tertiaryText)
                    Text("FINISH")
                        .font(HYFITTypography.heading)
                        .foregroundStyle(HYFITTheme.primaryText)
                    Text("FINAL STATION")
                        .font(HYFITTypography.caption)
                        .foregroundStyle(HYFITTheme.lime)
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
