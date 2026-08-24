//
//  CognitiveRecallView.swift
//  HYFIT
//

import SwiftUI

struct CognitiveRecallView: View {
    @Bindable var session: RaceSession
    @State private var inputText: String = ""
    @FocusState private var isFocused: Bool

    private var normalizedLetters: [Character] {
        Array(
            inputText
                .uppercased()
                .filter { "YRGB".contains($0) }
        )
    }

    private var canSubmit: Bool {
        !session.hasSubmittedCognitiveRecall
    }

    var body: some View {
        ZStack {
            HYFITTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("RECALL")
                    .hyfitLabel(HYFITTheme.lime)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)

                Spacer(minLength: 16)

                VStack(alignment: .leading, spacing: 20) {
                    Text("COGNITIVE FINISH")
                        .font(HYFITTypography.title)
                        .foregroundStyle(HYFITTheme.primaryText)
                        .textCase(.uppercase)

                    Text("Recall the sequence from the start, now under fatigue. Mind and body, together.")
                        .font(HYFITTypography.body)
                        .foregroundStyle(HYFITTheme.secondaryText)

                    letterSlots
                        .padding(.top, 4)

                    Text("ALLOWED: Y / R / G / B")
                        .hyfitLabel(HYFITTheme.tertiaryText)

                    TextField("", text: $inputText)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .keyboardType(.asciiCapable)
                        .focused($isFocused)
                        .disabled(session.hasSubmittedCognitiveRecall)
                        .font(HYFITTypography.heading)
                        .foregroundStyle(HYFITTheme.primaryText)
                        .padding(14)
                        .background(HYFITTheme.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous)
                                .stroke(HYFITTheme.border, lineWidth: HYFITTheme.borderWidth)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous))
                        .onChange(of: inputText) { _, newValue in
                            let filtered = newValue
                                .uppercased()
                                .filter { "YRGB".contains($0) }
                            let limited = String(filtered.prefix(10))
                            if limited != newValue {
                                inputText = limited
                            }
                        }
                }
                .padding(.horizontal, HYFITTheme.horizontalPadding)

                Spacer()

                HYFITPrimaryButton(
                    title: "SUBMIT",
                    isEnabled: canSubmit,
                    action: submit
                )
                .padding(.horizontal, HYFITTheme.horizontalPadding)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            isFocused = true
        }
    }

    private var letterSlots: some View {
        HStack(spacing: 6) {
            ForEach(0..<10, id: \.self) { index in
                let letter = index < normalizedLetters.count
                    ? String(normalizedLetters[index])
                    : ""
                Text(letter.isEmpty ? "_" : letter)
                    .font(HYFITTypography.heading)
                    .foregroundStyle(letter.isEmpty ? HYFITTheme.tertiaryText : HYFITTheme.lime)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(HYFITTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(HYFITTheme.border, lineWidth: 1)
                    )
            }
        }
    }

    private func submit() {
        guard canSubmit else { return }
        _ = session.submitCognitiveRecall(input: String(normalizedLetters))
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
