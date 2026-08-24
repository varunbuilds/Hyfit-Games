//
//  CognitivePreviewView.swift
//  HYFIT
//

import SwiftUI

struct CognitivePreviewView: View {
    let sequence: [CognitiveColor]
    let totalElapsed: TimeInterval
    let onRemember: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        ZStack {
            HYFITTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 20)

                VStack(alignment: .leading, spacing: 18) {
                    Text("COGNITIVE START")
                        .font(HYFITTypography.title)
                        .foregroundStyle(HYFITTheme.primaryText)
                        .textCase(.uppercase)

                    Text("Memorise a pattern before the timer forgives you. The race begins in your head.")
                        .font(HYFITTypography.body)
                        .foregroundStyle(HYFITTheme.secondaryText)

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(Array(sequence.enumerated()), id: \.offset) { _, color in
                            Text(color.letter)
                                .font(HYFITTypography.heading)
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 64)
                                .background(color.displayColor)
                                .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadiusSmall, style: .continuous))
                        }
                    }
                    .padding(.top, 8)

                    Text("Y YELLOW  ·  R RED  ·  G GREEN  ·  B BLUE")
                        .hyfitLabel(HYFITTheme.tertiaryText)
                        .padding(.top, 4)
                }
                .padding(.horizontal, HYFITTheme.horizontalPadding)

                Spacer()

                HYFITPrimaryButton(title: "REMEMBER →", action: onRemember)
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.bottom, 24)
            }
        }
    }
}

#Preview {
    CognitivePreviewView(
        sequence: CognitiveColor.randomSequence(),
        totalElapsed: 0,
        onRemember: {}
    )
}
