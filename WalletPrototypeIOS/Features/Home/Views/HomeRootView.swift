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
                    StatusBanner(text: error, style: .error)
                        .padding(.vertical, 4)
                }

                createJoinRow
                cardCarousel
                actionRow
                membersSection
                debugSection
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

    var createJoinRow: some View {
        HStack(spacing: 12) {
            Button {
                // Placeholder: hook API when available
            } label: {
                Label("Create New Card", systemImage: "plus.circle")
            }
            .buttonStyle(PrimaryButtonStyle())

            Button {
                // Placeholder: hook API when available
            } label: {
                Label("Join Card", systemImage: "person.badge.plus")
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }

    var cardCarousel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.wallet?.name ?? "Groceries")
                .font(.title3.bold())
            TabView {
                ForEach(displayCards(), id: \.displayId) { card in
                    cardHero(card: card)
                }
            }
            .frame(height: 200)
            .tabViewStyle(.page(indexDisplayMode: .automatic))
        }
    }

    var actionRow: some View {
        HStack(spacing: 12) {
            Button {
                // Placeholder: hook API when available
            } label: {
                Label("Add Money", systemImage: "arrow.down.circle")
            }
            .buttonStyle(PrimaryButtonStyle())

            Button {
                router.goToCardSettings()
            } label: {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }

    var membersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Members")
                .font(.headline)

            ForEach(memberRows(), id: \.id) { member in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(member.name)
                            .font(.body.weight(.semibold))
                        Text(member.role)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(member.status)
                            .font(.caption.bold())
                            .foregroundStyle(member.status.lowercased() == "active" ? .green : .red)
                        Text(member.amount)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    var debugSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Debug / Status")
                .font(.caption)
                .foregroundStyle(.secondary)
            StatusBanner(text: viewModel.errorMessage ?? "Using demo data; API not fully wired.", style: .info)
        }
    }

    func cardHero(card: Card) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(LinearGradient(colors: [.blue, Color.purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(radius: 6, y: 4)

            VStack(alignment: .leading, spacing: 10) {
                Text("Available Balance")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                Text(viewModel.poolBalanceText)
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                Text(card.maskedDisplay)
                    .font(.body.monospacedDigit())
                    .foregroundStyle(.white)

                Text(appState.currentUser?.email ?? "Card Holder")
                    .font(.footnote.bold())
                    .foregroundStyle(.white)
            }
            .padding(16)
        }
        .padding(.horizontal, 4)
    }

    struct MemberRow: Identifiable {
        let id = UUID()
        let name: String
        let role: String
        let status: String
        let amount: String
    }

    func memberRows() -> [MemberRow] {
        if let members = viewModel.wallet?.members, !members.isEmpty {
            return members.map {
                let amount = viewModel.memberEquityText
                return MemberRow(
                    name: $0.user?.email ?? "Member",
                    role: $0.role ?? "Member",
                    status: "Active",
                    amount: amount
                )
            }
        }

        return [
            MemberRow(name: appState.currentUser?.email ?? "You", role: "Admin", status: "Active", amount: viewModel.memberEquityText),
            MemberRow(name: "Michael", role: "Member", status: "Active", amount: CurrencyFormatter.string(from: 33.25)),
            MemberRow(name: "Simon", role: "Member", status: "Active", amount: CurrencyFormatter.string(from: 12.13))
        ]
    }

    func displayCards() -> [Card] {
        if let card = viewModel.card {
            return [card]
        }
        return [
            Card(id: "placeholder", externalCardId: "placeholder", last4: "8635", status: "ACTIVE", providerName: "Demo", walletId: viewModel.wallet?.id, userId: appState.currentUser?.id)
        ]
    }
}
