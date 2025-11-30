//
//  CardService.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import Foundation

struct CardDetailsResponse: Codable {
    let card: Card
    let balances: Balances?
}

struct CardStatusUpdateRequest: Codable {
    let status: CardStatus
}

protocol CardServicing {
    func fetchCard(cardId: String) async throws -> CardDetailsResponse
    func updateCardStatus(cardId: String, status: CardStatus) async throws -> Card
    func listCards(walletId: String) async throws -> [Card]
}

final class CardService: CardServicing {
    static let shared = CardService()
    private init() {}

    private let apiClient = APIClient.shared

    func fetchCard(cardId: String) async throws -> CardDetailsResponse {
        try await apiClient.send(
            path: "/cards/\(cardId)",
            method: .get
        )
    }

    func updateCardStatus(cardId: String, status: CardStatus) async throws -> Card {
        let request = CardStatusUpdateRequest(status: status)
        return try await apiClient.send(
            path: "/cards/\(cardId)/status",
            method: .patch,
            body: request
        )
    }

    func listCards(walletId: String) async throws -> [Card] {
        struct ListResponse: Codable { let cards: [Card] }
        let response: ListResponse = try await apiClient.send(
            path: "/wallets/\(walletId)/cards",
            method: .get
        )
        return response.cards
    }
}
