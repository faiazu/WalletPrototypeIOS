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
                    maskedNumber: maskedNumber(from: viewModel.card?.last4),
                    validFrom: "10/25",
                    expires: "10/30",
                    holder: appState.currentUser?.email ?? "Will Jonas",
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
                    name: $0.user?.email ?? "Member",
                    role: $0.role ?? "Member",
                    status: "Active",
                    amount: amount
                )
            }
        }

        return [
            MemberRowModel(name: appState.currentUser?.email ?? "You", role: "Admin", status: "Active", amount: viewModel.memberEquityText),
            MemberRowModel(name: "Michael", role: "Member", status: "Active", amount: CurrencyFormatter.string(from: 33.25)),
            MemberRowModel(name: "Simon", role: "Member", status: "Active", amount: CurrencyFormatter.string(from: 12.13))
        ]
    }

    func maskedNumber(from last4: String?) -> String {
        let suffix = last4 ?? "7641"
        return "**** **** **** \(suffix)"
    }
}
