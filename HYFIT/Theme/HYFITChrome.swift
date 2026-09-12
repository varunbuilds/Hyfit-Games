//
//  HYFITChrome.swift
//  HYFIT
//

import SwiftUI

// MARK: - Screen chrome

struct HYFITScreenBackground: View {
    var body: some View {
        ZStack {
            HYFITTheme.background

            RadialGradient(
                colors: [
                    HYFITTheme.lime.opacity(0.07),
                    HYFITTheme.background.opacity(0)
                ],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 420
            )

            RadialGradient(
                colors: [
                    Color.white.opacity(0.03),
                    HYFITTheme.background.opacity(0)
                ],
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 360
            )
        }
    }
}

struct HYFITFloatingBarBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: HYFITTheme.cornerRadiusLarge, style: .continuous)
            .fill(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: HYFITTheme.cornerRadiusLarge, style: .continuous)
                    .fill(HYFITTheme.surfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: HYFITTheme.cornerRadiusLarge, style: .continuous)
                    .stroke(HYFITTheme.border, lineWidth: HYFITTheme.borderWidth)
            )
    }
}

struct HYFITBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(HYFITTheme.primaryText)
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(
                    Circle()
                        .stroke(HYFITTheme.border, lineWidth: HYFITTheme.borderWidth)
                )
        }
        .buttonStyle(HYFITPressableStyle(scale: 0.94))
        .accessibilityLabel("Back")
    }
}

// MARK: - Interaction

struct HYFITPressableStyle: ButtonStyle {
    var scale: CGFloat = 0.97

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(HYFITTheme.quickSpring, value: configuration.isPressed)
    }
}

// MARK: - View extensions

extension View {
    func hyfitScreenBackground() -> some View {
        background {
            HYFITScreenBackground()
                .ignoresSafeArea()
        }
    }

    func hyfitCardSurface(accentBorder: Bool = false) -> some View {
        background(
            RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous)
                .fill(HYFITTheme.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous)
                .stroke(
                    accentBorder ? HYFITTheme.lime.opacity(0.55) : HYFITTheme.border,
                    lineWidth: accentBorder ? 1 : HYFITTheme.borderWidth
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 12, y: 6)
    }

    func hyfitInsetSurface(cornerRadius: CGFloat = HYFITTheme.cornerRadiusSmall) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(HYFITTheme.surfaceSecondary.opacity(0.65))
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(HYFITTheme.border, lineWidth: HYFITTheme.borderWidth)
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
