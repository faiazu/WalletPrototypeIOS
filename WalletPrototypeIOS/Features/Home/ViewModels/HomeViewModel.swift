//
//  HomeViewModel.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-19.
//

import Foundation
import Combine

/// Orchestrates loading the overview, active wallet, balances, and cards for the Home screen.
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var wallet: Wallet?
    @Published var balances: Balances?
    @Published var cards: [Card] = []
    @Published var overview: UserOverview?
    @Published var wallets: [UserOverview.WalletSummary] = []
    @Published var selectedWalletId: String?
    @Published var showOnboarding = false
    @Published var state: ScreenState = .idle
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var statusMessage: String?

    private let appState: AppState
    private let walletService: WalletServicing
    private let cardService: CardServicing
    private let userService: UserServicing
    private let authService: AuthServicing

    init(
        appState: AppState,
        walletService: WalletServicing? = nil,
        cardService: CardServicing? = nil,
        userService: UserServicing? = nil,
        authService: AuthServicing? = nil
    ) {
        self.appState = appState
        self.walletService = walletService ?? WalletService.shared
        self.cardService = cardService ?? CardService.shared
        self.userService = userService ?? UserService.shared
        self.authService = authService ?? AuthService.shared

        self.wallet = appState.wallet
        self.cards = appState.cards
        self.balances = appState.balances
        self.overview = appState.overview
        self.wallets = appState.overview?.wallets ?? []
        self.selectedWalletId = appState.wallet?.id ?? appState.overview?.firstWalletId
        self.showOnboarding = !(appState.overview?.hasWallets ?? (appState.wallet != nil))
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

    var kycRequired: Bool {
        overview?.requirements.kycRequired ?? false
    }

    var selectedWalletName: String? {
        wallets.first(where: { $0.id == selectedWalletId })?.name
    }

    func loadIfNeeded() {
        guard !isLoading else { return }
        guard appState.authToken != nil else {
            errorMessage = "Not logged in."
            state = .error(message: errorMessage ?? "Not logged in.")
            return
        }

        Task {
            await loadOverviewAndWallet()
        }
    }

    func load() {
        loadIfNeeded()
    }

    func refresh() {
        loadIfNeeded()
    }

    func selectWallet(id: String) {
        guard id != selectedWalletId else { return }
        selectedWalletId = id
        Task {
            await loadOverviewAndWallet(focusWalletId: id)
        }
    }

    func createWallet(named name: String) async {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Wallet name cannot be empty."
            return
        }

        if kycRequired {
            errorMessage = "Complete KYC before creating a wallet."
            return
        }

        guard !isLoading else { return }

        statusMessage = "Creating wallet..."
        errorMessage = nil
        isLoading = true

        do {
            let wallet = try await walletService.createWallet(name: trimmed)
            await loadOverviewAndWallet(focusWalletId: wallet.id)
            statusMessage = nil
        } catch {
            handleActionError(error)
        }

        isLoading = false
    }

    func joinWallet(withId walletId: String) async {
        let trimmed = walletId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Wallet ID or invite code required."
            return
        }

        guard !isLoading else { return }

        statusMessage = "Joining wallet..."
        errorMessage = nil
        isLoading = true

        do {
            let wallet = try await walletService.joinWallet(walletId: trimmed)
            await loadOverviewAndWallet(focusWalletId: wallet.id)
            statusMessage = nil
        } catch {
            handleActionError(error)
        }

        isLoading = false
    }

    func createCard(nickname: String?) async {
        guard let walletId = selectedWalletId ?? wallet?.id else {
            errorMessage = "Select a wallet before creating a card."
            return
        }

        guard !isLoading else { return }

        statusMessage = "Issuing card..."
        errorMessage = nil
        isLoading = true

        do {
            let trimmed = nickname?.trimmingCharacters(in: .whitespacesAndNewlines)
            _ = try await cardService.createCard(walletId: walletId, nickname: trimmed)
            statusMessage = "Refreshing cards..."
            await loadOverviewAndWallet(focusWalletId: walletId)
            statusMessage = "Card created."
        } catch {
            handleActionError(error)
        }

        isLoading = false
    }

    func signOut() {
        appState.signOut()
    }
}

