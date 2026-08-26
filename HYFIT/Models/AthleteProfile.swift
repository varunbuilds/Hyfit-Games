//
//  AthleteProfile.swift
//  HYFIT
//
//  Local athlete preferences. Not part of RaceResult.
//

import Foundation

/// Local profile defaults for Race Setup. Immutable completed races are unaffected.
nonisolated struct AthleteProfile: Hashable, Sendable, Codable {
    var athleteName: String
    var category: RaceCategory
    var mode: RaceMode
    var partnerName: String
    var distanceTrackingMode: DistanceTrackingMode

    /// First-launch placeholder — not a fabricated personal identity.
    static let `default` = AthleteProfile(
        athleteName: "ATHLETE",
        category: .maleDoubles,
        mode: .competitionSimulation,
        partnerName: "PARTNER",
        distanceTrackingMode: .simulated
    )

    var displayName: String {
        let trimmed = athleteName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? Self.default.athleteName : trimmed
    }

    var displayPartnerName: String {
        let trimmed = partnerName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? Self.default.partnerName : trimmed
    }

    var initials: String {
        let parts = displayName.split(separator: " ").filter { !$0.isEmpty }
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(displayName.prefix(2)).uppercased()
    }

    func asRaceSetupConfiguration() -> RaceSetupConfiguration {
        RaceSetupConfiguration(
            category: category,
            mode: mode,
            you: TeamMember(id: "you", role: "YOU", name: displayName),
            partner: TeamMember(id: "partner", role: "PARTNER", name: displayPartnerName),
            distanceTrackingMode: distanceTrackingMode
        )
    }

    static func from(_ setup: RaceSetupConfiguration) -> AthleteProfile {
        AthleteProfile(
            athleteName: setup.you.name,
            category: setup.category,
            mode: setup.mode,
            partnerName: setup.partner.name,
            distanceTrackingMode: setup.distanceTrackingMode
        )
    }
}

/// UserDefaults-backed profile store. Separate from SwiftData RaceResult persistence.
@MainActor
enum AthleteProfileStore {
    private static let storageKey = "hyfit.athleteProfile.v1"

    static var hasSavedProfile: Bool {
        UserDefaults.standard.data(forKey: storageKey) != nil
    }

    static func load() -> AthleteProfile {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let profile = try? JSONDecoder().decode(AthleteProfile.self, from: data) else {
            return .default
        }
        return profile
    }

    static func save(_ profile: AthleteProfile) {
        var normalized = profile
        normalized.athleteName = profile.displayName
        normalized.partnerName = profile.displayPartnerName
        guard let data = try? JSONEncoder().encode(normalized) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
