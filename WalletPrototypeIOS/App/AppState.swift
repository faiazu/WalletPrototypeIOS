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

    private let userDefaults = UserDefaults.standard

    private let tokenKey = "accessToken"
    private let userIdKey = "userId"
    private let userEmailKey = "userEmail"
    private let userKycStatusKey = "userKycStatus"
    private let personIdKey = "personId"
    
    init() {
        // Load from persistence on app launch (simple version)
        if let token = userDefaults.string(forKey: tokenKey),
           let id = userDefaults.string(forKey: userIdKey),
           let email = userDefaults.string(forKey: userEmailKey) {

            let storedKYC = userDefaults.string(forKey: userKycStatusKey)
            let kycStatus = storedKYC.flatMap { KYCStatus(rawValue: $0) ?? .unknown }
            let storedPersonId = userDefaults.string(forKey: personIdKey)

            self.currentUser = User(id: id, email: email, kycStatus: kycStatus)
            self.authToken = token
            self.personId = storedPersonId
            APIClient.shared.setAuthToken(token)
        }
    }
    
    // Called after successful auth flow
    func applyLogin(response: LoginResponse) {
        currentUser = response.user
        authToken = response.token
        personId = response.personId

        userDefaults.set(response.token, forKey: tokenKey)
        userDefaults.set(response.user.id, forKey: userIdKey)
        userDefaults.set(response.user.email, forKey: userEmailKey)
        if let kycRaw = response.user.kycStatus?.rawValue {
            userDefaults.set(kycRaw, forKey: userKycStatusKey)
        } else {
            userDefaults.removeObject(forKey: userKycStatusKey)
        }
        if let personId = response.personId {
            userDefaults.set(personId, forKey: personIdKey)
        } else {
            userDefaults.removeObject(forKey: personIdKey)
        }

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

        userDefaults.removeObject(forKey: tokenKey)
        userDefaults.removeObject(forKey: userIdKey)
        userDefaults.removeObject(forKey: userEmailKey)
        userDefaults.removeObject(forKey: userKycStatusKey)
        userDefaults.removeObject(forKey: personIdKey)
        APIClient.shared.setAuthToken(nil)
    }
}
