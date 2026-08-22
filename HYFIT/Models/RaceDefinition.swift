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
    let stations: [RaceStation]

    var stationCount: Int { stations.count }

    func station(at index: Int) -> RaceStation? {
        guard stations.indices.contains(index) else { return nil }
        return stations[index]
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
