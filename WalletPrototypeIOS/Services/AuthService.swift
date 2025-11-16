//
//  AuthService.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-15.
//

import Foundation

final class AuthService {
    static let shared = AuthService()
    private init() {}

    private let apiClient = APIClient.shared

    // Sends the Google ID Token to backend and returns (User, token)
    func loginWithGoogle(idToken: String) async throws -> (User, String) {
        let request = GoogleLoginRequest(idToken: idToken)

        let response: GoogleLoginResponse = try await apiClient.send(
            path: "/auth/google",   // backend route we'll build later
            method: "POST",
            body: request
        )

        return (response.user, response.token)
    }
}

