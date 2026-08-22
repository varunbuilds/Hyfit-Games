//
//  CircularDistanceProgress.swift
//  HYFIT
//

import SwiftUI

struct CircularDistanceProgress: View {
    let current: Double
    let target: Double
    let unit: DistanceUnit
    var iconSystemName: String = "figure.run"

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(1, max(0, current / target))
    }

    private var currentLabel: String {
        current.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(current.rounded()))"
            : String(format: "%.0f", current)
    }

    private var targetLabel: String {
        let value = target.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(target))"
            : String(format: "%.0f", target)
        return "/ \(value) \(unit.shortLabel)"
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(HYFITTheme.surfaceSecondary, lineWidth: 10)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    HYFITTheme.lime,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.2), value: progress)

            VStack(spacing: 6) {
                Image(systemName: iconSystemName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(HYFITTheme.lime)

                Text(currentLabel)
                    .font(HYFITTypography.metricLarge)
                    .foregroundStyle(HYFITTheme.lime)
                    .monospacedDigit()

                Text(targetLabel)
                    .font(HYFITTypography.label)
                    .foregroundStyle(HYFITTheme.secondaryText)
                    .tracking(1)
            }
        }
        .frame(width: 220, height: 220)
    }
}

struct SegmentedDistanceBar: View {
    let current: Double
    let target: Double
    let unit: DistanceUnit
    var segments: Int = 10

    private var filled: Int {
        guard target > 0 else { return 0 }
        return Int((Double(segments) * current / target).rounded(.down))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 4) {
                ForEach(0..<segments, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(index < filled ? HYFITTheme.lime : HYFITTheme.surfaceSecondary)
                        .frame(height: 8)
                }
            }
            Text("\(Int(current.rounded())) / \(Int(target)) \(unit.shortLabel)")
                .font(HYFITTypography.label)
                .foregroundStyle(HYFITTheme.lime)
                .tracking(1)
        }
    }
}

#Preview {
    VStack(spacing: 32) {
        CircularDistanceProgress(current: 148, target: 200, unit: .meters)
        SegmentedDistanceBar(current: 14, target: 20, unit: .meters)
    }
    .padding()
    .background(HYFITTheme.background)
}
