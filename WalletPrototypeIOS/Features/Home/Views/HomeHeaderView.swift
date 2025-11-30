//
//  HomeHeaderView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import SwiftUI

struct HomeHeaderView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                                .foregroundStyle(Color(hex: "1A3EEC"))
                        )
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .offset(x: 6, y: -6)
                }

                Spacer()

                VStack(spacing: 4) {
                    Text("Divvi")
                        .font(.title2.bold())
                }

                Spacer()

                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 46, height: 46)
                    .overlay(
                        Image(systemName: "bell.fill")
                            .foregroundStyle(.orange)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(displayName(for: appState.currentUser))
                    .font(.system(size: 24, weight: .heavy))
                if let email = appState.currentUser?.email {
                    Text(email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func displayName(for user: User?) -> String {
        if let name = user?.name, !name.isEmpty { return name }
        if let email = user?.email {
            let base = email.split(separator: "@").first ?? Substring(email)
            let parts = base.split(separator: ".").map { $0.capitalized }
            if !parts.isEmpty { return parts.joined(separator: " ") }
            return String(base)
        }
        return "User"
    }
}

#Preview {
    HomeHeaderView(appState: AppState())
}
