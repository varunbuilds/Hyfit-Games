//
//  StationType.swift
//  HYFIT
//

import Foundation

nonisolated enum StationType: String, Codable, Sendable, Hashable {
    case distance
    case repetitions
}

nonisolated enum DistanceUnit: String, Codable, Sendable, Hashable {
    case meters
    case kilometers

    var shortLabel: String {
        switch self {
        case .meters: "M"
        case .kilometers: "KM"
        }
    }

    func meters(from value: Double) -> Double {
        switch self {
        case .meters: value
        case .kilometers: value * 1000
        }
    }
}

nonisolated enum LoadUnit: String, Codable, Sendable, Hashable {
    case kilograms
    case pounds

    var shortLabel: String {
        switch self {
        case .kilograms: "KG"
        case .pounds: "LB"
        }
    }
}

/// Broad movement class for analytics (running vs station work).
nonisolated enum StationMovement: String, Codable, Sendable, Hashable {
    case run
    case carry
    case crawl
    case stepUp
    case sled
    case other

    var countsAsRunning: Bool { self == .run }
}