// MARK: - Private helpers
private extension HomeViewModel {
    func loadOverviewAndWallet(focusWalletId: String? = nil) async {
        guard !Task.isCancelled else { return }

        isLoading = true
        errorMessage = nil
        state = .loading(message: "Loading your wallet...")

        defer { isLoading = false }

        do {
            let fetchedOverview = try await userService.fetchOverview()
            let resolvedWalletId = resolveSelectedWalletId(
                overview: fetchedOverview,
                focusWalletId: focusWalletId
            )
            applyOverview(fetchedOverview, selectedId: resolvedWalletId)

            guard fetchedOverview.hasWallets, let walletId = resolvedWalletId else {
                showOnboarding = true
                clearWalletData()
                state = .loaded
                return
            }

            let details = try await walletService.fetchWalletDetails(walletId: walletId)
            let cardsResponse = try await cardService.listCards(walletId: walletId)
            applyWallet(details: details, cards: cardsResponse)

            showOnboarding = false
            state = .loaded
        } catch {
            if Task.isCancelled { return }
            _ = await handleLoadError(error)
        }
    }

    func applyOverview(_ overview: UserOverview, selectedId: String?) {
        self.overview = overview
        wallets = overview.wallets
        selectedWalletId = selectedId
        appState.applyOverview(overview)
    }

    func applyWallet(details: WalletDetailsResponse, cards: [Card]) {
        wallet = details.wallet
        balances = details.balances
        self.cards = cards
        appState.applyWalletContext(wallet: details.wallet, cards: cards, balances: details.balances)
    }

    func clearWalletData() {
        wallet = nil
        balances = nil
        cards = []
        selectedWalletId = nil
        appState.wallet = nil
        appState.cards = []
        appState.balances = nil
    }

    func handleActionError(_ error: Error) {
        statusMessage = nil
        errorMessage = ErrorMessageMapper.message(for: error)

        if isKycRequired(error) {
            errorMessage = "Complete KYC before continuing."
        }
    }

    func handleLoadError(_ error: Error) async -> Bool {
        if let apiError = error as? APIError {
            switch apiError {
            case let .serverError(status, body):
                if status == 401 || status == 403 {
                    errorMessage = "Session expired. Please sign in again."
                    state = .error(message: errorMessage ?? "Session expired.")
                    appState.signOut()
                    return false
                }

                if isUserNotFound(body) {
                    return await retryFreshLoginAndReload()
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

    func retryFreshLoginAndReload() async -> Bool {
        do {
            appState.signOut()
            let loginResponse = try await authService.loginAsChristopher()
            appState.applyLogin(response: loginResponse)
            await loadOverviewAndWallet()
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

    func isUserNotFound(_ body: String?) -> Bool {
        guard let body = body?.lowercased() else { return false }
        return body.contains("usernotfound") || body.contains("user_not_found")
    }

    func isKycRequired(_ error: Error) -> Bool {
        guard case let .serverError(_, body) = error as? APIError else { return false }
        let lowered = body?.lowercased() ?? ""
        return lowered.contains("kycrequired") || lowered.contains("kyc_required")
    }

    func resolveSelectedWalletId(overview: UserOverview, focusWalletId: String?) -> String? {
        let availableIds = overview.wallets.map { $0.id }

        if let focus = focusWalletId, availableIds.contains(focus) {
            return focus
        }

        if let current = selectedWalletId, availableIds.contains(current) {
            return current
        }

        return overview.firstWalletId
    }

    func formatCurrency(_ amount: Double?) -> String {
        CurrencyFormatter.string(from: amount)
    }
}
