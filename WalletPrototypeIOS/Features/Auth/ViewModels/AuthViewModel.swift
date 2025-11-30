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
