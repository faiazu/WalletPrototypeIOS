//
//  WalletService.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import Foundation

protocol WalletServicing {
    func fetchWalletDetails(walletId: String) async throws -> WalletDetailsResponse
    func createWallet(name: String) async throws -> Wallet
    func joinWallet(walletId: String) async throws -> Wallet
}

final class WalletService: WalletServicing {
    static let shared = WalletService()
    private init() {}

    private let apiClient = APIClient.shared

    func fetchWalletDetails(walletId: String) async throws -> WalletDetailsResponse {
        let dto: WalletDetailsDTO = try await apiClient.send(
            path: "/wallet/\(walletId)",
            method: .get
        )
        return dto.toDomain()
    }

    func createWallet(name: String) async throws -> Wallet {
        struct Request: Codable { let name: String }
        struct Response: Codable { let wallet: WalletDTO }

        let response: Response = try await apiClient.send(
            path: "/wallet/create",
            method: .post,
            body: Request(name: name)
        )
        return response.wallet.toDomain()
    }

    func joinWallet(walletId: String) async throws -> Wallet {
        struct Response: Codable { let wallet: WalletDTO }
        let response: Response = try await apiClient.send(
            path: "/wallet/\(walletId)/join",
            method: .post
        )
        return response.wallet.toDomain()
    }
}
