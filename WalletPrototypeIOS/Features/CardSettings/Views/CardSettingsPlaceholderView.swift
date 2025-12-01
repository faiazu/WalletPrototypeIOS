//
//  CardSettingsPlaceholderView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import SwiftUI

/// Card settings screen wired to card endpoints; includes debug messaging.
struct CardSettingsPlaceholderView: View {
    @ObservedObject var appState: AppState
    @EnvironmentObject var router: Router
    @StateObject private var viewModel: CardSettingsViewModel

    init(appState: AppState) {
        self.appState = appState
        _viewModel = StateObject(wrappedValue: CardSettingsViewModel(appState: appState))
    }

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
        .onAppear {
            viewModel.load()
        }
    }
}

private extension CardSettingsPlaceholderView {
    var cardSummary: some View {
        CardDisplayView(
            cardTitle: viewModel.card?.nickname?.isEmpty == false
                ? (viewModel.card?.nickname ?? "Card")
                : (appState.wallet?.name ?? "Groceries"),
            balanceText: CurrencyFormatter.string(from: viewModel.balances?.poolDisplay ?? appState.balances?.poolDisplay ?? 0),
            maskedNumber: maskedCard(viewModel.card?.last4 ?? appState.cards.first?.last4 ?? "7641"),
            validFrom: "10/25",
            expires: "10/30",
            holder: displayName(for: viewModel.card?.user ?? appState.currentUser),
            chipImageName: "CardChipImage",
            brandImageName: "MastercardLogo"
        )
    }

    var statusRow: some View {
        HStack {
            Text("Card Status")
                .font(.headline)
            Spacer()
            let status = viewModel.card?.status ?? .unknown
            Text(statusLabel(status))
                .font(.footnote.weight(.semibold))
                .foregroundStyle(statusColor(status))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(statusColor(status).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    var settingsList: some View {
        VStack(spacing: 12) {
            settingsRow(title: "Change Pin", icon: "lock.rotation")
            settingsRow(
                title: "Lock Card",
                icon: "lock.fill",
                trailing: AnyView(Toggle("", isOn: Binding<Bool>(
                    get: { viewModel.card?.status == .locked },
                    set: { viewModel.setLocked($0) }
                )).labelsHidden()),
                disabled: viewModel.card == nil || viewModel.isLoading
            )
            settingsRow(
                title: "Deactivate Card",
                icon: "xmark.circle.fill",
                trailing: AnyView(Toggle("", isOn: Binding<Bool>(
                    get: { viewModel.card?.status == .canceled },
                    set: { viewModel.setDeactivated($0) }
                )).labelsHidden()),
                disabled: viewModel.card == nil || viewModel.isLoading
            )
            settingsRow(title: "Edit Users", icon: "person.2.fill", trailing: AnyView(Image(systemName: "chevron.right").foregroundStyle(.secondary))) {
                router.goToEditUsers()
            }
        }
    }

    func settingsRow(title: String, icon: String, trailing: AnyView? = nil, disabled: Bool = false, action: (() -> Void)? = nil) -> some View {
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
        .disabled(disabled)
    }

    var debugSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Debug / Status")
                .font(.caption)
                .foregroundStyle(.secondary)
            if let debug = viewModel.debugMessage {
                StatusBanner(text: debug, style: .info)
            }
            if let error = viewModel.errorMessage {
                StatusBanner(text: error, style: .error)
            }
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

    func statusLabel(_ status: CardStatus) -> String {
        switch status {
        case .active: return "Active"
        case .locked: return "Locked"
        case .canceled: return "Canceled"
        case .suspended: return "Suspended"
        case .unknown: return "Unknown"
        }
    }

    func statusColor(_ status: CardStatus) -> Color {
        switch status {
        case .active: return .green
        case .locked: return .orange
        case .canceled, .suspended: return .red
        case .unknown: return .secondary
        }
    }
}

#Preview {
    NavigationStack {
        CardSettingsPlaceholderView(appState: AppState())
            .environmentObject(Router())
    }
}
