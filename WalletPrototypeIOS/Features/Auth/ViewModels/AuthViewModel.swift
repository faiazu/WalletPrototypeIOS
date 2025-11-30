//
//  AuthViewModel.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-15.
//

import Combine
import UIKit

@MainActor
final class AuthViewModel: ObservableObject {
    // Standardized loading/error status for the screen.
    @Published var state: ScreenState = .idle
    @Published var isLoading = false
    @Published var statusMessage: String?
    @Published var errorMessage: String?

    private let authService: AuthServicing
    private let walletService: WalletServicing

    init(
        authService: AuthServicing? = nil,
        walletService: WalletServicing? = nil
    ) {
        self.authService = authService ?? AuthService.shared
        self.walletService = walletService ?? WalletService.shared
    }
    
    /// Primary path: demo login + bootstrap. Keeps the button disabled until both steps finish.
    func loginAsChristopher(appState: AppState) async {
        guard !isLoading else { return }

        errorMessage = nil
        statusMessage = "Signing you in..."
        state = .loading(message: statusMessage)
        isLoading = true

        do {
            let loginResponse = try await authService.loginAsChristopher()
            APIClient.shared.setAuthToken(loginResponse.token)

            statusMessage = "Preparing your wallet..."
            let bootstrap = try await walletService.bootstrap()
            appState.applyLogin(response: loginResponse)
            appState.applyBootstrap(bootstrap)

            statusMessage = nil
            state = .loaded
            isLoading = false
        } catch {
            handleAuthError(error, appState: appState)
        }
    }

    /// Secondary path: Google login retained for now; same bootstrap afterwards.
    func signInWithGoogle(
        presenting viewController: UIViewController,
        appState: AppState
    ) async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        statusMessage = "Connecting to Google..."
        state = .loading(message: statusMessage)

        do {
            let idToken = try await GoogleAuthService.shared.signIn(presenting: viewController)
            let response = try await authService.loginWithGoogle(idToken: idToken)
            APIClient.shared.setAuthToken(response.token)

            statusMessage = "Preparing your wallet..."
            let bootstrap = try await walletService.bootstrap()
            appState.applyLogin(response: response)
            appState.applyBootstrap(bootstrap)

            statusMessage = nil
            state = .loaded
            isLoading = false
        } catch {
            handleAuthError(error, appState: appState)
        }
    }
}

// MARK: - Private helpers
private extension AuthViewModel {
    /// Normalize errors, reset UI state, and clear any partial session so retry starts clean.
    func handleAuthError(_ error: Error, appState: AppState) {
        statusMessage = nil
        state = .error(message: ErrorMessageMapper.message(for: error))
        isLoading = false

        // If login partially succeeded, clear any persisted state so user can retry cleanly.
        if appState.currentUser != nil {
            appState.signOut()
        }

        if Task.isCancelled { return }

        errorMessage = ErrorMessageMapper.message(for: error)
    }
}
