//
//  UserService.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-15.
//

import Foundation

protocol UserServicing {
    func fetchCurrentUser(authToken: String) async throws -> User
}

final class UserService: UserServicing {
    static let shared = UserService()
    private init() {}

    private let apiClient = APIClient.shared

    // Calls GET /me with Authorization: Bearer <authToken>
    func fetchCurrentUser(authToken: String) async throws -> User {
        let user: User = try await apiClient.send(
            path: "/user/me",
            method: .get,
            headers: [
                "Authorization": "Bearer \(authToken)"
            ]
        )
        
        return user
    }
}
