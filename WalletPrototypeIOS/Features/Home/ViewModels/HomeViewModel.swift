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
    @Published var wallet: Wallet?
    @Published var card: Card?
    @Published var balances: Balances?
    @Published var state: ScreenState = .idle
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let appState: AppState
    private let walletService: WalletServicing
    private let authService: AuthServicing

    init(
        appState: AppState,
        walletService: WalletServicing? = nil,
        authService: AuthServicing? = nil
    ) {
        self.appState = appState
        self.walletService = walletService ?? WalletService.shared
        self.authService = authService ?? AuthService.shared

        self.wallet = appState.wallet
        self.card = appState.card
        self.balances = appState.balances
    }

    var hasBootstrap: Bool {
        wallet != nil && card != nil && balances != nil
    }

    var poolBalanceText: String {
        formatCurrency(balances?.poolDisplay)
    }

    var memberEquityText: String {
        guard let entries = balances?.memberEquity else { return "—" }

        if let userId = appState.currentUser?.id,
           let match = entries.first(where: { $0.userId == userId }) {
            return formatCurrency(match.balance)
        }

        if let first = entries.first {
            return formatCurrency(first.balance)
        }

        return "—"
    }

    func loadIfNeeded() {
        guard !hasBootstrap else { return }
        load()
    }

    func load() {
        guard !isLoading else { return }
        guard appState.authToken != nil else {
            errorMessage = "Not logged in."
            return
        }

        Task {
            isLoading = true
            errorMessage = nil
            state = .loading(message: "Loading your wallet...")

            defer { isLoading = false }

            do {
                let bootstrap = try await walletService.bootstrap()
                apply(bootstrap)
                state = .loaded

            } catch {
                if Task.isCancelled { return }
                _ = await handleBootstrapError(error)
            }
        }
    }

    func signOut() {
        appState.signOut()
    }

    private func apply(_ bootstrap: WalletBootstrapResponse) {
        wallet = bootstrap.wallet
        card = bootstrap.card
        balances = bootstrap.balances

        appState.applyBootstrap(bootstrap)
    }

    private func handleBootstrapError(_ error: Error) async -> Bool {
        if let apiError = error as? APIError {
            switch apiError {
            case let .serverError(status, body):
                if status == 401 || status == 403 {
                    errorMessage = "Session expired. Please sign in again."
                    state = .error(message: errorMessage ?? "Session expired.")
                    appState.signOut()
                    return false
                }

                // DB reset / stale token cases: auto re-login and retry bootstrap once.
                if isUserNotFound(body) || body?.localizedCaseInsensitiveContains("foreign key constraint") == true {
                    return await retryFreshLoginAndBootstrap()
                }

                errorMessage = ErrorMessageMapper.parsedServerMessage(from: body) ?? apiError.localizedDescription
                state = .error(message: errorMessage ?? apiError.localizedDescription)
                return false

            default:
                errorMessage = apiError.localizedDescription
                state = .error(message: errorMessage ?? apiError.localizedDescription)
                return false
            }
        }

        errorMessage = error.localizedDescription
        state = .error(message: errorMessage ?? error.localizedDescription)
        return false
    }

    private func isUserNotFound(_ body: String?) -> Bool {
        guard let body = body?.lowercased() else { return false }
        return body.contains("usernotfound") || body.contains("user_not_found")
    }

    private func retryFreshLoginAndBootstrap() async -> Bool {
        do {
            appState.signOut()
            let loginResponse = try await authService.loginAsChristopher()
            appState.applyLogin(response: loginResponse)

            let bootstrap = try await walletService.bootstrap()
            apply(bootstrap)
            errorMessage = nil
            state = .loaded
            return true
        } catch {
            errorMessage = "Session reset. Please try signing in again."
            state = .error(message: errorMessage ?? "Session reset.")
            appState.signOut()
            return false
        }
    }

    private func formatCurrency(_ amount: Double?) -> String {
        return CurrencyFormatter.string(from: amount)
    }
}
