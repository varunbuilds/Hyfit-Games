//
//  ProfileView.swift
//  HYFIT
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    let results: [RaceResult]
    let onProfileSaved: (AthleteProfile) -> Void
    let onOpenStats: () -> Void
    let onRefreshResults: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var profile: AthleteProfile = .default
    @State private var draft: AthleteProfile = .default
    @State private var isEditing = false
    @State private var hasSavedProfile = false
    @State private var photoItem: PhotosPickerItem?

    private var summary: StatsSummary {
        StatsCalculator.summarize(results)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header

                if isEditing {
                    editSection
                } else {
                    overviewSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(HYFITPremiumBackground())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    if isEditing { saveDraft() }
                    dismiss()
                }
                .accessibilityLabel("Done")
            }
        }
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    draft.avatarData = Self.avatarJPEG(from: image)
                }
                photoItem = nil
            }
        }
        .onChange(of: draft) { _, _ in
            // Autosave every edit (name / photo) as it happens.
            if isEditing && draft != profile { saveDraft() }
        }
        .onDisappear {
            if isEditing { saveDraft() }
        }
        .onAppear {
            reloadProfile()
            onRefreshResults()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 14) {
            avatar
                .shadow(color: .black.opacity(0.35), radius: 12, y: 6)

            Text(displayProfile.displayName)
                .font(HYFITTypography.sora(size: 28, weight: .bold))
                .foregroundStyle(HYFITTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Button {
                if isEditing {
                    isEditing = false
                } else {
                    draft = profile
                    isEditing = true
                }
            } label: {
                Text(isEditing ? "Done" : "Edit Profile")
                    .font(HYFITTypography.sora(size: 13, weight: .semibold))
                    .foregroundStyle(isEditing ? HYFITTheme.onLime : HYFITTheme.primaryText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        isEditing ? HYFITTheme.lime : Color.white.opacity(0.14),
                        in: Capsule()
                    )
            }
            .buttonStyle(.plain)

            if !isEditing && !hasSavedProfile {
                Text("Configure your profile for future races.")
                    .font(HYFITTypography.caption)
                    .foregroundStyle(HYFITTheme.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var displayProfile: AthleteProfile {
        isEditing ? draft : profile
    }

    // MARK: - Avatar

    @ViewBuilder
    private var avatar: some View {
        if let data = displayProfile.avatarData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 104, height: 104)
                .clipShape(Circle())
        } else {
            Text(displayProfile.initials)
                .font(HYFITTypography.sora(size: 44, weight: .semibold))
                .foregroundStyle(HYFITTheme.onLime)
                .frame(width: 104, height: 104)
                .background(
                    LinearGradient(
                        colors: [HYFITTheme.lime, Color(red: 0.55, green: 0.80, blue: 0.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    in: Circle()
                )
        }
    }

    /// Center-crops to a square and downsizes so the profile stays small in UserDefaults.
    private static func avatarJPEG(from image: UIImage) -> Data? {
        let side = min(image.size.width, image.size.height)
        guard side > 0 else { return nil }
        let target = CGSize(width: 256, height: 256)
        let scale = target.width / side
        let drawSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let rendered = UIGraphicsImageRenderer(size: target, format: format).image { _ in
            image.draw(in: CGRect(
                x: (target.width - drawSize.width) / 2,
                y: (target.height - drawSize.height) / 2,
                width: drawSize.width,
                height: drawSize.height
            ))
        }
        return rendered.jpegData(compressionQuality: 0.8)
    }

    // MARK: - Edit

    private var editSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Edit Profile")

            card {
                editField(icon: "person.fill", title: "Name", text: $draft.athleteName)
            }

            card {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    row(icon: "photo.fill", title: "Change Photo", subtitle: "Choose from your library", showsChevron: true)
                }
                .buttonStyle(.plain)

                if draft.avatarData != nil {
                    divider
                    Button {
                        draft.avatarData = nil
                    } label: {
                        row(icon: "trash.fill", title: "Remove Photo", subtitle: "Show initials instead")
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Overview

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Overview")

            if summary.isEmpty {
                card {
                    row(icon: "flag.checkered", title: "No race data yet", subtitle: "Complete a race to see stats")
                }
            } else {
                card {
                    row(icon: "flag.checkered", title: "Races Completed", subtitle: "\(summary.raceCount)")
                    divider
                    row(
                        icon: "stopwatch.fill",
                        title: "Best Time",
                        subtitle: summary.bestAdjustedFinishTime.map { TimeFormatting.raceClock($0) } ?? "—"
                    )
                }
                card {
                    row(
                        icon: "bolt.fill",
                        title: "Best 200 M",
                        subtitle: summary.personalBests.map { TimeFormatting.paddedRaceClock($0.fastest200m) } ?? "—"
                    )
                    divider
                    row(
                        icon: "brain.head.profile",
                        title: "Best Recall",
                        subtitle: summary.personalBests.map {
                            "\($0.bestRecallCorrect) / \($0.recallSequenceLength)"
                        } ?? "—"
                    )
                }
            }

            Button(action: onOpenStats) {
                card {
                    row(icon: "chart.bar.fill", title: "View Stats", subtitle: "Full performance history", showsChevron: true)
                }
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Building blocks

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(HYFITTypography.heading)
            .foregroundStyle(HYFITTheme.primaryText)
            .padding(.horizontal, 4)
    }

    private var divider: some View {
        Divider()
            .overlay(Color.white.opacity(0.08))
            .padding(.leading, 64)
    }

    private func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
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

    private func icon(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 20, weight: .regular))
            .foregroundStyle(HYFITTheme.lime)
            .frame(width: 32)
    }

    private func row(icon name: String, title: String, subtitle: String, showsChevron: Bool = false) -> some View {
        HStack(spacing: 16) {
            icon(name)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(HYFITTypography.sora(size: 16, weight: .semibold))
                    .foregroundStyle(HYFITTheme.primaryText)
                Text(subtitle)
                    .font(HYFITTypography.caption)
                    .foregroundStyle(HYFITTheme.secondaryText)
                    .lineLimit(2)
            }
            Spacer(minLength: 8)
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(HYFITTheme.tertiaryText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }

    private func editField(icon name: String, title: String, text: Binding<String>) -> some View {
        HStack(spacing: 16) {
            icon(name)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(HYFITTypography.caption)
                    .foregroundStyle(HYFITTheme.secondaryText)
                TextField(title, text: text)
                    .font(HYFITTypography.sora(size: 16, weight: .semibold))
                    .foregroundStyle(HYFITTheme.primaryText)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
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
