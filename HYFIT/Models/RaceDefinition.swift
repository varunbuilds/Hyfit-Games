//
//  RaceDefinition.swift
//  HYFIT
//

import Foundation

enum RaceCategory: String, Codable, Sendable, Hashable, CaseIterable {
    case maleDoubles = "MALE DOUBLES"

    var displayName: String { rawValue }
}

enum RaceMode: String, Codable, Sendable, Hashable, CaseIterable {
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

struct TeamMember: Identifiable, Hashable, Sendable {
    let id: String
    let role: String
    let name: String
}

struct RaceSetupConfiguration: Hashable, Sendable {
    var category: RaceCategory
    var mode: RaceMode
    var you: TeamMember
    var partner: TeamMember

    static let maleDoublesPlaceholder = RaceSetupConfiguration(
        category: .maleDoubles,
        mode: .competitionSimulation,
        you: TeamMember(id: "you", role: "YOU", name: "VARUN"),
        partner: TeamMember(id: "partner", role: "PARTNER", name: "ARJUN")
    )
}
