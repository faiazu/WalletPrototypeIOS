//
//  SecondaryActionsView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import SwiftUI

struct SecondaryActionsView: View {
    let addMoneyAction: () -> Void
    let settingsAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: addMoneyAction) {
                HStack(spacing: 8) {
                    Text("💸")
                        .font(.system(size: 28))
                    Text("Add Money")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, minHeight: 24)
            }
            .buttonStyle(PrimaryButtonStyle())

            Button(action: settingsAction) {
                HStack(spacing: 8) {
                    Text("⚙️")
                        .font(.system(size: 28))
                    Text("Settings")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, minHeight: 24)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }
}

#Preview {
    SecondaryActionsView(addMoneyAction: {}, settingsAction: {})
        .padding()
}
