//
//  HomeRootView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-19.
//

import SwiftUI

struct HomeRootView: View {
    @ObservedObject var appState: AppState
    @StateObject private var viewModel: HomeViewModel

    init(appState: AppState) {
        _appState = ObservedObject(wrappedValue: appState)
        _viewModel = StateObject(wrappedValue: HomeViewModel(appState: appState))
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Home")
                .font(.largeTitle)
                .bold()

            if let me = viewModel.me {
                Text("Backend says you are:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(me.email)
                    .font(.headline)
            } else if let user = appState.currentUser {
                // Fallback to what we got from /auth/google before calling /me
                Text("Logged in as \(user.email)")
            }

            if viewModel.isLoading {
                ProgressView("Loading profile…")
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button("Reload /me") {
                viewModel.load()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)

            Button("Sign out") {
                viewModel.signOut()
            }
            .padding(.top, 4)
        }
        .padding()
        .onAppear {
            // Load once when the view appears
            viewModel.load()
        }
    }
}

#Preview {
    HomeRootView(appState: AppState())
}
