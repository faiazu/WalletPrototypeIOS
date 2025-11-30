//
//  MembersSectionView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import SwiftUI

struct MembersSectionView: View {
    let members: [MemberRowModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Members")
                .font(.headline)

            ForEach(members) { member in
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
}

#Preview {
    MembersSectionView(members: [
        MemberRowModel(name: "Christopher", role: "Admin", status: "Active", amount: "$0.00")
    ])
        .padding()
}
