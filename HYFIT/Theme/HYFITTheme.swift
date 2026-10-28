//
//  HYFITTheme.swift
//  HYFIT
//

import SwiftUI

enum HYFITTheme {
    static let background = Color(red: 0.02, green: 0.02, blue: 0.02)
    static let surface = Color(red: 0.10, green: 0.10, blue: 0.10)
    static let surfaceSecondary = Color(red: 0.14, green: 0.14, blue: 0.14)
    /// Slightly lifted surface for floating chrome (bars, sheets).
    static let surfaceElevated = Color(red: 0.16, green: 0.16, blue: 0.16)
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
    static let cornerRadiusLarge: CGFloat = 22
    static let borderWidth: CGFloat = 1
    static let horizontalPadding: CGFloat = 20

    static let quickSpring = Animation.spring(response: 0.32, dampingFraction: 0.82)
}

enum HYFITTypography {
    /// Sora weights bundled with the app. PostScript names verified from the .ttf metadata.
    enum Weight: String {
        case regular = "Sora-Regular"
        case medium = "Sora-Medium"
        case semibold = "Sora-SemiBold"
        case bold = "Sora-Bold"
    }

    /// Sora at a fixed point size (matches the previous fixed-size system fonts).
    static func sora(size: CGFloat, weight: Weight = .regular) -> Font {
        .custom(weight.rawValue, fixedSize: size)
    }

    /// UIKit counterpart for system-drawn text (nav bar, tab bar, segmented control).
    static func uiFont(size: CGFloat, weight: Weight = .regular) -> UIFont {
        UIFont(name: weight.rawValue, size: size) ?? .systemFont(ofSize: size)
    }

    /// Applies Sora to UIKit-rendered chrome text.
    static func configureUIKitAppearance() {
        let nav = UINavigationBarAppearance()
        nav.configureWithTransparentBackground()
        nav.titleTextAttributes = [.font: uiFont(size: 17, weight: .semibold)]
        nav.largeTitleTextAttributes = [.font: uiFont(size: 34, weight: .bold)]
        nav.backButtonAppearance.normal.titleTextAttributes = [.font: uiFont(size: 17, weight: .medium)]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav

        UITabBarItem.appearance().setTitleTextAttributes([.font: uiFont(size: 10, weight: .medium)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([.font: uiFont(size: 10, weight: .semibold)], for: .selected)

        UISegmentedControl.appearance().setTitleTextAttributes([.font: uiFont(size: 13, weight: .medium)], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([.font: uiFont(size: 13, weight: .semibold)], for: .selected)
    }

    // Display / titles / numbers: Bold. Section headings, buttons, labels: SemiBold.
    // Body and captions: Regular. Emphasized body: SemiBold.
    static let display = sora(size: 52, weight: .bold)
    static let displayLarge = sora(size: 64, weight: .bold)
    static let title = sora(size: 34, weight: .bold)
    static let heading = sora(size: 22, weight: .semibold)
    static let label = sora(size: 12, weight: .semibold)
    static let metric = sora(size: 48, weight: .bold)
    static let metricLarge = sora(size: 56, weight: .bold)
    static let metricHuge = sora(size: 72, weight: .bold)
    static let body = sora(size: 15, weight: .regular)
    static let bodyEmphasized = sora(size: 15, weight: .semibold)
    static let button = sora(size: 17, weight: .semibold)
    static let caption = sora(size: 13, weight: .regular)
    static let timer = sora(size: 44, weight: .bold)
    static let timerLarge = sora(size: 56, weight: .bold)
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
