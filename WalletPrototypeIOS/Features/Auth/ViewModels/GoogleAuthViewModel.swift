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
            // 1. Google UI → ID token
            let idToken = try await GoogleAuthService.shared.signIn(presenting: viewController)
            print("✅ Google ID Token:", idToken)

            // 2. Send token to your backend
            let (user, backendToken) = try await AuthService.shared.loginWithGoogle(idToken: idToken)
            print("✅ Backend auth token:", backendToken)

            // 3. Update global app state
            appState.currentUser = user
            appState.authToken = backendToken

        } catch {
            print("❌ Sign in failed:", error)
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}


