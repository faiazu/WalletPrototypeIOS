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
    @StateObject private var viewModel: GoogleAuthViewModel = GoogleAuthViewModel()

    var body: some View {
        VStack(spacing: 24) {
            
            header
            
            googleButton
            
            statusSection
            
        }
        .padding()
    }
}

// Subviews
private extension AuthRootView {
    var header: some View {
        VStack(spacing: 8) {
            Text("Wallet App")
                .font(.largeTitle)
                .bold()

            Text("Sign in to continue")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    var googleButton: some View {
        GoogleSignInButton {
            handleGoogleSignInTap()
        }
        .frame(height: 50)
        .padding(.horizontal)
        .disabled(viewModel.isLoading) // prevent double taps
        .opacity(viewModel.isLoading ? 0.6 : 1.0)
    }
    
    var statusSection: some View {
        VStack(spacing: 8) {
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
    }
}

// Actions
private extension AuthRootView {
    func handleGoogleSignInTap() {
        // Don’t start a second sign-in while one is in progress
        guard !viewModel.isLoading else { return }

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
