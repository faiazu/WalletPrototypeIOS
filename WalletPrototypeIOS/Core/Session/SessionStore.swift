//
//  SessionStore.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import Foundation

struct SessionSnapshot {
    let user: User
    let token: String
    let personId: String?
}

/// Persists and restores lightweight session info (token + user identifiers).
final class SessionStore {
    static let shared = SessionStore()
    /// Internal init so tests can provide an in-memory UserDefaults if needed.
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    private let userDefaults: UserDefaults

    private let tokenKey = "accessToken"
    private let userIdKey = "userId"
    private let userEmailKey = "userEmail"
    private let userNameKey = "userName"
    private let userKycStatusKey = "userKycStatus"
    private let personIdKey = "personId"

    func load() -> SessionSnapshot? {
        guard
            let token = userDefaults.string(forKey: tokenKey),
            let id = userDefaults.string(forKey: userIdKey),
            let email = userDefaults.string(forKey: userEmailKey)
        else {
            return nil
        }

        let name = userDefaults.string(forKey: userNameKey)
        let storedKyc = userDefaults.string(forKey: userKycStatusKey)
        let kycStatus = storedKyc.flatMap { KYCStatus(rawValue: $0) ?? .unknown }
        let personId = userDefaults.string(forKey: personIdKey)

        let user = User(id: id, email: email, name: name, kycStatus: kycStatus)
        return SessionSnapshot(user: user, token: token, personId: personId)
    }

    func save(snapshot: SessionSnapshot) {
        userDefaults.set(snapshot.token, forKey: tokenKey)
        userDefaults.set(snapshot.user.id, forKey: userIdKey)
        userDefaults.set(snapshot.user.email, forKey: userEmailKey)
        userDefaults.set(snapshot.user.name, forKey: userNameKey)
        userDefaults.set(snapshot.user.kycStatus?.rawValue, forKey: userKycStatusKey)
        if let personId = snapshot.personId {
            userDefaults.set(personId, forKey: personIdKey)
        } else {
            userDefaults.removeObject(forKey: personIdKey)
        }
    }

    func clear() {
        userDefaults.removeObject(forKey: tokenKey)
        userDefaults.removeObject(forKey: userIdKey)
        userDefaults.removeObject(forKey: userEmailKey)
        userDefaults.removeObject(forKey: userNameKey)
        userDefaults.removeObject(forKey: userKycStatusKey)
        userDefaults.removeObject(forKey: personIdKey)
    }
}
