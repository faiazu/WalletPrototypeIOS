//
//  WalletService.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import Foundation

protocol WalletServicing {
    func bootstrap() async throws -> WalletBootstrapResponse
}

final class WalletService: WalletServicing {
    static let shared = WalletService()
    private init() {}

    private let apiClient = APIClient.shared

    // Ensures a default wallet, membership, and card; returns dashboard-ready data.
    func bootstrap() async throws -> WalletBootstrapResponse {
        let dto: WalletBootstrapDTO = try await apiClient.send(
            path: "/wallet/bootstrap",
            method: .post
        )
        return dto.toDomain()
    }
}
