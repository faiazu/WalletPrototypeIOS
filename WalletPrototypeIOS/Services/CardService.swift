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
    func createCard(walletId: String, nickname: String?) async throws -> Card
    func updateNickname(cardId: String, nickname: String) async throws -> Card
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

    func createCard(walletId: String, nickname: String?) async throws -> Card {
        let response: IssueCardResponse

        if let nickname = nickname, !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let request = IssueCardRequest(nickname: nickname)
            response = try await apiClient.send(
                path: "/wallets/\(walletId)/cards",
                method: .post,
                body: request
            )
        } else {
            response = try await apiClient.send(
                path: "/wallets/\(walletId)/cards",
                method: .post
            )
        }
        return response.toDomain(walletId: walletId)
    }

    func updateNickname(cardId: String, nickname: String) async throws -> Card {
        let request = CardNicknameUpdateRequest(nickname: nickname)
        return try await apiClient.send(
            path: "/cards/\(cardId)/nickname",
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

private struct IssueCardRequest: Codable {
    let nickname: String
}

private struct IssueCardResponse: Codable {
    let provider: String?
    let externalCardId: String?
    let last4: String?
    let nickname: String?
    let status: CardStatus?

    func toDomain(walletId: String) -> Card {
        Card(
            id: nil,
            externalCardId: externalCardId,
            last4: last4,
            nickname: nickname,
            status: status ?? .active,
            providerName: provider,
            walletId: walletId,
            userId: nil,
            user: nil
        )
    }
}

private struct CardNicknameUpdateRequest: Codable {
    let nickname: String
}
