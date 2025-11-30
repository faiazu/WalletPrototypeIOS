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
                if let email = appState.currentUser?.email {
                    Text(email)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
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
    }
}

#Preview {
    HomeHeaderView(appState: AppState())
}
