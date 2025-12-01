//
//  AppState.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-15.
//

import Foundation
import Combine
import SwiftUI

final class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var authToken: String?
    @Published var personId: String?
    @Published var overview: UserOverview?
    @Published var wallet: Wallet?
    @Published var cards: [Card] = []
    @Published var balances: Balances?
    @Published var showAuthTransition = false

    private let sessionStore: SessionStore
    
    init(sessionStore: SessionStore = .shared) {
        self.sessionStore = sessionStore

        if let snapshot = sessionStore.load() {
            self.currentUser = snapshot.user
            self.authToken = snapshot.token
            self.personId = snapshot.personId
            APIClient.shared.setAuthToken(self.authToken)
        }
    }
    
    // Called after successful auth flow
    func applyLogin(response: LoginResponse) {
        currentUser = response.user
        authToken = response.token
        personId = response.personId

        let snapshot = SessionSnapshot(user: response.user, token: response.token, personId: response.personId)
        sessionStore.save(snapshot: snapshot)

        APIClient.shared.setAuthToken(response.token)
        triggerAuthTransition()
    }

    func applyOverview(_ overview: UserOverview) {
        self.overview = overview
        currentUser = overview.user
        if let token = authToken {
            let snapshot = SessionSnapshot(user: overview.user, token: token, personId: personId)
            sessionStore.save(snapshot: snapshot)
        }
    }

    func applyWalletContext(wallet: Wallet, cards: [Card], balances: Balances?) {
        self.wallet = wallet
        self.cards = cards
        self.balances = balances
    }
    
    func signOut() {
        currentUser = nil
        authToken = nil
        personId = nil
        overview = nil
        wallet = nil
        cards = []
        balances = nil

        sessionStore.clear()
        APIClient.shared.setAuthToken(nil)
        triggerAuthTransition()
    }

    // Replace or insert a card in the cached array.
    func updateCard(_ updated: Card) {
        if let id = updated.id, let index = cards.firstIndex(where: { $0.id == id }) {
            cards[index] = updated
        } else {
            cards.insert(updated, at: 0)
        }
    }

    private func triggerAuthTransition() {
        showAuthTransition = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            withAnimation(.easeInOut(duration: 0.3)) {
                self?.showAuthTransition = false
            }
        }
    }
}
