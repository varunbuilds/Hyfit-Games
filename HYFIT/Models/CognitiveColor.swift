//
//  CognitiveColor.swift
//  HYFIT
//

import SwiftUI

enum CognitiveColor: String, CaseIterable, Codable, Sendable, Hashable {
    case yellow = "Y"
    case red = "R"
    case green = "G"
    case blue = "B"

    var letter: String { rawValue }

    var displayColor: Color {
        switch self {
        case .yellow: Color(red: 1.0, green: 0.85, blue: 0.0)
        case .red: Color(red: 0.95, green: 0.22, blue: 0.22)
        case .green: Color(red: 0.18, green: 0.78, blue: 0.35)
        case .blue: Color(red: 0.20, green: 0.48, blue: 1.0)
        }
    }

    static func randomSequence(count: Int = 10) -> [CognitiveColor] {
        (0..<count).map { _ in allCases.randomElement()! }
    }

    /// Parses 0...10 Y/R/G/B letters. Spaces ignored. Invalid characters → nil.
    static func parseSubmitted(_ input: String) -> [CognitiveColor]? {
        let letters = input
            .uppercased()
            .filter { !$0.isWhitespace }
            .map(String.init)

        guard letters.count <= 10 else { return nil }

        var colors: [CognitiveColor] = []
        colors.reserveCapacity(letters.count)
        for letter in letters {
            guard let color = CognitiveColor(rawValue: letter) else { return nil }
            colors.append(color)
        }
        return colors
    }

    /// Legacy exact-10 parse used where a full sequence is required.
    static func parse(_ input: String) -> [CognitiveColor]? {
        guard let colors = parseSubmitted(input), colors.count == 10 else { return nil }
        return colors
    }
}
