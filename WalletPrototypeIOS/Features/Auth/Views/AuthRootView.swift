//
//  AuthRootView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-15.
//

import SwiftUI
import GoogleSignInSwift

struct AuthRootView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = GoogleAuthViewModel()

    var body: some View {
        VStack(spacing: 32) {
            Text("WalletApp")
                .font(.largeTitle)
                .bold()

            Text("Sign in to continue")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            GoogleSignInButton {
                handleGoogleSignInTap()
            }
            .frame(height: 50)
            .padding(.horizontal)

            if viewModel.isLoading {
                ProgressView("Signing in…")
            }

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding()
    }

    private func handleGoogleSignInTap() {
        guard let rootVC = RootViewControllerProvider.rootViewController() else {
            viewModel.errorMessage = "Unable to find root view controller."
            return
        }

        Task {
            await viewModel.signInWithGoogle(
                presenting: rootVC,
                appState: appState
            )
        }
    }
}

#Preview {
    AuthRootView()
        .environmentObject(AppState())
}
