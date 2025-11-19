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
    func loginWithGoogle(idToken: String) async throws -> GoogleLoginResponse {
        let request = GoogleLoginRequest(idToken: idToken)

        let response: GoogleLoginResponse = try await apiClient.send(
            path: "/auth/google",   // backend route we'll build later
            method: HTTPMethod.post,
            body: request
        )

        return response
    }
}

