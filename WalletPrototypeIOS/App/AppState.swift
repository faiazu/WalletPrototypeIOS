//
//  AppState.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-15.
//

import Combine

final class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var authToken: String?

    // Later:
    // - An init that tries to load token from Keychain
    // - A logout() method
    // - Maybe some app-wide flags (e.g. hasSeenOnboarding)
}
