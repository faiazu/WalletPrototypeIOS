import XCTest
@testable import WalletPrototypeIOS

@MainActor
final class HomeViewModelTests: XCTestCase {
    func testBootstrapHappyPath() async {
        let appState = AppState(sessionStore: SessionStore())
        appState.applyLogin(response: .fixture) // seed token/user

        let wallet = MockWalletService(bootstrapResponse: .fixture)
        let auth = MockAuthService(loginResponse: .fixture)
        let viewModel = HomeViewModel(appState: appState, walletService: wallet, authService: auth)

        viewModel.load()
        try? await Task.sleep(nanoseconds: 100_000_000) // allow task to finish

        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertEqual(viewModel.wallet?.id, "wallet-123")
    }

    func testStaleTokenRetriesLogin() async {
        let appState = AppState(sessionStore: SessionStore())
        appState.applyLogin(response: .fixture)

        let staleError = APIError.serverError(statusCode: 500, body: "{\"error\":\"UserNotFound\"}")
        let wallet = MockWalletService(bootstrapError: staleError, fallback: .fixture)
        let auth = MockAuthService(loginResponse: .fixture)
        let viewModel = HomeViewModel(appState: appState, walletService: wallet, authService: auth)

        viewModel.load()
        try? await Task.sleep(nanoseconds: 200_000_000) // allow retry to happen

        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertEqual(viewModel.wallet?.id, "wallet-123")
    }
}

// MARK: - Test doubles
private final class MockAuthService: AuthServicing {
    let loginResponse: LoginResponse

    init(loginResponse: LoginResponse) {
        self.loginResponse = loginResponse
    }

    func loginWithGoogle(idToken: String) async throws -> LoginResponse { loginResponse }
    func loginAsChristopher() async throws -> LoginResponse { loginResponse }
}

private final class MockWalletService: WalletServicing {
    let bootstrapResponse: WalletBootstrapResponse
    let bootstrapError: Error?
    let fallbackResponse: WalletBootstrapResponse?

    init(bootstrapResponse: WalletBootstrapResponse, fallback: WalletBootstrapResponse? = nil) {
        self.bootstrapResponse = bootstrapResponse
        self.bootstrapError = nil
        self.fallbackResponse = fallback
    }

    init(bootstrapError: Error, fallback: WalletBootstrapResponse) {
        self.bootstrapResponse = fallback
        self.bootstrapError = bootstrapError
        self.fallbackResponse = fallback
    }

    private var hasFailedOnce = false

    func bootstrap() async throws -> WalletBootstrapResponse {
        if let bootstrapError, !hasFailedOnce {
            hasFailedOnce = true
            throw bootstrapError
        }
        return fallbackResponse ?? bootstrapResponse
    }
}

private extension LoginResponse {
    static var fixture: LoginResponse {
        LoginResponse(
            user: User(id: "user-123", email: "user@example.com", kycStatus: .accepted),
            token: "token-123",
            personId: "person-123"
        )
    }
}

private extension WalletBootstrapResponse {
    static var fixture: WalletBootstrapResponse {
        WalletBootstrapResponse(
            wallet: Wallet(id: "wallet-123", name: "Test", members: nil, adminId: nil, createdAt: nil),
            card: Card(id: "card-123", externalCardId: "ext-123", last4: "1234", status: "ACTIVE", providerName: "TEST", walletId: "wallet-123", userId: "user-123"),
            balances: Balances(poolDisplay: 10, memberEquity: [MemberEquity(userId: "user-123", balance: 5)])
        )
    }
}
