//
//  EditUsersPlaceholderView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import SwiftUI

/// Placeholder edit-users screen with mock actions. Real APIs can be hooked to these buttons later.
struct EditUsersPlaceholderView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Edit Users")
                    .font(.largeTitle.bold())

                ForEach(sampleMembers, id: \.id) { member in
                    memberCard(member)
                }

                debugSection
            }
            .padding()
        }
    }
}

private extension EditUsersPlaceholderView {
    struct Member: Identifiable {
        let id = UUID()
        let name: String
        let role: String
        let status: String
        let amount: Double
    }

    var sampleMembers: [Member] {
        if let members = appState.wallet?.members, !members.isEmpty {
            return members.map {
                Member(
                    name: $0.user?.email ?? "Member",
                    role: $0.role ?? "Member",
                    status: "Active",
                    amount: appState.balances?.memberEquity?.first(where: { $0.userId == $0.userId })?.balance ?? 0
                )
            }
        }
        return [
            Member(name: appState.currentUser?.email ?? "You", role: "Admin", status: "Active", amount: 55.50),
            Member(name: "Simon", role: "Member", status: "Active", amount: 55.50),
            Member(name: "Alex", role: "Member", status: "Inactive", amount: 55.50),
            Member(name: "Veer", role: "Member", status: "Active", amount: 23.21)
        ]
    }

    func memberCard(_ member: Member) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(member.name)
                        .font(.headline)
                    Text(member.role)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(statusText(member.status))
                        .font(.caption.bold())
                        .foregroundStyle(statusColor(member.status))
                    Text(CurrencyFormatter.string(from: member.amount))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            actionGrid
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    var actionGrid: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                actionButton(title: "Kick off Card", systemImage: "figure.walk.departure")
                actionButton(title: "Request Money", systemImage: "dollarsign.square")
            }
            HStack(spacing: 8) {
                actionButton(title: "Transfer Ownership", systemImage: "crown.fill")
                actionButton(title: "Freeze Usage", systemImage: "snowflake")
            }
        }
    }

    func actionButton(title: String, systemImage: String) -> some View {
        Button {
            // Placeholder action; hook up when API ready.
        } label: {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(title)
                    .font(.footnote.weight(.semibold))
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 3, y: 2)
        }
        .buttonStyle(.plain)
    }

    var debugSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Debug / Status")
                .font(.caption)
                .foregroundStyle(.secondary)
            StatusBanner(text: "Edit users is a placeholder. Actions are not wired yet.", style: .info)
        }
    }

    func statusColor(_ status: String) -> Color {
        status.lowercased() == "active" ? .green : .red
    }

    func statusText(_ status: String) -> String {
        status.capitalized
    }
}

#Preview {
    NavigationStack {
        EditUsersPlaceholderView(appState: AppState())
    }
}
