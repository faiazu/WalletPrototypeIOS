//
//  AppState.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-15.
//

import Foundation
import Combine

final class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var authToken: String?
    @Published var personId: String?
    @Published var wallet: Wallet?
    @Published var card: Card?
    @Published var balances: Balances?

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
    }

    func applyBootstrap(_ bootstrap: WalletBootstrapResponse) {
        wallet = bootstrap.wallet
        card = bootstrap.card
        balances = bootstrap.balances
    }
    
    func signOut() {
        currentUser = nil
        authToken = nil
        personId = nil
        wallet = nil
        card = nil
        balances = nil

        sessionStore.clear()
        APIClient.shared.setAuthToken(nil)
    }
}
