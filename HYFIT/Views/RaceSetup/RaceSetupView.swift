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

            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 28)

                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        categoryField
                        teamSection
                        modeField
                        distanceModeSection
                    }
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.bottom, 120)
                }

                Spacer(minLength: 0)
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
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        HStack(spacing: 14) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(HYFITTheme.primaryText)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)

            Text("RACE SETUP")
                .hyfitTitle()

            Spacer()
        }
    }

    private var categoryField: some View {
        // Extensible: swap for a picker when more categories ship.
        HYFITFieldRow(
            label: "CATEGORY",
            value: configuration.category.displayName,
            showsChevron: true
        )
    }

    private var teamSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TEAM")
                .hyfitLabel(HYFITTheme.tertiaryText)
                .padding(.leading, 4)

            HYFITFieldRow(
                label: configuration.you.role,
                value: configuration.you.name,
                showsEdit: true
            )

            HYFITFieldRow(
                label: configuration.partner.role,
                value: configuration.partner.name,
                showsEdit: true
            )
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
