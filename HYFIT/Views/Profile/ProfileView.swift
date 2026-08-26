//
//  ProfileView.swift
//  HYFIT
//

import SwiftUI

struct ProfileView: View {
    let results: [RaceResult]
    let onProfileSaved: (AthleteProfile) -> Void
    let onOpenStats: () -> Void
    let onRefreshResults: () -> Void

    @State private var profile: AthleteProfile = .default
    @State private var draft: AthleteProfile = .default
    @State private var isEditing = false
    @State private var hasSavedProfile = false

    private var summary: StatsSummary {
        StatsCalculator.summarize(results)
    }

    var body: some View {
        ZStack {
            HYFITTheme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        athleteCard

                        if isEditing {
                            editSection
                            racePreferencesSection(editable: true)
                        } else {
                            infoSection
                            racePreferencesSection(editable: false)
                            performanceSnapshot
                        }
                    }
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.bottom, 120)
                }
            }

            VStack {
                Spacer()
                bottomActions
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.bottom, 24)
                    .padding(.top, 12)
                    .background(HYFITTheme.background)
            }
        }
        .onAppear {
            reloadProfile()
            onRefreshResults()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PROFILE")
                .hyfitTitle()
            Text("ATHLETE")
                .hyfitLabel(HYFITTheme.lime)
            if !hasSavedProfile && !isEditing {
                Text("Configure your profile for future races.")
                    .font(HYFITTypography.caption)
                    .foregroundStyle(HYFITTheme.secondaryText)
                    .padding(.top, 2)
            }
        }
    }

    // MARK: - Athlete card

    private var athleteCard: some View {
        HYFITBorderedCard(padding: 16) {
            HStack(alignment: .center, spacing: 16) {
                Text(displayProfile.initials)
                    .font(HYFITTypography.heading)
                    .foregroundStyle(HYFITTheme.onLime)
                    .frame(width: 56, height: 56)
                    .background(HYFITTheme.lime)
                    .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadiusSmall, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(displayProfile.displayName)
                        .font(HYFITTypography.heading)
                        .foregroundStyle(HYFITTheme.primaryText)
                        .textCase(.uppercase)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(displayProfile.category.displayName)
                        .hyfitLabel(HYFITTheme.lime)

                    Text("TEAM · \(displayProfile.displayPartnerName)")
                        .font(HYFITTypography.caption)
                        .foregroundStyle(HYFITTheme.secondaryText)
                        .textCase(.uppercase)

                    Text(displayProfile.mode.displayName)
                        .font(HYFITTypography.caption)
                        .foregroundStyle(HYFITTheme.tertiaryText)
                        .textCase(.uppercase)
                }

                Spacer(minLength: 0)
            }
        }
    }

    private var displayProfile: AthleteProfile {
        isEditing ? draft : profile
    }

    // MARK: - Info (read-only)

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("PROFILE")

            infoRow(label: "NAME", value: profile.displayName)
            infoRow(label: "CATEGORY", value: profile.category.displayName)
            infoRow(label: "TEAM / PARTNER", value: profile.displayPartnerName)
            infoRow(label: "RACE MODE", value: profile.mode.displayName)
        }
    }

    // MARK: - Edit

    private var editSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("EDIT PROFILE")

            profileTextField(label: "NAME", text: $draft.athleteName)

            VStack(alignment: .leading, spacing: 8) {
                Text("CATEGORY")
                    .hyfitLabel(HYFITTheme.tertiaryText)
                Picker("CATEGORY", selection: $draft.category) {
                    ForEach(RaceCategory.allCases, id: \.self) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            profileTextField(label: "TEAM / PARTNER", text: $draft.partnerName)

            VStack(alignment: .leading, spacing: 8) {
                Text("RACE MODE")
                    .hyfitLabel(HYFITTheme.tertiaryText)
                Picker("RACE MODE", selection: $draft.mode) {
                    ForEach(RaceMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
        }
    }

    // MARK: - Distance mode

    private func racePreferencesSection(editable: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("RACE PREFERENCES")

            Text("DISTANCE MODE")
                .hyfitLabel(HYFITTheme.tertiaryText)

            HStack(spacing: 10) {
                ForEach(DistanceTrackingMode.allCases, id: \.self) { mode in
                    distanceModeButton(mode, editable: editable)
                }
            }

            Text("Applies to future races. Active races are unchanged.")
                .font(HYFITTypography.caption)
                .foregroundStyle(HYFITTheme.tertiaryText)
        }
    }

    private func distanceModeButton(_ mode: DistanceTrackingMode, editable: Bool) -> some View {
        let selected = (isEditing ? draft : profile).distanceTrackingMode == mode
        return Button {
            guard editable, isEditing else { return }
            draft.distanceTrackingMode = mode
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
                .opacity(editable || selected ? 1 : 0.55)
        }
        .buttonStyle(.plain)
        .disabled(!editable || !isEditing)
        .accessibilityLabel("Distance mode \(mode.displayName)")
    }

    // MARK: - Snapshot

    private var performanceSnapshot: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionTitle("PERFORMANCE SNAPSHOT")
                Spacer()
                Button(action: onOpenStats) {
                    Text("VIEW STATS")
                        .hyfitLabel(HYFITTheme.lime)
                }
                .buttonStyle(.plain)
            }

            if summary.isEmpty {
                HYFITBorderedCard(padding: 16) {
                    Text("NO RACE DATA YET")
                        .font(HYFITTypography.bodyEmphasized)
                        .foregroundStyle(HYFITTheme.secondaryText)
                }
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    snapshotCell("RACES COMPLETED", "\(summary.raceCount)")
                    snapshotCell(
                        "BEST TIME",
                        summary.bestAdjustedFinishTime.map { TimeFormatting.raceClock($0) } ?? "—"
                    )
                    snapshotCell(
                        "BEST 200 M",
                        summary.personalBests.map { TimeFormatting.paddedRaceClock($0.fastest200m) } ?? "—"
                    )
                    snapshotCell(
                        "BEST RECALL",
                        summary.personalBests.map {
                            "\($0.bestRecallCorrect) / \($0.recallSequenceLength)"
                        } ?? "—"
                    )
                }
            }
        }
    }

    // MARK: - Actions

    private var bottomActions: some View {
        Group {
            if isEditing {
                HYFITPrimaryButton(title: "SAVE", action: saveDraft)
            } else {
                HYFITPrimaryButton(title: "EDIT PROFILE") {
                    draft = profile
                    isEditing = true
                }
            }
        }
    }

    // MARK: - Helpers

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .hyfitLabel(HYFITTheme.lime)
    }

    private func infoRow(label: String, value: String) -> some View {
        HYFITBorderedCard(padding: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(label)
                    .hyfitLabel(HYFITTheme.tertiaryText)
                Text(value)
                    .font(HYFITTypography.heading)
                    .foregroundStyle(HYFITTheme.primaryText)
                    .textCase(.uppercase)
                    .minimumScaleFactor(0.7)
                    .lineLimit(2)
            }
        }
    }

    private func profileTextField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .hyfitLabel(HYFITTheme.tertiaryText)
            TextField("", text: text)
                .font(HYFITTypography.heading)
                .foregroundStyle(HYFITTheme.primaryText)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(HYFITTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous)
                        .stroke(HYFITTheme.border, lineWidth: HYFITTheme.borderWidth)
                )
                .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous))
        }
    }

    private func snapshotCell(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .hyfitLabel(HYFITTheme.tertiaryText)
            Text(value)
                .font(HYFITTypography.heading)
                .foregroundStyle(HYFITTheme.primaryText)
                .monospacedDigit()
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HYFITTheme.surface)
        .overlay(
            RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous)
                .stroke(HYFITTheme.border, lineWidth: HYFITTheme.borderWidth)
        )
        .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous))
    }

    private func reloadProfile() {
        hasSavedProfile = AthleteProfileStore.hasSavedProfile
        profile = AthleteProfileStore.load()
        if !isEditing {
            draft = profile
        }
    }

    private func saveDraft() {
        AthleteProfileStore.save(draft)
        profile = AthleteProfileStore.load()
        hasSavedProfile = true
        isEditing = false
        onProfileSaved(profile)
    }
}

#Preview {
    ProfileView(
        results: [],
        onProfileSaved: { _ in },
        onOpenStats: {},
        onRefreshResults: {}
    )
}
