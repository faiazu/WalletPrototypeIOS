//
//  StatusBanner.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import SwiftUI

/// Lightweight banner for inline status/error messages.
struct StatusBanner: View {
    enum Style {
        case info
        case error
    }

    let text: String
    let style: Style

    var body: some View {
        HStack(alignment: .center, spacing: StyleGuide.Spacing.md) {
            Image(systemName: iconName)
                .font(.headline)
                .foregroundStyle(iconColor)

            Text(text)
                .font(StyleGuide.Fonts.caption)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding(StyleGuide.Spacing.md)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: StyleGuide.Radius.md, style: .continuous))
    }

    private var backgroundColor: Color {
        switch style {
        case .info:
            return Color(.secondarySystemBackground)
        case .error:
            return Color.red.opacity(0.12)
        }
    }

    private var iconColor: Color {
        switch style {
        case .info:
            return .accentColor
        case .error:
            return .red
        }
    }

    private var iconName: String {
        switch style {
        case .info:
            return "info.circle"
        case .error:
            return "exclamationmark.circle"
        }
    }
}

#Preview {
    VStack {
        StatusBanner(text: "Loading wallet data...", style: .info)
        StatusBanner(text: "Failed to load wallet.", style: .error)
    }
    .padding()
}
