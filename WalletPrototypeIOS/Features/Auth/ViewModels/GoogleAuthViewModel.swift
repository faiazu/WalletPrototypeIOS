//
//  GoogleAuthViewModel.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-15.
//

import Combine
import UIKit

@MainActor
final class GoogleAuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?

    func signInWithGoogle(
        presenting viewController: UIViewController,
        appState: AppState
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            // Google UI to ID token
            let idToken = try await GoogleAuthService.shared.signIn(presenting: viewController)
            print("✅ Google ID Token:", idToken)

            // Send token to backend
            let response = try await AuthService.shared.loginWithGoogle(idToken: idToken)
            print("✅ Backend auth token:", response.token)

            // Update global app state
            appState.applyLogin(response: response)

        } catch {
            print("❌ Sign in failed:", error)
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}


