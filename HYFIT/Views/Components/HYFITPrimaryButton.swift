//
//  HYFITPrimaryButton.swift
//  HYFIT
//

import SwiftUI

struct HYFITPrimaryButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .hyfitButton()
                .foregroundStyle(HYFITTheme.onLime)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(isEnabled ? HYFITTheme.lime : HYFITTheme.lime.opacity(0.35))
                .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous))
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
    }
}

struct HYFITSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .hyfitButton()
                .foregroundStyle(HYFITTheme.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(HYFITTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous)
                        .stroke(HYFITTheme.borderStrong, lineWidth: HYFITTheme.borderWidth)
                )
                .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        HYFITPrimaryButton(title: "START RACE →") {}
        HYFITSecondaryButton(title: "RACE AGAIN") {}
    }
    .padding()
    .background(HYFITTheme.background)
}
