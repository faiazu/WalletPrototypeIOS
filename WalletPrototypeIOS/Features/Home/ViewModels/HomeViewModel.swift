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
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let appState: AppState
    private let walletService: WalletService
    private let authService: AuthService

    init(
        appState: AppState,
        walletService: WalletService? = nil,
        authService: AuthService? = nil
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

            defer { isLoading = false }

            do {
                let bootstrap = try await walletService.bootstrap()
                apply(bootstrap)

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
                    appState.signOut()
                    return false
                }

                // DB reset / stale token cases: auto re-login and retry bootstrap once.
                if isUserNotFound(body) || body?.localizedCaseInsensitiveContains("foreign key constraint") == true {
                    return await retryFreshLoginAndBootstrap()
                }

                errorMessage = parsedServerMessage(from: body) ?? apiError.localizedDescription
                return false

            default:
                errorMessage = apiError.localizedDescription
                return false
            }
        }

        errorMessage = error.localizedDescription
        return false
    }

    private func parsedServerMessage(from body: String?) -> String? {
        guard let body, !body.isEmpty else { return nil }

        if let data = body.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let message = json["error"] as? String {
            return message
        }

        return body
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
            return true
        } catch {
            errorMessage = "Session reset. Please try signing in again."
            appState.signOut()
            return false
        }
    }

    private func formatCurrency(_ amount: Double?) -> String {
        guard let amount else { return "—" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}
