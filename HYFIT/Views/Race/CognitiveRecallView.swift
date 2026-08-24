//
//  CognitiveRecallView.swift
//  HYFIT
//

import SwiftUI

struct CognitiveRecallView: View {
    @Bindable var session: RaceSession
    @State private var entered: [CognitiveColor] = []

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    private var canSubmit: Bool {
        !session.hasSubmittedCognitiveRecall
    }

    private var canAppend: Bool {
        canSubmit && entered.count < 10
    }

    var body: some View {
        ZStack {
            HYFITTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 16)

                VStack(alignment: .leading, spacing: 18) {
                    Text("COGNITIVE FINISH")
                        .font(HYFITTypography.title)
                        .foregroundStyle(HYFITTheme.primaryText)
                        .textCase(.uppercase)

                    Text("Recall the sequence from the start, now under fatigue. Mind and body, together.")
                        .font(HYFITTypography.body)
                        .foregroundStyle(HYFITTheme.secondaryText)

                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(0..<10, id: \.self) { index in
                            sequenceBlock(at: index)
                        }
                    }
                    .padding(.top, 8)

                    Text("Y YELLOW  ·  R RED  ·  G GREEN  ·  B BLUE")
                        .hyfitLabel(HYFITTheme.tertiaryText)
                        .padding(.top, 4)
                }
                .padding(.horizontal, HYFITTheme.horizontalPadding)

                Spacer(minLength: 12)

                colorInputPad
                    .padding(.horizontal, HYFITTheme.horizontalPadding)
                    .padding(.bottom, 14)

                HStack(spacing: 12) {
                    HYFITPrimaryButton(
                        title: "SUBMIT",
                        isEnabled: canSubmit,
                        action: submit
                    )

                    backspaceButton
                }
                .padding(.horizontal, HYFITTheme.horizontalPadding)
                .padding(.bottom, 24)
            }
        }
    }

    @ViewBuilder
    private func sequenceBlock(at index: Int) -> some View {
        if index < entered.count {
            let color = entered[index]
            Text(color.letter)
                .font(HYFITTypography.heading)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(color.displayColor)
                .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadiusSmall, style: .continuous))
        } else {
            Text("")
                .font(HYFITTypography.heading)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(HYFITTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: HYFITTheme.cornerRadiusSmall, style: .continuous)
                        .stroke(HYFITTheme.border, lineWidth: HYFITTheme.borderWidth)
                )
                .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadiusSmall, style: .continuous))
        }
    }

    private var colorInputPad: some View {
        HStack(spacing: 10) {
            ForEach(CognitiveColor.allCases, id: \.self) { color in
                Button {
                    append(color)
                } label: {
                    Text(color.letter)
                        .font(HYFITTypography.heading)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(color.displayColor.opacity(canAppend ? 1 : 0.35))
                        .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadiusSmall, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!canAppend)
                .accessibilityLabel(color.letter)
            }
        }
    }

    private var canDelete: Bool {
        canSubmit && !entered.isEmpty
    }

    private var backspaceButton: some View {
        Button {
            deleteLast()
        } label: {
            Image(systemName: "delete.backward")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(canDelete ? HYFITTheme.primaryText : HYFITTheme.tertiaryText)
                .frame(width: 58, height: 58)
                .background(HYFITTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous)
                        .stroke(HYFITTheme.borderStrong, lineWidth: HYFITTheme.borderWidth)
                )
                .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!canDelete)
        .accessibilityLabel("Delete last color")
    }

    private func append(_ color: CognitiveColor) {
        guard canAppend else { return }
        entered.append(color)
    }

    private func deleteLast() {
        guard canDelete else { return }
        entered.removeLast()
    }

    private func submit() {
        guard canSubmit else { return }
        let input = entered.map(\.letter).joined()
        _ = session.submitCognitiveRecall(input: input)
    }
}

#Preview {
    CognitiveRecallView(
        session: {
            let session = RaceSession(
                definition: MaleDoublesRaceDefinition.race,
                setup: .maleDoublesPlaceholder
            )
            session.startRace()
            return session
        }()
    )
}
