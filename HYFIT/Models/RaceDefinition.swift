//
//  RaceDefinition.swift
//  HYFIT
//

import Foundation

nonisolated enum RaceCategory: String, Codable, Sendable, Hashable, CaseIterable {
    case maleDoubles = "MALE DOUBLES"

    var displayName: String { rawValue }
}

nonisolated enum RaceMode: String, Codable, Sendable, Hashable, CaseIterable {
    case competitionSimulation = "COMPETITION SIMULATION"

    var displayName: String { rawValue }
}

struct RaceDefinition: Identifiable, Codable, Sendable, Hashable {
    let id: String
    let name: String
    let category: RaceCategory
    /// Full official order including cognitive preview/recall and finish.
    let segments: [RaceSegment]

    /// Runs + work stations only (progression between preview and recall).
    var physicalSegments: [RaceSegment] {
        segments.filter(\.isPhysical)
    }

    var workStationCount: Int {
        segments.filter { $0.kind == .workStation }.count
    }

    func physicalSegment(at index: Int) -> RaceSegment? {
        let physical = physicalSegments
        guard physical.indices.contains(index) else { return nil }
        return physical[index]
    }
}

nonisolated struct TeamMember: Identifiable, Hashable, Sendable, Codable {
    let id: String
    let role: String
    let name: String
}

nonisolated struct RaceSetupConfiguration: Hashable, Sendable, Codable {
    var category: RaceCategory
    var mode: RaceMode
    var you: TeamMember
    var partner: TeamMember
    /// Dev/test distance source. Defaults to simulator; omitted in older saved results.
    var distanceTrackingMode: DistanceTrackingMode

    static let maleDoublesPlaceholder = RaceSetupConfiguration(
        category: .maleDoubles,
        mode: .competitionSimulation,
        you: TeamMember(id: "you", role: "YOU", name: "VARUN"),
        partner: TeamMember(id: "partner", role: "PARTNER", name: "ARJUN"),
        distanceTrackingMode: .simulated
    )

    enum CodingKeys: String, CodingKey {
        case category, mode, you, partner, distanceTrackingMode
    }

    init(
        category: RaceCategory,
        mode: RaceMode,
        you: TeamMember,
        partner: TeamMember,
        distanceTrackingMode: DistanceTrackingMode = .simulated
    ) {
        self.category = category
        self.mode = mode
        self.you = you
        self.partner = partner
        self.distanceTrackingMode = distanceTrackingMode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        category = try container.decode(RaceCategory.self, forKey: .category)
        mode = try container.decode(RaceMode.self, forKey: .mode)
        you = try container.decode(TeamMember.self, forKey: .you)
        partner = try container.decode(TeamMember.self, forKey: .partner)
        distanceTrackingMode = try container.decodeIfPresent(
            DistanceTrackingMode.self,
            forKey: .distanceTrackingMode
        ) ?? .simulated
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(category, forKey: .category)
        try container.encode(mode, forKey: .mode)
        try container.encode(you, forKey: .you)
        try container.encode(partner, forKey: .partner)
        try container.encode(distanceTrackingMode, forKey: .distanceTrackingMode)
    }
}
