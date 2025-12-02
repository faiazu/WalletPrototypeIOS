//
//  AppButtonStyles.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import SwiftUI

/// Primary filled button style for main actions.
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, StyleGuide.Spacing.md)
            .padding(.horizontal, StyleGuide.Spacing.lg)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? StyleGuide.Colors.accent.opacity(0.8) : StyleGuide.Colors.accent)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: StyleGuide.Radius.md, style: .continuous))
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Secondary outlined button style for less prominent actions.
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, StyleGuide.Spacing.md)
            .padding(.horizontal, StyleGuide.Spacing.lg)
            .frame(maxWidth: .infinity)
            .background(StyleGuide.Colors.surface)
            .foregroundStyle(.primary)
            .overlay(
                RoundedRectangle(cornerRadius: StyleGuide.Radius.md, style: .continuous)
                    .stroke(StyleGuide.Colors.accent.opacity(configuration.isPressed ? 0.9 : 0.6), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: StyleGuide.Radius.md, style: .continuous))
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
