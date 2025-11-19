//
//  HomeViewModel.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-19.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var me: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let appState: AppState
    private let userService: UserService

    init(appState: AppState, userService: UserService? = nil) {
        self.appState = appState
        self.userService = userService ?? UserService.shared
    }

    func load() {
        guard let token = appState.authToken else {
            errorMessage = "Not logged in."
            return
        }

        Task {
            do {
                isLoading = true
                errorMessage = nil

                let user = try await userService.fetchCurrentUser(authToken: token)
                self.me = user   // this is who backend thinks user is

            } catch {
                errorMessage = "Failed to load /me: \(error)"
            }
            isLoading = false
        }
    }

    func signOut() {
        appState.signOut()
    }
}
