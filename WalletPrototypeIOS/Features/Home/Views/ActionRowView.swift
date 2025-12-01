//
//  ActionRowView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import SwiftUI

struct ActionRowView: View {
    let createAction: () -> Void
    let joinAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: createAction) {
                HStack(spacing: 8) {
                    Text("💳")
                        .font(.system(size: 24))
                    Text("Create New Card")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .padding(.horizontal, 12)
            }
            .buttonStyle(PrimaryButtonStyle())

            Button(action: joinAction) {
                HStack(spacing: 8) {
                    Text("🏇")
                        .font(.system(size: 24))
                    Text("Join Wallet")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .padding(.horizontal, 12)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }
}

#Preview {
    ActionRowView(createAction: {}, joinAction: {})
        .padding()
}
