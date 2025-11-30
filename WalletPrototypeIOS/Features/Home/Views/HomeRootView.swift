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
        ZStack {
            Color(.systemBackground)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HomeHeaderView(appState: appState)

                    if viewModel.isLoading {
                        ProgressView("Loading your wallet...")
                    }

                    if let error = viewModel.errorMessage {
                        StatusBanner(text: error, style: .error)
                            .padding(.vertical, 4)
                    }

                    ActionRowView(
                        createAction: { /* TODO: wire create card */ },
                        joinAction: { /* TODO: wire join card */ }
                    )

                    CardDisplayView(
                        walletName: viewModel.wallet?.name ?? "Groceries",
                        balanceText: viewModel.poolBalanceText,
                        maskedNumber: maskedNumber(from: viewModel.cards.first?.last4),
                        validFrom: "10/25",
                        expires: "10/30",
                        holder: displayName(for: viewModel.cards.first?.user ?? appState.currentUser),
                        chipImageName: "CardChipImage",
                        brandImageName: "MastercardLogo"
                    )

                    SecondaryActionsView(
                        addMoneyAction: { /* TODO: wire add money */ },
                        settingsAction: { router.goToCardSettings() }
                    )

                    MembersSectionView(members: memberRows())

                    DebugStatusView(message: viewModel.errorMessage ?? "Using demo data; API not fully wired.")
                }
                .padding()
            }
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
    func memberRows() -> [MemberRowModel] {
        if let members = viewModel.wallet?.members, !members.isEmpty {
            return members.map {
                let amount = viewModel.memberEquityText
                return MemberRowModel(
                    name: displayName(for: $0.user),
                    role: $0.role ?? "Member",
                    status: "Active",
                    amount: amount
                )
            }
        }

        return [
            MemberRowModel(name: displayName(for: appState.currentUser), role: "Admin", status: "Active", amount: viewModel.memberEquityText),
            MemberRowModel(name: "Michael", role: "Member", status: "Active", amount: CurrencyFormatter.string(from: 33.25)),
            MemberRowModel(name: "Simon", role: "Member", status: "Active", amount: CurrencyFormatter.string(from: 12.13))
        ]
    }

    func maskedNumber(from last4: String?) -> String {
        let suffix = last4 ?? "7641"
        return "**** **** **** \(suffix)"
    }

    func displayName(for user: User?) -> String {
        if let name = user?.name, !name.isEmpty {
            return name
        }
        if let email = user?.email {
            let base = email.split(separator: "@").first ?? Substring(email)
            let parts = base.split(separator: ".").map { $0.capitalized }
            if !parts.isEmpty {
                return parts.joined(separator: " ")
            }
            return String(base)
        }
        return "You"
    }
}
