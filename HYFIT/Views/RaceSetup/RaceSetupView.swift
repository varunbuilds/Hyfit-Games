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
                    modeField
                    distanceModeSection
                }
                .padding(.horizontal, HYFITTheme.horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, 120)
            }

            VStack {
                Spacer()
                HYFITPrimaryButton(title: "CONTINUE", action: onContinue)
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.bottom, 24)
                    .padding(.top, 12)
                    .background(HYFITTheme.background)
            }
        }
        .navigationTitle("Race Setup")
        .navigationBarTitleDisplayMode(.large)
        .toolbar(.hidden, for: .tabBar)
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

            HYFITFieldRow(
                label: configuration.you.role,
                value: configuration.you.name,
                showsEdit: true
            )

            if configuration.category.isTeam {
                HYFITFieldRow(
                    label: configuration.partner.role,
                    value: configuration.partner.name,
                    showsEdit: true
                )
            }
        }
        .padding(.top, 8)
    }

    private var modeField: some View {
        HYFITFieldRow(
            label: "RACE MODE",
            value: configuration.mode.displayName,
            showsChevron: true
        )
        .padding(.top, 8)
    }

    private var distanceModeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DISTANCE MODE")
                .hyfitLabel(HYFITTheme.tertiaryText)
                .padding(.leading, 4)

            HStack(spacing: 10) {
                ForEach(DistanceTrackingMode.allCases, id: \.self) { mode in
                    distanceModeButton(mode)
                }
            }
        }
        .padding(.top, 8)
    }

    private func distanceModeButton(_ mode: DistanceTrackingMode) -> some View {
        let selected = configuration.distanceTrackingMode == mode
        return Button {
            configuration.distanceTrackingMode = mode
        } label: {
            Text(mode.displayName)
                .font(HYFITTypography.heading)
                .foregroundStyle(selected ? HYFITTheme.onLime : HYFITTheme.primaryText)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(selected ? HYFITTheme.lime : HYFITTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous)
                        .stroke(
                            selected ? HYFITTheme.lime : HYFITTheme.border,
                            lineWidth: HYFITTheme.borderWidth
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Distance mode \(mode.displayName)")
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
