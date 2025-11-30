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
    @StateObject private var viewModel: AuthViewModel = AuthViewModel()

    var body: some View {
        VStack(spacing: 24) {
            header

            demoButton

            statusSection

            googleSection
        }
        .padding()
        .animation(.default, value: viewModel.isLoading)
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

    var demoButton: some View {
        Button(action: handleDemoLoginTap) {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.title3.weight(.semibold))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Login as Christopher Albertson")
                        .font(.headline)
                    Text("Local demo account with Synctera onboarding")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(viewModel.isLoading)
        .opacity(viewModel.isLoading ? 0.9 : 1.0)
    }
    
    var statusSection: some View {
        VStack(spacing: 8) {
            if viewModel.isLoading {
                ProgressView(viewModel.statusMessage ?? "Signing in...")
            }

            if let status = viewModel.statusMessage {
                Text(status)
                    .foregroundStyle(.secondary)
                    .font(.footnote)
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

    var googleSection: some View {
        VStack(spacing: 8) {
            Text("Other sign-in options")
                .font(.caption)
                .foregroundStyle(.secondary)

            GoogleSignInButton {
                handleGoogleSignInTap()
            }
            .frame(height: 44)
            .padding(.horizontal)
            .disabled(viewModel.isLoading)
            .opacity(viewModel.isLoading ? 0.35 : 0.6)
        }
        .padding(.top, 8)
    }
}

// Actions
private extension AuthRootView {
    func handleDemoLoginTap() {
        guard !viewModel.isLoading else { return }

        Task {
            await viewModel.loginAsChristopher(appState: appState)
        }
    }

    func handleGoogleSignInTap() {
        // Don't start a second sign-in while one is in progress
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
