//
//  HYFITTheme.swift
//  HYFIT
//

import SwiftUI

enum HYFITTheme {
    static let background = Color(red: 0.02, green: 0.02, blue: 0.02)
    static let surface = Color(red: 0.10, green: 0.10, blue: 0.10)
    static let surfaceSecondary = Color(red: 0.14, green: 0.14, blue: 0.14)
    static let border = Color.white.opacity(0.14)
    static let borderStrong = Color.white.opacity(0.22)
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.55)
    static let tertiaryText = Color.white.opacity(0.35)
    static let lime = Color(red: 0.820, green: 1.0, blue: 0.0) // #D1FF00
    static let limeMuted = Color(red: 0.820, green: 1.0, blue: 0.0).opacity(0.18)
    static let onLime = Color.black
    static let danger = Color(red: 1.0, green: 0.32, blue: 0.28)

    static let cornerRadius: CGFloat = 14
    static let cornerRadiusSmall: CGFloat = 10
    static let borderWidth: CGFloat = 1
    static let horizontalPadding: CGFloat = 20
}

enum HYFITTypography {
    /// Condensed heavy display — swap family later when a custom athletic font ships.
    static func condensed(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .default)
            .width(.condensed)
    }

    static let display = condensed(size: 52, weight: .heavy)
    static let displayLarge = condensed(size: 64, weight: .heavy)
    static let title = condensed(size: 34, weight: .heavy)
    static let heading = condensed(size: 22, weight: .bold)
    static let label = condensed(size: 12, weight: .semibold)
    static let metric = condensed(size: 48, weight: .heavy)
    static let metricLarge = condensed(size: 56, weight: .heavy)
    static let metricHuge = condensed(size: 72, weight: .heavy)
    static let body = Font.system(size: 15, weight: .regular, design: .default)
    static let bodyEmphasized = Font.system(size: 15, weight: .semibold, design: .default)
    static let button = condensed(size: 17, weight: .heavy)
    static let caption = Font.system(size: 13, weight: .medium, design: .default)
    static let timer = condensed(size: 44, weight: .bold)
    static let timerLarge = condensed(size: 56, weight: .heavy)
}

struct HYFITDisplay: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(HYFITTypography.display)
            .foregroundStyle(HYFITTheme.primaryText)
            .textCase(.uppercase)
            .tracking(-0.5)
    }
}

struct HYFITTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(HYFITTypography.title)
            .foregroundStyle(HYFITTheme.primaryText)
            .textCase(.uppercase)
            .tracking(-0.3)
    }
}

struct HYFITHeading: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(HYFITTypography.heading)
            .foregroundStyle(HYFITTheme.primaryText)
            .textCase(.uppercase)
    }
}

struct HYFITLabel: ViewModifier {
    var color: Color = HYFITTheme.secondaryText

    func body(content: Content) -> some View {
        content
            .font(HYFITTypography.label)
            .foregroundStyle(color)
            .textCase(.uppercase)
            .tracking(1.2)
    }
}

struct HYFITMetric: ViewModifier {
    var size: Font = HYFITTypography.metric

    func body(content: Content) -> some View {
        content
            .font(size)
            .foregroundStyle(HYFITTheme.primaryText)
            .monospacedDigit()
    }
}

struct HYFITBody: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(HYFITTypography.body)
            .foregroundStyle(HYFITTheme.secondaryText)
    }
}

struct HYFITButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(HYFITTypography.button)
            .textCase(.uppercase)
            .tracking(0.6)
    }
}

extension View {
    func hyfitDisplay() -> some View { modifier(HYFITDisplay()) }
    func hyfitTitle() -> some View { modifier(HYFITTitle()) }
    func hyfitHeading() -> some View { modifier(HYFITHeading()) }
    func hyfitLabel(_ color: Color = HYFITTheme.secondaryText) -> some View {
        modifier(HYFITLabel(color: color))
    }
    func hyfitMetric(_ size: Font = HYFITTypography.metric) -> some View {
        modifier(HYFITMetric(size: size))
    }
    func hyfitBody() -> some View { modifier(HYFITBody()) }
    func hyfitButton() -> some View { modifier(HYFITButtonStyle()) }
}
