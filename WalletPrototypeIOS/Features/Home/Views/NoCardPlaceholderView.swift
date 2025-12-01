//
//  NoCardPlaceholderView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-12-02.
//

import SwiftUI

/// Placeholder shown when a wallet has no cards yet.
struct NoCardPlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(style: StrokeStyle(lineWidth: 2, dash: [10, 6]))
                .foregroundStyle(Color(.systemGray4))
                .frame(height: 220)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "creditcard")
                            .font(.title)
                            .foregroundStyle(.secondary)
                        Text("No card issued yet")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                )
        }
    }
}

#Preview {
    NoCardPlaceholderView()
        .padding()
}
