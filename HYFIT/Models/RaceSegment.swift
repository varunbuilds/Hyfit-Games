//
//  RaceSegment.swift
//  HYFIT
//

import Foundation

/// Ordered race flow item. Cognitive steps are not physical stations.
struct RaceSegment: Identifiable, Codable, Sendable, Hashable {
    enum Kind: String, Codable, Sendable, Hashable {
        case cognitivePreview
        case run
        case workStation
        case cognitiveRecall
        case finish
    }

    let id: String
    let kind: Kind
    /// Format badge: START / STATION 01 / RECALL / FINISH, etc.
    let badge: String
    let title: String
    let shortDescription: String
    /// 1...6 for 200 m runs (internal only — not shown in format UI).
    let runNumber: Int?
    /// 1...6 for physical work stations (display as 01...06).
    let workStationNumber: Int?
    let station: RaceStation?

    var isPhysical: Bool {
        kind == .run || kind == .workStation
    }
}
