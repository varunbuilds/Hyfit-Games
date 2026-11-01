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

/// Dark graphite gradient with soft glows and fine film grain (Apple-style premium backdrop).
struct HYFITPremiumBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.200, green: 0.250, blue: 0.075),
                    Color(red: 0.075, green: 0.095, blue: 0.045),
                    Color(red: 0.035, green: 0.040, blue: 0.035)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [HYFITTheme.lime.opacity(0.08), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 380
            )

            RadialGradient(
                colors: [Color.white.opacity(0.06), .clear],
                center: .top,
                startRadius: 0,
                endRadius: 460
            )

            HYFITGrain()
        }
        .ignoresSafeArea()
    }
}

/// Static, deterministic film grain rendered once into a Canvas.
private struct HYFITGrain: View {
    var body: some View {
        Canvas { context, size in
            var generator = SeededGenerator(seed: 0x4859_4649_54)
            let count = Int(size.width * size.height / 14)
            for _ in 0..<count {
                let x = CGFloat.random(in: 0..<size.width, using: &generator)
                let y = CGFloat.random(in: 0..<size.height, using: &generator)
                let light = Bool.random(using: &generator)
                let alpha = Double.random(in: 0.02...0.07, using: &generator)
                context.fill(
                    Path(CGRect(x: x, y: y, width: 1, height: 1)),
                    with: .color((light ? Color.white : Color.black).opacity(alpha))
                )
            }
        }
        .drawingGroup()
        .allowsHitTesting(false)
    }
}

private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_33EB
        return z ^ (z >> 31)
    }
}

// MARK: - Grouped card components (shared by History / Stats)

/// Large section heading used above grouped cards.
struct HYFITSectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(HYFITTypography.heading)
                .foregroundStyle(HYFITTheme.primaryText)
            if let subtitle {
                Text(subtitle)
                    .font(HYFITTypography.caption)
                    .foregroundStyle(HYFITTheme.secondaryText)
            }
        }
        .padding(.horizontal, 4)
    }
}

/// Rounded translucent container, matching the Profile cards.
struct HYFITGroupCard<Content: View>: View {
    var padding: CGFloat = 0
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.10), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct HYFITCardDivider: View {
    var inset: CGFloat = 20

    var body: some View {
        Divider()
            .overlay(Color.white.opacity(0.08))
            .padding(.leading, inset)
    }
}

/// Native-style empty state: symbol, title, explanation and an optional action.
struct HYFITEmptyState: View {
    let symbol: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: symbol)
                .font(.system(size: 44, weight: .regular))
                .foregroundStyle(HYFITTheme.lime)
                .padding(.bottom, 4)
            Text(title)
                .font(HYFITTypography.heading)
                .foregroundStyle(HYFITTheme.primaryText)
            Text(message)
                .font(HYFITTypography.body)
                .foregroundStyle(HYFITTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(HYFITTypography.sora(size: 15, weight: .semibold))
                        .foregroundStyle(HYFITTheme.onLime)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(HYFITTheme.lime, in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity)
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

struct HYFITProfileToolbarButton: View {
    let action: () -> Void

    /// Observes the saved profile so the avatar updates as soon as it is edited.
    @AppStorage(AthleteProfileStore.storageKey) private var profileData: Data?

    private var profile: AthleteProfile? {
        guard let profileData else { return nil }
        return try? JSONDecoder().decode(AthleteProfile.self, from: profileData)
    }

    var body: some View {
        Button(action: action) {
            avatar
                .frame(width: 34, height: 34)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Profile")
    }

    @ViewBuilder
    private var avatar: some View {
        if let profile, let data = profile.avatarData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
        } else if let profile {
            Text(profile.initials)
                .font(HYFITTypography.sora(size: 13, weight: .semibold))
                .foregroundStyle(HYFITTheme.onLime)
                .frame(width: 34, height: 34)
                .background(HYFITTheme.lime, in: Circle())
        } else {
            Image(systemName: "person.crop.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(HYFITTheme.lime)
        }
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

    func hyfitPageHeader(title: String, onOpenProfile: @escaping () -> Void) -> some View {
        self
            .navigationTitle(title)
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HYFITProfileToolbarButton(action: onOpenProfile)
                }
            }
    }
}
