//
//  PersistedRaceResult.swift
//  HYFIT
//

import Foundation
import SwiftData

/// SwiftData row for a completed race. Full `RaceResult` is stored as Codable JSON payload
/// so nested enums/structs/arrays persist reliably without a complex schema.
@Model
final class PersistedRaceResult {
    @Attribute(.unique) var id: UUID
    var completedAt: Date
    /// JSON-encoded `RaceResult`.
    var payload: Data

    init(id: UUID, completedAt: Date, payload: Data) {
        self.id = id
        self.completedAt = completedAt
        self.payload = payload
    }

    func decodedResult() -> RaceResult? {
        try? JSONDecoder().decode(RaceResult.self, from: payload)
    }
}
