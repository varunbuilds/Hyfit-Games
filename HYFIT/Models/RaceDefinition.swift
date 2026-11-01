//
//  RaceDefinition.swift
//  HYFIT
//

import Foundation

/// Top-level race type. Each group owns a set of categories.
nonisolated enum RaceGroup: String, Codable, Sendable, Hashable, CaseIterable {
    case individuals = "INDIVIDUALS"
    case doubles = "DOUBLES"
    case games2X = "HYFIT GAMES 2X"

    var displayName: String {
        switch self {
        case .individuals: "Individuals"
        case .doubles: "Doubles"
        case .games2X: "Hyfit Games 2X"
        }
    }

    var categories: [RaceCategory] {
        RaceCategory.allCases.filter { $0.group == self }
    }
}

nonisolated enum RaceCategory: String, Codable, Sendable, Hashable, CaseIterable {
    // Individuals
    case nextGen8to11 = "NEXTGEN 8-11"
    case nextGen12to15 = "NEXTGEN 12-15"
    case grandMasters = "GRAND MASTERS"
    case openMale = "OPEN MALE"
    case openFemale = "OPEN FEMALE"
    case proMale = "PRO MALE"
    case proFemale = "PRO FEMALE"
    // Doubles
    case bloodline = "BLOODLINE"
    case maleDoubles = "MALE DOUBLES"
    case femaleDoubles = "FEMALE DOUBLES"
    case mixedDoubles = "MIXED DOUBLES"
    // Hyfit Games 2X
    case openMale2X = "OPEN MALE 2X"
    case openFemale2X = "OPEN FEMALE 2X"
    case proMale2X = "PRO MALE 2X"
    case proFemale2X = "PRO FEMALE 2X"
    case maleDoubles2X = "MALE DOUBLES 2X"
    case femaleDoubles2X = "FEMALE DOUBLES 2X"
    case mixedDoubles2X = "MIXED DOUBLES 2X"

    var displayName: String { rawValue }

    var group: RaceGroup {
        switch self {
        case .nextGen8to11, .nextGen12to15, .grandMasters, .openMale, .openFemale, .proMale, .proFemale:
            .individuals
        case .bloodline, .maleDoubles, .femaleDoubles, .mixedDoubles:
            .doubles
        case .openMale2X, .openFemale2X, .proMale2X, .proFemale2X,
             .maleDoubles2X, .femaleDoubles2X, .mixedDoubles2X:
            .games2X
        }
    }

    /// Name shown in the category selector (age is shown separately).
    var title: String {
        switch self {
        case .nextGen8to11, .nextGen12to15: "NextGen"
        case .grandMasters: "Grand Masters"
        case .openMale: "Open Male"
        case .openFemale: "Open Female"
        case .proMale: "Pro Male"
        case .proFemale: "Pro Female"
        case .bloodline: "Bloodline"
        case .maleDoubles: "Male Doubles"
        case .femaleDoubles: "Female Doubles"
        case .mixedDoubles: "Mixed Doubles"
        case .openMale2X: "Open Male 2X"
        case .openFemale2X: "Open Female 2X"
        case .proMale2X: "Pro Male 2X"
        case .proFemale2X: "Pro Female 2X"
        case .maleDoubles2X: "Male Doubles 2X"
        case .femaleDoubles2X: "Female Doubles 2X"
        case .mixedDoubles2X: "Mixed Doubles 2X"
        }
    }

    var ageLabel: String {
        switch self {
        case .nextGen8to11: "Ages 8-11"
        case .nextGen12to15: "Ages 12-15"
        case .grandMasters: "Ages 55-84"
        case .bloodline: "Parent + kid, 8-15"
        default: "Ages 16-84"
        }
    }

    /// Categories raced with a partner.
    var isTeam: Bool {
        switch self {
        case .bloodline, .maleDoubles, .femaleDoubles, .mixedDoubles,
             .maleDoubles2X, .femaleDoubles2X, .mixedDoubles2X:
            true
        default:
            false
        }
    }
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
