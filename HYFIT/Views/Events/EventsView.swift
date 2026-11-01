//
//  EventsView.swift
//  HYFIT
//

import SwiftUI

struct HYFITRaceEvent: Identifiable {
    let id: String
    let city: String
    /// Display date, e.g. "5–6 DEC 2026". `nil` when not announced yet.
    let dateText: String?
    /// First race day, used for the "Race in Nd" countdown.
    let startDate: Date?
    let edition: Int
    /// Entry fee in rupees, if announced.
    let priceRupees: Int?
    let isNextRace: Bool
    let registrationOpen: Bool
    let isPast: Bool
    let symbol: String
}

private enum EventFilter: String, CaseIterable, Identifiable {
    case upcoming = "Upcoming Races"
    case registrationOpen = "Registration Open"
    case comingSoon = "Coming Soon"
    case past = "Past Races"

    var id: String { rawValue }

    func includes(_ event: HYFITRaceEvent) -> Bool {
        switch self {
        case .upcoming: !event.isPast
        case .registrationOpen: !event.isPast && event.registrationOpen
        case .comingSoon: !event.isPast && !event.registrationOpen
        case .past: event.isPast
        }
    }
}

struct EventsView: View {
    let onStartRace: () -> Void

    @State private var filter: EventFilter = .upcoming
    @State private var showRegistrationNotice = false

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date? {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))
    }

    private let events: [HYFITRaceEvent] = [
        HYFITRaceEvent(
            id: "delhi-2026",
            city: "Delhi",
            dateText: "5–6 DEC 2026",
            startDate: EventsView.date(2026, 12, 5),
            edition: 2026,
            priceRupees: 1499,
            isNextRace: true,
            registrationOpen: true,
            isPast: false,
            symbol: "building.columns.fill"
        ),
        HYFITRaceEvent(
            id: "gujarat-2027",
            city: "Gujarat",
            dateText: "14 FEB 2027",
            startDate: EventsView.date(2027, 2, 14),
            edition: 2027,
            priceRupees: 1499,
            isNextRace: false,
            registrationOpen: true,
            isPast: false,
            symbol: "building.columns"
        ),
        HYFITRaceEvent(
            id: "hyderabad-2027",
            city: "Hyderabad",
            dateText: nil,
            startDate: nil,
            edition: 2027,
            priceRupees: nil,
            isNextRace: false,
            registrationOpen: false,
            isPast: false,
            symbol: "building.2.fill"
        ),
        HYFITRaceEvent(
            id: "pune-2026-09",
            city: "Pune",
            dateText: "12–13 SEP 2026",
            startDate: EventsView.date(2026, 9, 12),
            edition: 2026,
            priceRupees: nil,
            isNextRace: false,
            registrationOpen: false,
            isPast: true,
            symbol: "figure.strengthtraining.traditional"
        ),
        HYFITRaceEvent(
            id: "mumbai-2026-08",
            city: "Mumbai",
            dateText: "22–23 AUG 2026",
            startDate: EventsView.date(2026, 8, 22),
            edition: 2026,
            priceRupees: nil,
            isNextRace: false,
            registrationOpen: false,
            isPast: true,
            symbol: "figure.strengthtraining.traditional"
        ),
        HYFITRaceEvent(
            id: "bangalore-2026-08",
            city: "Bangalore",
            dateText: "15–16 AUG 2026",
            startDate: EventsView.date(2026, 8, 15),
            edition: 2026,
            priceRupees: nil,
            isNextRace: false,
            registrationOpen: false,
            isPast: true,
            symbol: "figure.strengthtraining.traditional"
        ),
        HYFITRaceEvent(
            id: "mumbai-2026-05",
            city: "Mumbai",
            dateText: "23–24 MAY 2026",
            startDate: EventsView.date(2026, 5, 23),
            edition: 2026,
            priceRupees: nil,
            isNextRace: false,
            registrationOpen: false,
            isPast: true,
            symbol: "figure.strengthtraining.traditional"
        ),
        HYFITRaceEvent(
            id: "bangalore-2026-05",
            city: "Bangalore",
            dateText: "9–10 MAY 2026",
            startDate: EventsView.date(2026, 5, 9),
            edition: 2026,
            priceRupees: nil,
            isNextRace: false,
            registrationOpen: false,
            isPast: true,
            symbol: "figure.strengthtraining.traditional"
        ),
        HYFITRaceEvent(
            id: "delhi-ncr-2026-04",
            city: "Delhi NCR",
            dateText: "25–26 APR 2026",
            startDate: EventsView.date(2026, 4, 25),
            edition: 2026,
            priceRupees: nil,
            isNextRace: false,
            registrationOpen: false,
            isPast: true,
            symbol: "figure.strengthtraining.traditional"
        ),
        HYFITRaceEvent(
            id: "bangalore-2026-02",
            city: "Bangalore",
            dateText: "14 FEB 2026",
            startDate: EventsView.date(2026, 2, 14),
            edition: 2026,
            priceRupees: nil,
            isNextRace: false,
            registrationOpen: false,
            isPast: true,
            symbol: "figure.strengthtraining.traditional"
        ),
        HYFITRaceEvent(
            id: "bangalore-2025-11",
            city: "Bangalore",
            dateText: "16 NOV 2025",
            startDate: EventsView.date(2025, 11, 16),
            edition: 2025,
            priceRupees: nil,
            isNextRace: false,
            registrationOpen: false,
            isPast: true,
            symbol: "figure.strengthtraining.traditional"
        ),
        HYFITRaceEvent(
            id: "bangalore-2025-08",
            city: "Bangalore",
            dateText: "16 AUG 2025",
            startDate: EventsView.date(2025, 8, 16),
            edition: 2025,
            priceRupees: nil,
            isNextRace: false,
            registrationOpen: false,
            isPast: true,
            symbol: "figure.strengthtraining.traditional"
        )
    ]

    private var filtered: [HYFITRaceEvent] {
        let matches = events.filter { filter.includes($0) }
        guard filter == .past else { return matches }
        // Past races: most recent first.
        return matches.sorted {
            ($0.startDate ?? .distantPast) > ($1.startDate ?? .distantPast)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                filterSection
                racesSection
                simulationCard
            }
            .padding(.horizontal, HYFITTheme.horizontalPadding)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(HYFITTheme.background.ignoresSafeArea())
        .alert("Registration", isPresented: $showRegistrationNotice) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Online registration isn't available in the app yet.")
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("The 2026 Season")
                .font(HYFITTypography.sora(size: 13, weight: .semibold))
                .foregroundStyle(HYFITTheme.lime)
            Text("Hyfit Games is heading across India. Pick your city, lock your category, and get to the start line. Ages 8 to 84, every station scales.")
                .font(HYFITTypography.body)
                .foregroundStyle(HYFITTheme.secondaryText)
                .lineSpacing(3)
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Filter

    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("FILTER")
                .hyfitLabel(HYFITTheme.tertiaryText)
                .padding(.leading, 4)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)],
                spacing: 8
            ) {
                ForEach(EventFilter.allCases) { item in
                    filterButton(item)
                }
            }
        }
    }

    private func filterButton(_ item: EventFilter) -> some View {
        let selected = filter == item
        let count = events.filter { item.includes($0) }.count
        return Button {
            withAnimation(HYFITTheme.quickSpring) { filter = item }
        } label: {
            HStack(spacing: 6) {
                Text(item.rawValue)
                    .font(HYFITTypography.sora(size: 12, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Spacer(minLength: 2)
                Text("\(count)")
                    .font(HYFITTypography.sora(size: 12, weight: .regular))
                    .opacity(0.7)
            }
            .foregroundStyle(selected ? HYFITTheme.onLime : HYFITTheme.primaryText)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(selected ? HYFITTheme.lime : HYFITTheme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous)
                    .stroke(selected ? HYFITTheme.lime : HYFITTheme.border, lineWidth: HYFITTheme.borderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    // MARK: - Races

    private var racesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(filter.rawValue.uppercased())
                .hyfitLabel(HYFITTheme.secondaryText)
                .padding(.leading, 4)

            if filtered.isEmpty {
                HYFITEmptyState(
                    symbol: "flag.checkered",
                    title: "Nothing Here Yet",
                    message: "No races in this list right now."
                )
                .padding(.vertical, 32)
            } else if filter == .past {
                LazyVStack(spacing: 12) {
                    ForEach(filtered) { event in
                        pastCard(event)
                    }
                }
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(filtered) { event in
                        raceCard(event)
                    }
                }
            }
        }
    }

    private func statusBadge(_ event: HYFITRaceEvent) -> some View {
        let text: String
        let foreground: Color
        let background: Color
        if event.isPast {
            text = "PAST RACE"; foreground = HYFITTheme.secondaryText; background = Color.black.opacity(0.55)
        } else if event.isNextRace {
            text = "NEXT RACE"; foreground = .white; background = Color(red: 1.0, green: 0.12, blue: 0.25)
        } else if event.registrationOpen {
            text = "REGISTRATION OPEN"; foreground = HYFITTheme.onLime; background = HYFITTheme.lime
        } else {
            text = "COMING SOON"; foreground = HYFITTheme.primaryText; background = Color.black.opacity(0.55)
        }
        return HStack(spacing: 5) {
            if event.isNextRace && !event.isPast {
                Circle().fill(.white).frame(width: 5, height: 5)
            }
            Text(text)
                .font(HYFITTypography.sora(size: 10, weight: .semibold))
                .tracking(0.5)
        }
        .foregroundStyle(foreground)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(background, in: Capsule())
    }

    private func editionPill(_ edition: Int) -> some View {
        let color = edition == 2026 ? HYFITTheme.lime : Color(red: 0.40, green: 0.62, blue: 1.0)
        return Text(verbatim: "\(String(edition)) EDITION")
            .font(HYFITTypography.sora(size: 10, weight: .semibold))
            .tracking(0.5)
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color.black.opacity(0.45), in: Capsule())
            .overlay(Capsule().stroke(color, lineWidth: 1))
    }

    private func daysUntil(_ date: Date?) -> Int? {
        guard let date else { return nil }
        let calendar = Calendar.current
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: Date()),
            to: calendar.startOfDay(for: date)
        ).day
        guard let days, days >= 0 else { return nil }
        return days
    }

    private func raceCard(_ event: HYFITRaceEvent) -> some View {
        VStack(spacing: 0) {
            // Image area (grayscale artwork placeholder until photos are bundled).
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [Color(white: 0.52), Color(white: 0.20)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                Image(systemName: event.symbol)
                    .font(.system(size: 120, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.18))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 28)

                LinearGradient(
                    colors: [.clear, Color.black.opacity(0.85)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 6) {
                    editionPill(event.edition)
                    Text(event.city.uppercased())
                        .font(HYFITTypography.sora(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(event.dateText ?? "DATES TO BE ANNOUNCED")
                        .font(HYFITTypography.sora(size: 12, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.8))
                }
                .padding(18)

                statusBadge(event)
                    .padding(14)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(height: 260)

            // Details panel
            VStack(spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    if let price = event.priceRupees {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text("FROM")
                                .font(HYFITTypography.sora(size: 10, weight: .regular))
                                .foregroundStyle(HYFITTheme.tertiaryText)
                            Text("Rs \(price.formatted())")
                                .font(HYFITTypography.sora(size: 17, weight: .bold))
                                .foregroundStyle(HYFITTheme.primaryText)
                        }
                    } else {
                        Text("Pricing to be announced")
                            .font(HYFITTypography.caption)
                            .foregroundStyle(HYFITTheme.secondaryText)
                    }
                    Spacer()
                    if let days = daysUntil(event.startDate), !event.isPast {
                        HStack(spacing: 4) {
                            Text("Race in")
                                .foregroundStyle(HYFITTheme.tertiaryText)
                            Text("\(days)d")
                                .fontWeight(.semibold)
                                .foregroundStyle(HYFITTheme.danger)
                        }
                        .font(HYFITTypography.sora(size: 12, weight: .regular))
                    }
                }

                if event.registrationOpen && !event.isPast {
                    Button {
                        showRegistrationNotice = true
                    } label: {
                        HStack {
                            Text("REGISTER NOW")
                                .font(HYFITTypography.sora(size: 15, weight: .semibold))
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundStyle(HYFITTheme.onLime)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(HYFITTheme.lime, in: RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous))
                    }
                    .buttonStyle(HYFITPressableStyle())
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.06))
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    /// Compact tile for completed races.
    private func pastCard(_ event: HYFITRaceEvent) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color(white: 0.34), Color(white: 0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
            Image(systemName: event.symbol)
                .font(.system(size: 60))
                .foregroundStyle(Color.white.opacity(0.12))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 36)

            LinearGradient(
                colors: [.clear, Color.black.opacity(0.85)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(event.city.uppercased())
                    .font(HYFITTypography.sora(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                if let date = event.dateText {
                    Text(date)
                        .font(HYFITTypography.sora(size: 12, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.7))
                }
            }
            .padding(12)

            Text("COMPLETED")
                .font(HYFITTypography.sora(size: 9, weight: .semibold))
                .tracking(0.5)
                .foregroundStyle(HYFITTheme.primaryText)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.55), in: Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                .padding(10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(height: 170)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
    }

    // MARK: - Simulation

    private var simulationCard: some View {
        HYFITGroupCard(padding: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Can't wait for race day?")
                    .font(HYFITTypography.sora(size: 18, weight: .semibold))
                    .foregroundStyle(HYFITTheme.primaryText)
                Text("Run an official HYFIT simulation anytime to benchmark your station splits and cognitive recall.")
                    .font(HYFITTypography.body)
                    .foregroundStyle(HYFITTheme.secondaryText)
                    .lineSpacing(3)
                HYFITPrimaryButton(title: "START SIMULATION →", action: onStartRace)
                    .padding(.top, 4)
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
