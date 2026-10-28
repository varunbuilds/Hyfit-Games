//
//  BottomNavBar.swift
//  HYFIT
//

import SwiftUI

enum HomeTab: String, CaseIterable, Identifiable {
    case race
    case history
    case stats
    case events

    var id: String { rawValue }

    var title: String {
        switch self {
        case .race: "Race"
        case .history: "History"
        case .stats: "Stats"
        case .events: "Events"
        }
    }

    var systemImage: String {
        switch self {
        case .race: "flag.checkered"
        case .history: "clock.arrow.circlepath"
        case .stats: "chart.bar"
        case .events: "calendar"
        }
    }

    var isImplemented: Bool {
        switch self {
        case .race, .history, .stats, .events: true
        }
    }
}

struct BottomNavBar: View {
    @Binding var selected: HomeTab

    var body: some View {
        TabView(selection: $selected) {
            ForEach(HomeTab.allCases) { tab in
                Tab(tab.title, systemImage: tab.systemImage, value: tab) {
                    HYFITTheme.background.ignoresSafeArea()
                }
            }
        }
        .tint(HYFITTheme.lime)
    }
}

#Preview {
    BottomNavBar(selected: .constant(.race))
        .preferredColorScheme(.dark)
}
