//
//  CardSettingsViewModel.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import Foundation
import Combine

@MainActor
final class CardSettingsViewModel: ObservableObject {
    @Published var card: Card?
    @Published var balances: Balances?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var debugMessage: String?

    private let appState: AppState
    private let cardService: CardServicing
    private let initialCardId: String?

    init(appState: AppState, cardService: CardServicing = CardService.shared) {
        self.appState = appState
        self.cardService = cardService
        self.card = appState.cards.first
        self.balances = appState.balances
        self.initialCardId = appState.cards.first?.id
    }

    func load() {
        guard let cardId = initialCardId ?? card?.id else { return }
        Task {
            do {
                isLoading = true
                errorMessage = nil
                debugMessage = "Loading card details..."
                let response = try await cardService.fetchCard(cardId: cardId)
                apply(card: response.card, balances: response.balances)
                debugMessage = "Card details refreshed."
            } catch {
                errorMessage = ErrorMessageMapper.message(for: error)
                debugMessage = "Failed to load card: \(errorMessage ?? "")"
            }
            isLoading = false
        }
    }

    func setLocked(_ locked: Bool) {
        let target: CardStatus = locked ? .locked : .active
        updateStatus(to: target)
    }

    func setDeactivated(_ deactivated: Bool) {
        let target: CardStatus = deactivated ? .canceled : .active
        updateStatus(to: target)
    }

    private func updateStatus(to status: CardStatus) {
        guard let cardId = initialCardId ?? card?.id else { return }
        Task {
            do {
                isLoading = true
                errorMessage = nil
                debugMessage = "Updating status to \(status.rawValue)..."
                let updated = try await cardService.updateCardStatus(cardId: cardId, status: status)
                apply(card: updated, balances: balances)
                debugMessage = "Card status updated to \(status.rawValue)."
            } catch {
                errorMessage = ErrorMessageMapper.message(for: error)
                debugMessage = "Failed to update status: \(errorMessage ?? "")"
            }
            isLoading = false
        }
    }

    private func apply(card: Card, balances: Balances?) {
        self.card = card
        self.balances = balances ?? self.balances
        appState.updateCard(card)
        if let balances {
            appState.balances = balances
        }
    }
}
