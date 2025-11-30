//
//  CardSettingsPlaceholderView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import SwiftUI

/// Placeholder card settings screen. Displays card summary and mock settings actions.
struct CardSettingsPlaceholderView: View {
    @ObservedObject var appState: AppState
    @EnvironmentObject var router: Router

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                cardSummary
                statusRow
                settingsList
                debugSection
            }
            .padding()
        }
        .navigationTitle("Card Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension CardSettingsPlaceholderView {
    var cardSummary: some View {
        CardDisplayView(
            walletName: appState.wallet?.name ?? "Groceries",
            balanceText: CurrencyFormatter.string(from: appState.balances?.poolDisplay ?? 0),
            maskedNumber: maskedCard(appState.cards.first?.last4 ?? "7641"),
            validFrom: "10/25",
            expires: "10/30",
            holder: displayName(for: appState.cards.first?.user ?? appState.currentUser),
            chipImageName: "CardChipImage",
            brandImageName: "MastercardLogo"
        )
    }

    var statusRow: some View {
        HStack {
            Text("Card Status")
                .font(.headline)
            Spacer()
            Text(cardStatusText)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(cardStatusColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(cardStatusColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    var cardStatusText: String {
        appState.cards.first?.status ?? "Active"
    }

    var cardStatusColor: Color {
        // Simple mapping; adjust as needed for your statuses
        switch (appState.cards.first?.status ?? "Active").lowercased() {
        case "active": return .green
        case "locked": return .orange
        case "inactive", "deactivated", "disabled": return .red
        default: return .secondary
        }
    }

    var settingsList: some View {
        VStack(spacing: 12) {
            settingsRow(title: "Change Pin", icon: "lock.rotation")
            settingsRow(title: "Lock Card", icon: "lock.fill", trailing: AnyView(Toggle("", isOn: .constant(false)).labelsHidden()))
            settingsRow(title: "Deactivate Card", icon: "xmark.circle.fill", trailing: AnyView(Toggle("", isOn: .constant(true)).labelsHidden()))
            settingsRow(title: "Edit Users", icon: "person.2.fill", trailing: AnyView(Image(systemName: "chevron.right").foregroundStyle(.secondary))) {
                router.goToEditUsers()
            }
        }
    }

    func settingsRow(title: String, icon: String, trailing: AnyView? = nil, action: (() -> Void)? = nil) -> some View {
        Button {
            action?()
        } label: {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .foregroundStyle(.blue)
                    Text(title)
                        .font(.body.weight(.medium))
                }
                Spacer()
                trailing ?? AnyView(Image(systemName: "chevron.right").foregroundStyle(.secondary))
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    var debugSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Debug / Status")
                .font(.caption)
                .foregroundStyle(.secondary)
            StatusBanner(text: "Card settings are placeholders until APIs are ready.", style: .info)
        }
    }

    func maskedCard(_ last4: String) -> String {
        return "**** **** **** \(last4)"
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
        return "Card Holder"
    }
}

#Preview {
    NavigationStack {
        CardSettingsPlaceholderView(appState: AppState())
    }
}
