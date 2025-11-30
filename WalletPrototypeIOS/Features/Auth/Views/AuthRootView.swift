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
        ScrollView {
            VStack(spacing: 24) {
                heroSection

                demoButton

                statusSection

                googleSection
            }
            .padding()
            .animation(.default, value: viewModel.isLoading)
        }
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

    var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(LinearGradient(colors: [.blue, Color.purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 280)
                .shadow(radius: 8, y: 6)

            VStack(alignment: .leading, spacing: 12) {
                Text("Divvi")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                Text("The only solution for shared wallets.")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.9))
                Text("Login with the demo user to explore the dashboard.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding()
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
        .buttonStyle(PrimaryButtonStyle())
        .disabled(viewModel.isLoading)
        .opacity(viewModel.isLoading ? 0.9 : 1.0)
    }
    
    var statusSection: some View {
        VStack(spacing: 8) {
            if viewModel.isLoading {
                ProgressView(viewModel.statusMessage ?? "Signing in...")
            }

            if let status = viewModel.statusMessage {
                StatusBanner(text: status, style: .info)
            }

            if let error = viewModel.errorMessage {
                StatusBanner(text: error, style: .error)
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
