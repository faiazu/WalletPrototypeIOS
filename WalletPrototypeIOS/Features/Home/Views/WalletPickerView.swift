//
//  WalletPickerView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-12-02.
//

import SwiftUI

struct WalletPickerView: View {
    let title: String
    let wallets: [UserOverview.WalletSummary]
    let selectedWalletId: String?
    let onSelect: (String) -> Void
    let onCreate: () -> Void

    private let accent = Color(hex: "1A3EEC")

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Circle()
                    .fill(accent.opacity(0.15))
                    .frame(width: 28, height: 28)
                    .overlay(Text("💼").font(.footnote))

                Text("Wallet")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(bubbleOverlay)
                    .shadow(color: Color.black.opacity(0.08), radius: 10, y: 4)

                HStack(spacing: 12) {
                    Menu {
                        ForEach(wallets) { wallet in
                            Button {
                                onSelect(wallet.id)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(wallet.name ?? "Wallet")
                                        if let role = wallet.role {
                                            Text(role.capitalized)
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    Spacer()
                                    if wallet.id == selectedWalletId {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(accent)
                                    }
                                }
                            }
                        }

                        if !wallets.isEmpty {
                            Divider()
                        }

                        Button {
                            onCreate()
                        } label: {
                            Label("Create new wallet", systemImage: "plus.circle")
                        }
                    } label: {
                        HStack(alignment: .center, spacing: 8) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(title)
                                    .font(.title3.bold())
                                    .foregroundStyle(.primary)
                                Text("Tap to switch")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.down")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }

                    Button(action: onCreate) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(accent)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(accent.opacity(0.15))
                            )
                    }
                    .accessibilityLabel("Create wallet")
                    .padding(.trailing, 6)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(accent.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }

    private var bubbleOverlay: some View {
        ZStack {
            Circle()
                .fill(accent.opacity(0.2))
                .frame(width: 120, height: 120)
                .offset(x: -80, y: -40)
                .blur(radius: 20)
            Circle()
                .fill(Color.purple.opacity(0.18))
                .frame(width: 90, height: 90)
                .offset(x: 80, y: 30)
                .blur(radius: 15)
        }
    }
}

#Preview {
    WalletPickerView(
        title: "Household",
        wallets: [
            .init(id: "1", name: "Household", role: "admin", isAdmin: true, memberCount: 3, cardCount: 2, hasCardForCurrentUser: true, joinedAt: nil, createdAt: nil),
            .init(id: "2", name: "Travel", role: "member", isAdmin: false, memberCount: 2, cardCount: 1, hasCardForCurrentUser: false, joinedAt: nil, createdAt: nil)
        ],
        selectedWalletId: "1",
        onSelect: { _ in },
        onCreate: {}
    )
    .padding()
}
