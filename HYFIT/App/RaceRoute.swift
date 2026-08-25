//
//  RaceRoute.swift
//  HYFIT
//

import Foundation

enum RaceRoute: Hashable {
    case setup
    case format
    case activeRace
    case completion
    case raceDetail(UUID)
}
