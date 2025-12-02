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
    @State private var showCreateSheet = false
    @State private var showJoinSheet = false
    @State private var showCreateCardSheet = false
    @State private var selectedCardId: String?

    init(appState: AppState) {
        _appState = ObservedObject(wrappedValue: appState)
        _viewModel = StateObject(wrappedValue: HomeViewModel(appState: appState))
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if viewModel.showOnboarding {
                        NoWalletsView(
                            user: appState.currentUser ?? viewModel.overview?.user,
                            requirements: viewModel.overview?.requirements,
                            isBusy: viewModel.isLoading,
                            onCreate: { showCreateSheet = true },
                            onJoin: { showJoinSheet = true }
                        )
                    } else {
                        HomeHeaderView(appState: appState)
                        
                        WalletPickerView(
                            title: viewModel.selectedWalletName ?? viewModel.wallet?.name ?? "Select Wallet",
                            wallets: viewModel.wallets,
                            selectedWalletId: viewModel.selectedWalletId,
                            onSelect: { id in viewModel.selectWallet(id: id) },
                            onCreate: { showCreateSheet = true }
                        )

                        if viewModel.isLoading {
                            ProgressView("Loading your wallet...")
                        }

                        if let error = viewModel.errorMessage {
                            StatusBanner(text: error, style: .error)
                                .padding(.vertical, 4)
                        }

                        ActionRowView(
                            createAction: { showCreateCardSheet = true },
                            joinAction: { showJoinSheet = true }
                        )

                        if !viewModel.cards.isEmpty {
                            CardCarouselView(
                                cards: viewModel.cards,
                                walletName: viewModel.wallet?.name,
                                balanceText: viewModel.poolBalanceText,
                                chipImageName: "CardChipImage",
                                brandImageName: "MastercardLogo",
                                holderForCard: { card in
                                    displayName(for: card.user ?? appState.currentUser)
                                },
                                selectedCardId: $selectedCardId
                            )
                        } else {
                            NoCardPlaceholderView()
                        }

                        SecondaryActionsView(
                            addMoneyAction: { /* TODO: wire add money */ },
                            settingsAction: {
                                bringSelectedCardToFront()
                                router.goToCardSettings()
                            }
                        )

                        MembersSectionView(members: memberRows())
                    }

                    DebugStatusView(message: viewModel.statusMessage ?? viewModel.errorMessage ?? "Using demo data; API not fully wired.")
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.loadIfNeeded()
            selectedCardId = selectedCardId ?? appState.cards.first?.displayId ?? viewModel.cards.first?.displayId
        }
        .sheet(isPresented: $showCreateSheet) {
            WalletEntrySheet(mode: .create, isBusy: viewModel.isLoading) { name in
                await viewModel.createWallet(named: name)
            }
        }
        .sheet(isPresented: $showJoinSheet) {
            WalletEntrySheet(mode: .join, isBusy: viewModel.isLoading) { walletId in
                await viewModel.joinWallet(withId: walletId)
            }
        }
        .sheet(isPresented: $showCreateCardSheet) {
            CardNicknameSheet(isBusy: viewModel.isLoading) { nickname in
                await viewModel.createCard(nickname: nickname)
            }
        }
        .onChange(of: viewModel.cards) { _ in
            selectedCardId = selectedCardId ?? viewModel.cards.first?.displayId
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

    /// Ensures the currently selected card is first before navigating to settings.
    func bringSelectedCardToFront() {
        guard let selectedId = selectedCardId,
              let index = viewModel.cards.firstIndex(where: { $0.displayId == selectedId }) else {
            return
        }
        var cards = viewModel.cards
        let card = cards.remove(at: index)
        cards.insert(card, at: 0)
        viewModel.cards = cards
        appState.cards = cards
    }
}
