//
//  HomeRootView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-19.
//

import SwiftUI

struct HomeRootView: View {
    @ObservedObject var appState: AppState
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject private var router: Router

    init(appState: AppState) {
        _appState = ObservedObject(wrappedValue: appState)
        _viewModel = StateObject(wrappedValue: HomeViewModel(appState: appState))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                if viewModel.isLoading {
                    ProgressView("Loading your wallet...")
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                        .padding(.vertical, 4)
                }

                walletCardSection

                balancesSection

                actionsSection
            }
            .padding()
        }
        .onAppear {
            viewModel.loadIfNeeded()
        }
    }
}

#Preview {
    HomeRootView(appState: AppState())
        .environmentObject(Router())
}

private extension HomeRootView {
    var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(viewModel.wallet?.name ?? "Wallet Dashboard")
                .font(.largeTitle)
                .bold()

            if let email = appState.currentUser?.email {
                Text(email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    var walletCardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Wallet", systemImage: "wallet.pass")
                    .font(.headline)
                Spacer()
                if let memberCount = viewModel.wallet?.members?.count {
                    Text("\(memberCount) member\(memberCount == 1 ? "" : "s")")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            if let wallet = viewModel.wallet {
                Text(wallet.name ?? "Default wallet")
                    .font(.title3.weight(.semibold))
            }

            Divider()

            if let card = viewModel.card {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Card")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(card.maskedDisplay)
                        .font(.title3.monospacedDigit())
                    if let status = card.status {
                        Text("Status: \(status)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Text("Card details not available yet.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    var balancesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Balances")
                .font(.headline)

            HStack(spacing: 12) {
                balanceTile(title: "Pool", value: viewModel.poolBalanceText)
                balanceTile(title: "Your equity", value: viewModel.memberEquityText)
            }
        }
    }

    func balanceTile(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    var actionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                viewModel.load()
            } label: {
                Label("Refresh data", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)

            Button {
                router.goToWallet()
            } label: {
                Label("Open wallet", systemImage: "rectangle.grid.2x2")
            }
            .buttonStyle(.bordered)

            Button(role: .destructive) {
                viewModel.signOut()
            } label: {
                Label("Sign out", systemImage: "rectangle.portrait.and.arrow.right")
            }
            .buttonStyle(.borderless)
            .padding(.top, 6)
        }
        .padding(.top, 4)
    }
}
