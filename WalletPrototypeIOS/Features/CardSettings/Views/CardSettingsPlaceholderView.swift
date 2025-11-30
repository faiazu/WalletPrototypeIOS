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
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(LinearGradient(colors: [.blue, Color.cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 160)
                .shadow(radius: 6, y: 4)

            VStack(alignment: .leading, spacing: 10) {
                Text("Available Balance")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                Text(CurrencyFormatter.string(from: appState.balances?.poolDisplay ?? 4228.76))
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                Text(maskedCard(appState.card?.last4 ?? "8635"))
                    .font(.body.monospacedDigit())
                    .foregroundStyle(.white)

                Text(appState.currentUser?.email ?? "Will Jonas")
                    .font(.footnote.bold())
                    .foregroundStyle(.white)
            }
            .padding(16)
        }
    }

    var statusRow: some View {
        HStack {
            Text("Card Status")
                .font(.headline)
            Spacer()
            Text(appState.card?.status ?? "Active")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.green)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
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
        return "•••• •••• •••• \(last4)"
    }
}

#Preview {
    NavigationStack {
        CardSettingsPlaceholderView(appState: AppState())
    }
}
