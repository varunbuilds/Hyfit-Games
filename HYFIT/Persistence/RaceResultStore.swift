//
//  RaceResultStore.swift
//  HYFIT
//

import Foundation
import SwiftData
import OSLog

private let raceResultLogger = Logger(subsystem: "com.varunrewadi.HYFIT", category: "RaceResultStore")

/// Local persistence for completed `RaceResult` snapshots.
@MainActor
final class RaceResultStore {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Inserts once per RaceResult UUID. Safe to call repeatedly.
    @discardableResult
    func saveIfNeeded(_ result: RaceResult) -> Bool {
        let resultID = result.id
        do {
            var descriptor = FetchDescriptor<PersistedRaceResult>(
                predicate: #Predicate { $0.id == resultID }
            )
            descriptor.fetchLimit = 1
            let existing = try modelContext.fetch(descriptor)
            if !existing.isEmpty {
                raceResultLogger.debug("Skip duplicate save for \(resultID.uuidString, privacy: .public)")
                return false
            }

            let payload = try JSONEncoder().encode(result)
            let row = PersistedRaceResult(
                id: result.id,
                completedAt: result.completedAt,
                payload: payload
            )
            modelContext.insert(row)
            try modelContext.save()

            let total = try storedCount()
            raceResultLogger.info(
                "Saved RaceResult \(resultID.uuidString, privacy: .public). Store count=\(total)"
            )
            #if DEBUG
            print("[HYFIT] Saved RaceResult \(resultID). Store count=\(total)")
            #endif
            return true
        } catch {
            raceResultLogger.error("Failed to save RaceResult: \(error.localizedDescription, privacy: .public)")
            #if DEBUG
            print("[HYFIT] Failed to save RaceResult: \(error)")
            #endif
            return false
        }
    }

    func fetchAll() -> [RaceResult] {
        do {
            var descriptor = FetchDescriptor<PersistedRaceResult>(
                sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
            )
            let rows = try modelContext.fetch(descriptor)
            return rows.compactMap { $0.decodedResult() }
        } catch {
            raceResultLogger.error("Failed to fetch RaceResults: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    func fetch(id: UUID) -> RaceResult? {
        let resultID = id
        do {
            var descriptor = FetchDescriptor<PersistedRaceResult>(
                predicate: #Predicate { $0.id == resultID }
            )
            descriptor.fetchLimit = 1
            return try modelContext.fetch(descriptor).first?.decodedResult()
        } catch {
            raceResultLogger.error("Failed to fetch RaceResult \(resultID.uuidString, privacy: .public): \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    func storedCount() throws -> Int {
        try modelContext.fetchCount(FetchDescriptor<PersistedRaceResult>())
    }

    func debugLogStoreCount(context: String) {
        do {
            let total = try storedCount()
            raceResultLogger.info("[\(context, privacy: .public)] RaceResult store count=\(total)")
            #if DEBUG
            print("[HYFIT] [\(context)] RaceResult store count=\(total)")
            #endif
        } catch {
            raceResultLogger.error("Count failed: \(error.localizedDescription, privacy: .public)")
        }
    }
}
