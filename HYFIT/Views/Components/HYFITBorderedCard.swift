//
//  HYFITBorderedCard.swift
//  HYFIT
//

import SwiftUI

struct HYFITBorderedCard<Content: View>: View {
    var accentBorder: Bool = false
    var padding: CGFloat = 16
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(HYFITTheme.surface)
            .overlay(
                RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous)
                    .stroke(
                        accentBorder ? HYFITTheme.lime : HYFITTheme.border,
                        lineWidth: HYFITTheme.borderWidth
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: HYFITTheme.cornerRadius, style: .continuous))
    }
}

struct HYFITFieldRow: View {
    let label: String
    let value: String
    var showsChevron: Bool = false
    var showsEdit: Bool = false

    var body: some View {
        HYFITBorderedCard {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(label)
                        .hyfitLabel(HYFITTheme.tertiaryText)
                    Text(value)
                        .font(HYFITTypography.heading)
                        .foregroundStyle(HYFITTheme.primaryText)
                        .textCase(.uppercase)
                }
                Spacer(minLength: 8)
                if showsChevron {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(HYFITTheme.secondaryText)
                }
                if showsEdit {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(HYFITTheme.secondaryText)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        HYFITFieldRow(label: "CATEGORY", value: "MALE DOUBLES", showsChevron: true)
        HYFITFieldRow(label: "YOU", value: "VARUN", showsEdit: true)
    }
    .padding()
    .background(HYFITTheme.background)
}
