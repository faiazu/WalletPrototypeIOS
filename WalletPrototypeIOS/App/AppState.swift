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

    private let userDefaults = UserDefaults.standard

    private let tokenKey = "accessToken"
    private let userIdKey = "userId"
    private let userEmailKey = "userEmail"
    
    init() {
        // Load from persistence on app launch (simple version)
        if let token = userDefaults.string(forKey: tokenKey),
           let id = userDefaults.string(forKey: userIdKey),
           let email = userDefaults.string(forKey: userEmailKey) {
            self.currentUser = User(id: id, email: email)
            self.authToken = token
        }
    }
    
    // Called after successful /auth/google
    func applyLogin(response: GoogleLoginResponse) {
        currentUser = response.user
        authToken = response.token

        userDefaults.set(response.token, forKey: tokenKey)
        userDefaults.set(response.user.id, forKey: userIdKey)
        userDefaults.set(response.user.email, forKey: userEmailKey)
    }
    
    func signOut() {
        currentUser = nil
        authToken = nil

        userDefaults.removeObject(forKey: tokenKey)
        userDefaults.removeObject(forKey: userIdKey)
        userDefaults.removeObject(forKey: userEmailKey)
    }
}
