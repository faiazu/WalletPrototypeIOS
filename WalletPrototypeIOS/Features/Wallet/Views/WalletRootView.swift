//
//  WalletRootView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-19.
//

import SwiftUI

struct WalletRootView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        VStack(spacing: 16) {
            Text("Wallet")
                .font(.largeTitle)
                .bold()

            if let user = appState.currentUser {
                Text("Owner: \(user.email)")
                    .foregroundStyle(.secondary)
            }

            Text("Wallet UI goes here.")
                .font(.subheadline)

            Spacer()
        }
        .padding()
        .navigationTitle("$$$")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        WalletRootView(appState: AppState())
    }
}
