//
//  DashboardPlaceholderView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import SwiftUI

/// Dashboard placeholder inspired by the target design. Uses live data when available, otherwise falls back to safe placeholders.
struct DashboardPlaceholderView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                cardHero
                actionsRow
                membersList
                debugSection
            }
            .padding()
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension DashboardPlaceholderView {
    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(appState.wallet?.name ?? "Groceries")
                    .font(.title2.bold())
                if let email = appState.currentUser?.email {
                    Text(email)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Image(systemName: "bell.badge.fill")
                .font(.title3)
                .foregroundStyle(.red)
        }
    }

    var cardHero: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(LinearGradient(colors: [.blue, Color.purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 180)
                .shadow(radius: 6, y: 4)

            VStack(alignment: .leading, spacing: 10) {
                Text("Available Balance")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                Text(formattedBalance(appState.balances?.poolDisplay ?? 4228.76))
                    .font(.title2.bold())
                    .foregroundStyle(.white)

                // Use the first available card's last4 if present
                Text(maskedCard(appState.cards.first?.last4 ?? "8635"))
                    .font(.body.monospacedDigit())
                    .foregroundStyle(.white)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Card Holder")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.7))
                        Text(appState.currentUser?.email ?? "Will Jonas")
                            .font(.footnote.bold())
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Image(systemName: "creditcard.fill")
                        .foregroundStyle(.yellow)
                }
            }
            .padding(16)
        }
    }

    var actionsRow: some View {
        HStack(spacing: 12) {
            actionChip(title: "Add money", icon: "plus.circle")
            actionChip(title: "Settings", icon: "gearshape.fill")
            actionChip(title: "Create Card", icon: "creditcard.fill")
        }
    }

    func actionChip(title: String, icon: String) -> some View {
        Button {
            // Placeholder actions; hook API later.
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    var membersList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Members")
                .font(.headline)

            if let members = appState.wallet?.members, !members.isEmpty {
                ForEach(members, id: \.userId) { member in
                    memberRow(name: member.user?.email ?? "Member", role: member.role ?? "member", amount: nil)
                }
            } else {
                memberRow(name: appState.currentUser?.email ?? "You", role: "Admin", amount: appState.balances?.memberEquity?.first?.balance)
                memberRow(name: "Michael", role: "Member", amount: 33.25)
                memberRow(name: "Simon", role: "Member", amount: 12.13)
            }
        }
    }

    func memberRow(name: String, role: String, amount: Double?) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.body.weight(.semibold))
                Text(role.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(formattedBalance(amount ?? 0, showCurrency: true))
                .font(.body.monospacedDigit())
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    var debugSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Debug / Status")
                .font(.caption)
                .foregroundStyle(.secondary)
            StatusBanner(text: "Dashboard placeholder; real APIs not wired yet.", style: .info)
        }
    }

    func formattedBalance(_ amount: Double, showCurrency: Bool = true) -> String {
        if showCurrency {
            return CurrencyFormatter.string(from: amount)
        }
        return String(format: "%.2f", amount)
    }

    func maskedCard(_ last4: String) -> String {
        return "•••• •••• •••• \(last4)"
    }
}

#Preview {
    NavigationStack {
        DashboardPlaceholderView(appState: AppState())
    }
}
