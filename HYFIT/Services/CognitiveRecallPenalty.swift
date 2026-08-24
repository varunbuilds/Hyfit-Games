//
//  CognitiveRecallPenalty.swift
//  HYFIT
//

import Foundation

enum CognitivePenaltyType: String, Sendable, Hashable {
    case fullRecall = "FULL_RECALL"
    case noPenalty = "NO_PENALTY"
    case incorrectRecall = "INCORRECT_RECALL"
    case refusedRecall = "REFUSED_RECALL"

    var displayLabel: String {
        switch self {
        case .fullRecall: "Fully correct recall"
        case .noPenalty: "6 or more correct"
        case .incorrectRecall: "Fewer than 6 correct"
        case .refusedRecall: "Refused recall"
        }
    }
}

struct CognitiveRecallPenaltyResult: Sendable, Hashable {
    let correctPositions: Int
    /// Signed seconds applied to raw finish time (−30, 0, +30, +60).
    let penaltySeconds: TimeInterval
    let penaltyType: CognitivePenaltyType
    let rawFinishTime: TimeInterval
    let adjustedFinishTime: TimeInterval
}

enum CognitiveRecallPenalty {
    /// Position-based comparison and penalty. Does not mutate the race timer.
    static func calculate(
        original: [CognitiveColor],
        submitted: [CognitiveColor],
        rawFinishTime: TimeInterval,
        refused: Bool
    ) -> CognitiveRecallPenaltyResult {
        let correctPositions: Int
        let penaltyType: CognitivePenaltyType
        let penaltySeconds: TimeInterval

        if refused || submitted.isEmpty {
            correctPositions = 0
            penaltyType = .refusedRecall
            penaltySeconds = 60
        } else {
            correctPositions = countCorrectPositions(original: original, submitted: submitted)
            if correctPositions == 10 {
                penaltyType = .fullRecall
                penaltySeconds = -30
            } else if correctPositions >= 6 {
                penaltyType = .noPenalty
                penaltySeconds = 0
            } else {
                penaltyType = .incorrectRecall
                penaltySeconds = 30
            }
        }

        let adjusted = max(0, rawFinishTime + penaltySeconds)
        return CognitiveRecallPenaltyResult(
            correctPositions: correctPositions,
            penaltySeconds: penaltySeconds,
            penaltyType: penaltyType,
            rawFinishTime: rawFinishTime,
            adjustedFinishTime: adjusted
        )
    }

    /// Only matching indexes count. Missing submitted slots are never correct.
    static func countCorrectPositions(
        original: [CognitiveColor],
        submitted: [CognitiveColor]
    ) -> Int {
        let limit = min(original.count, submitted.count)
        var correct = 0
        for index in 0..<limit {
            if submitted[index] == original[index] {
                correct += 1
            }
        }
        return correct
    }
}
