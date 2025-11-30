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
    @Published var isLoading = false
    @Published var statusMessage: String?
    @Published var errorMessage: String?

    private let authService = AuthService.shared
    private let walletService = WalletService.shared
    
    func loginAsChristopher(appState: AppState) async {
        guard !isLoading else { return }

        errorMessage = nil
        statusMessage = "Signing you in..."
        isLoading = true

        do {
            let loginResponse = try await authService.loginAsChristopher()
            APIClient.shared.setAuthToken(loginResponse.token)

            statusMessage = "Preparing your wallet..."
            let bootstrap = try await walletService.bootstrap()
            appState.applyLogin(response: loginResponse)
            appState.applyBootstrap(bootstrap)

            statusMessage = nil
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

        do {
            let idToken = try await GoogleAuthService.shared.signIn(presenting: viewController)
            let response = try await authService.loginWithGoogle(idToken: idToken)
            APIClient.shared.setAuthToken(response.token)

            statusMessage = "Preparing your wallet..."
            let bootstrap = try await walletService.bootstrap()
            appState.applyLogin(response: response)
            appState.applyBootstrap(bootstrap)

            statusMessage = nil
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
        isLoading = false

        // If login partially succeeded, clear any persisted state so user can retry cleanly.
        if appState.currentUser != nil {
            appState.signOut()
        }

        if Task.isCancelled { return }

        if let apiError = error as? APIError {
            switch apiError {
            case let .serverError(_, body):
                errorMessage = parsedServerMessage(from: body) ?? apiError.localizedDescription
            default:
                errorMessage = apiError.localizedDescription
            }
        } else {
            errorMessage = error.localizedDescription
        }
    }

    func parsedServerMessage(from body: String?) -> String? {
        guard let body, !body.isEmpty else { return nil }

        if let data = body.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let message = json["error"] as? String {
            return message
        }

        return body
    }
}
