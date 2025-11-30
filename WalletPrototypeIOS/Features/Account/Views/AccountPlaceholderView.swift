//
//  AccountPlaceholderView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import SwiftUI

/// Simple account screen placeholder. Shows basic profile info and a sign-out action.
struct AccountPlaceholderView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 64, height: 64)
                    .overlay(
                        Text(initials(appState.currentUser?.email ?? "User"))
                            .font(.title3.bold())
                            .foregroundStyle(.blue)
                    )

                VStack(alignment: .leading, spacing: 6) {
                    Text(appState.currentUser?.email ?? "user@example.com")
                        .font(.headline)
                    Text(appState.personId ?? "No personId")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            Divider()

            StatusBanner(text: "Account screen placeholder. Add profile/settings later.", style: .info)

            Spacer()

            Button(role: .destructive) {
                appState.signOut()
            } label: {
                Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
        .navigationTitle("Account")
    }

    private func initials(_ text: String) -> String {
        guard let first = text.first else { return "U" }
        return String(first).uppercased()
    }
}

#Preview {
    NavigationStack {
        AccountPlaceholderView(appState: AppState())
    }
}
