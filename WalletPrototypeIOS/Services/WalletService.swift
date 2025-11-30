//
//  WalletService.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import Foundation

final class WalletService {
    static let shared = WalletService()
    private init() {}

    private let apiClient = APIClient.shared

    // Ensures a default wallet, membership, and card; returns dashboard-ready data.
    func bootstrap() async throws -> WalletBootstrapResponse {
        let response: WalletBootstrapResponse = try await apiClient.send(
            path: "/wallet/bootstrap",
            method: .post
        )
        return response
    }
}
