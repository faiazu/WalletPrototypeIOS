import XCTest
@testable import WalletPrototypeIOS

@MainActor
final class AuthViewModelTests: XCTestCase {
    func testDemoLoginHappyPath() async {
        let appState = AppState(sessionStore: SessionStore())
        let auth = MockAuthService(loginResponse: .fixture)
        let wallet = MockWalletService(bootstrapResponse: .fixture)
        let viewModel = AuthViewModel(authService: auth, walletService: wallet)

        await viewModel.loginAsChristopher(appState: appState)

        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertEqual(appState.currentUser?.id, "user-123")
        XCTAssertEqual(appState.wallet?.id, "wallet-123")
    }

    func testDemoLoginError() async {
        let appState = AppState(sessionStore: SessionStore())
        let auth = MockAuthService(loginError: APIError.serverError(statusCode: 400, body: "bad"))
        let wallet = MockWalletService(bootstrapResponse: .fixture)
        let viewModel = AuthViewModel(authService: auth, walletService: wallet)

        await viewModel.loginAsChristopher(appState: appState)

        XCTAssertEqual(viewModel.state, .error(message: viewModel.errorMessage ?? ""))
    }
}

// MARK: - Mocks / fixtures
private final class MockAuthService: AuthServicing {
    let loginResponse: LoginResponse?
    let loginError: Error?

    init(loginResponse: LoginResponse? = nil, loginError: Error? = nil) {
        self.loginResponse = loginResponse
        self.loginError = loginError
    }

    func loginWithGoogle(idToken: String) async throws -> LoginResponse {
        if let loginError { throw loginError }
        return loginResponse ?? .fixture
    }

    func loginAsChristopher() async throws -> LoginResponse {
        if let loginError { throw loginError }
        return loginResponse ?? .fixture
    }
}

private final class MockWalletService: WalletServicing {
    let bootstrapResponse: WalletBootstrapResponse?
    let bootstrapError: Error?

    init(bootstrapResponse: WalletBootstrapResponse? = nil, bootstrapError: Error? = nil) {
        self.bootstrapResponse = bootstrapResponse
        self.bootstrapError = bootstrapError
    }

    func bootstrap() async throws -> WalletBootstrapResponse {
        if let bootstrapError { throw bootstrapError }
        return bootstrapResponse ?? .fixture
    }
}

private extension LoginResponse {
    static var fixture: LoginResponse {
        LoginResponse(
            user: User(id: "user-123", email: "user@example.com", name: "Test User", kycStatus: .accepted),
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
