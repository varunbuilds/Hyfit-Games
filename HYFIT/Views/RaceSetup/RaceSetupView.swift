//
//  RaceSetupView.swift
//  HYFIT
//

import SwiftUI

struct RaceSetupView: View {
    @Binding var configuration: RaceSetupConfiguration
    let onContinue: () -> Void
    let onBack: () -> Void

    var body: some View {
        ZStack {
            HYFITTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    raceTypeSection
                    categorySection
                    teamSection
                    distanceModeSection
                }
                .padding(.horizontal, HYFITTheme.horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, 120)
            }
            .scrollDismissesKeyboard(.interactively)

            VStack {
                Spacer()
                HYFITPrimaryButton(title: "CONTINUE", action: continueTapped)
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.bottom, 24)
                    .padding(.top, 12)
                    .background(HYFITTheme.background)
            }
        }
        .navigationTitle("Race Setup")
        .navigationBarTitleDisplayMode(.large)
        .animation(HYFITTheme.quickSpring, value: configuration.category)
    }

    // MARK: - Selectors

    private var raceTypeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("RACE TYPE")
                .hyfitLabel(HYFITTheme.tertiaryText)
                .padding(.leading, 4)

            HStack(spacing: 8) {
                ForEach(RaceGroup.allCases, id: \.self) { group in
                    raceTypeButton(group)
                }
            }
        }
    }

    private func raceTypeButton(_ group: RaceGroup) -> some View {
        let selected = configuration.category.group == group
        return Button {
            guard !selected, let first = group.categories.first else { return }
            withAnimation(HYFITTheme.quickSpring) {
                configuration.category = first
            }
        } label: {
            Text(group.displayName)
                .font(HYFITTypography.sora(size: 12, weight: .semibold))
                .foregroundStyle(selected ? HYFITTheme.onLime : HYFITTheme.primaryText)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: 48)
                .padding(.horizontal, 4)
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

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CATEGORY")
                .hyfitLabel(HYFITTheme.tertiaryText)
                .padding(.leading, 4)

            VStack(spacing: 8) {
                ForEach(configuration.category.group.categories, id: \.self) { category in
                    categoryRow(category)
                }
            }
        }
        .padding(.top, 8)
    }

    private func categoryRow(_ category: RaceCategory) -> some View {
        let selected = configuration.category == category
        return Button {
            configuration.category = category
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.title)
                        .font(HYFITTypography.sora(size: 16, weight: .semibold))
                        .foregroundStyle(HYFITTheme.primaryText)
                    Text(category.ageLabel)
                        .font(HYFITTypography.caption)
                        .foregroundStyle(HYFITTheme.secondaryText)
                }
                Spacer(minLength: 8)
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(selected ? HYFITTheme.lime : HYFITTheme.tertiaryText)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(HYFITTheme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous)
                    .stroke(selected ? HYFITTheme.lime : HYFITTheme.border, lineWidth: HYFITTheme.borderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var teamSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(configuration.category.isTeam ? "TEAM" : "ATHLETE")
                .hyfitLabel(HYFITTheme.tertiaryText)
                .padding(.leading, 4)

            VStack(spacing: 8) {
                nameField(
                    icon: "person.fill",
                    label: configuration.you.role.capitalized,
                    text: $configuration.you.name,
                    placeholder: "Your name"
                )

                if configuration.category.isTeam {
                    nameField(
                        icon: "person.2.fill",
                        label: configuration.partner.role.capitalized,
                        text: $configuration.partner.name,
                        placeholder: "Partner name"
                    )
                }
            }
        }
        .padding(.top, 8)
    }

    private func nameField(icon: String, label: String, text: Binding<String>, placeholder: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(HYFITTheme.lime)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(HYFITTypography.caption)
                    .foregroundStyle(HYFITTheme.secondaryText)
                TextField(placeholder, text: text)
                    .font(HYFITTypography.sora(size: 16, weight: .semibold))
                    .foregroundStyle(HYFITTheme.primaryText)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
            }

            Image(systemName: "pencil")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(HYFITTheme.tertiaryText)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HYFITTheme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous)
                .stroke(HYFITTheme.border, lineWidth: HYFITTheme.borderWidth)
        )
        .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous))
    }

    /// Trims names and falls back to sensible defaults if left empty.
    private func continueTapped() {
        let you = configuration.you.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let partner = configuration.partner.name.trimmingCharacters(in: .whitespacesAndNewlines)
        configuration.you.name = you.isEmpty ? AthleteProfile.default.athleteName : you
        configuration.partner.name = partner.isEmpty ? AthleteProfile.default.partnerName : partner
        onContinue()
    }

    private var distanceModeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DISTANCE MODE")
                .hyfitLabel(HYFITTheme.tertiaryText)
                .padding(.leading, 4)

            VStack(spacing: 8) {
                ForEach(DistanceTrackingMode.allCases, id: \.self) { mode in
                    distanceModeRow(mode)
                }
            }
        }
        .padding(.top, 8)
    }

    private func distanceModeRow(_ mode: DistanceTrackingMode) -> some View {
        let selected = configuration.distanceTrackingMode == mode
        let title: String
        let subtitle: String
        let icon: String
        switch mode {
        case .simulated:
            title = "Simulator"; subtitle = "Simulated distance, no GPS needed"; icon = "gauge.with.dots.needle.67percent"
        case .gps:
            title = "GPS"; subtitle = "Track real distance outdoors"; icon = "location.fill"
        }
        return Button {
            configuration.distanceTrackingMode = mode
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(HYFITTheme.lime)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(HYFITTypography.sora(size: 16, weight: .semibold))
                        .foregroundStyle(HYFITTheme.primaryText)
                    Text(subtitle)
                        .font(HYFITTypography.caption)
                        .foregroundStyle(HYFITTheme.secondaryText)
                }
                Spacer(minLength: 8)
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(selected ? HYFITTheme.lime : HYFITTheme.tertiaryText)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(HYFITTheme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous)
                    .stroke(selected ? HYFITTheme.lime : HYFITTheme.border, lineWidth: HYFITTheme.borderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Distance mode \(title)")
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

#Preview {
    RaceSetupView(
        configuration: .constant(.maleDoublesPlaceholder),
        onContinue: {},
        onBack: {}
    )
}
