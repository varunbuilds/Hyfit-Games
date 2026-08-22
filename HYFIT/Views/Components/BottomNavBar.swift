//
//  BottomNavBar.swift
//  HYFIT
//

import SwiftUI

enum HomeTab: String, CaseIterable, Identifiable {
    case race
    case history
    case stats
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .race: "RACE"
        case .history: "HISTORY"
        case .stats: "STATS"
        case .profile: "PROFILE"
        }
    }

    var systemImage: String {
        switch self {
        case .race: "flag.checkered"
        case .history: "clock.arrow.circlepath"
        case .stats: "chart.bar"
        case .profile: "person"
        }
    }

    var isImplemented: Bool { self == .race }
}

struct BottomNavBar: View {
    @Binding var selected: HomeTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(HomeTab.allCases) { tab in
                Button {
                    if tab.isImplemented {
                        selected = tab
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 18, weight: .semibold))
                        Text(tab.title)
                            .font(HYFITTypography.label)
                            .tracking(0.8)
                    }
                    .foregroundStyle(selected == tab ? HYFITTheme.lime : HYFITTheme.tertiaryText)
                    .frame(maxWidth: .infinity)
                    .opacity(tab.isImplemented ? 1 : 0.45)
                }
                .buttonStyle(.plain)
                .disabled(!tab.isImplemented)
                .accessibilityLabel(tab.title)
                .accessibilityHint(tab.isImplemented ? "" : "Coming soon")
            }
        }
        .padding(.top, 14)
        .padding(.bottom, 8)
        .padding(.horizontal, 8)
        .background(HYFITTheme.background)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(HYFITTheme.border)
                .frame(height: 1)
        }
    }
}

#Preview {
    BottomNavBar(selected: .constant(.race))
        .background(HYFITTheme.background)
}
