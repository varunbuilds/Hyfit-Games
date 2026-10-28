//
//  EventsView.swift
//  HYFIT
//

import SwiftUI

struct HYFITEvent: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let dateLabel: String
    let location: String
    let category: String
    let statusBadge: String
}

struct EventsView: View {
    let onStartRace: () -> Void

    private let upcomingEvents: [HYFITEvent] = [
        HYFITEvent(
            id: "hyfit-open-sim",
            title: "HYFIT GLOBAL SIMULATION",
            subtitle: "8 × 200 m runs + 8 functional stations + cognitive recall",
            dateLabel: "OPEN QUALIFIER",
            location: "ANYWHERE · GPS / SIMULATED",
            category: "MALE DOUBLES",
            statusBadge: "LIVE"
        ),
        HYFITEvent(
            id: "hyfit-championship-prep",
            title: "SEASON CHAMPIONSHIP PREP",
            subtitle: "Full competition simulation under official penalty rules",
            dateLabel: "UPCOMING SERIES",
            location: "HYFIT ARENA SERIES",
            category: "ALL DIVISIONS",
            statusBadge: "UPCOMING"
        )
    ]

    var body: some View {
        ZStack {
            HYFITTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    featuredBanner

                    VStack(alignment: .leading, spacing: 12) {
                        Text("EVENTS & QUALIFIERS")
                            .hyfitLabel(HYFITTheme.lime)

                        LazyVStack(spacing: 14) {
                            ForEach(upcomingEvents) { event in
                                eventCard(event)
                            }
                        }
                    }
                }
                .padding(.horizontal, HYFITTheme.horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
    }

    private var featuredBanner: some View {
        HYFITBorderedCard(accentBorder: true, padding: 18) {
            VStack(alignment: .leading, spacing: 12) {
                Text("OFFICIAL FORMAT")
                    .hyfitLabel(HYFITTheme.lime)

                Text("COMPETE ANYWHERE")
                    .font(HYFITTypography.heading)
                    .foregroundStyle(HYFITTheme.primaryText)
                    .textCase(.uppercase)

                Text("Run an official HYFIT simulation anytime to benchmark your station splits and cognitive recall.")
                    .font(HYFITTypography.body)
                    .foregroundStyle(HYFITTheme.secondaryText)
                    .lineSpacing(3)

                HYFITPrimaryButton(title: "START SIMULATION →", action: onStartRace)
                    .padding(.top, 4)
            }
        }
    }

    private func eventCard(_ event: HYFITEvent) -> some View {
        HYFITBorderedCard(padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(event.dateLabel)
                        .hyfitLabel(HYFITTheme.lime)
                    Spacer()
                    Text(event.statusBadge)
                        .hyfitLabel(event.statusBadge == "LIVE" ? HYFITTheme.lime : HYFITTheme.tertiaryText)
                }

                Text(event.title)
                    .font(HYFITTypography.heading)
                    .foregroundStyle(HYFITTheme.primaryText)
                    .textCase(.uppercase)

                Text(event.subtitle)
                    .font(HYFITTypography.body)
                    .foregroundStyle(HYFITTheme.secondaryText)
                    .lineSpacing(2)

                HStack {
                    Text(event.location)
                        .hyfitLabel(HYFITTheme.tertiaryText)
                    Spacer()
                    Text(event.category)
                        .hyfitLabel(HYFITTheme.secondaryText)
                }
                .padding(.top, 2)
            }
        }
    }
}

#Preview {
    NavigationStack {
        EventsView(onStartRace: {})
            .navigationTitle("Events")
            .toolbarTitleDisplayMode(.inlineLarge)
    }
    .preferredColorScheme(.dark)
}
