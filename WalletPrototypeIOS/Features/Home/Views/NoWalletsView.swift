//
//  NoWalletsView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-12-01.
//

import SwiftUI

struct NoWalletsView: View {
    let user: User?
    let requirements: UserOverview.Requirements?
    let isBusy: Bool
    let onCreate: () -> Void
    let onJoin: () -> Void

    private var name: String {
        if let name = user?.name, !name.isEmpty {
            return name
        }
        return user?.email ?? "Wallet member"
    }

    private var email: String {
        user?.email ?? ""
    }

    private var kycRequired: Bool {
        requirements?.kycRequired ?? false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header
            illustration
            VStack(spacing: 12) {
                Button(action: onCreate) {
                    HStack(spacing: 10) {
                        Text("🎉")
                        Text("Create your first Wallet")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
                    .padding(.horizontal, 12)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isBusy || kycRequired)
                .opacity((isBusy || kycRequired) ? 0.65 : 1)

                Button(action: onJoin) {
                    HStack(spacing: 10) {
                        Text("📱")
                        Text("Join an existing Wallet")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
                    .padding(.horizontal, 12)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(isBusy)
                .opacity(isBusy ? 0.65 : 1)
            }

            if kycRequired {
                StatusBanner(text: "Complete KYC before creating a wallet.", style: .error)
            }
        }
        .padding(.vertical, 20)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(Color(hex: "1A3EEC"))
                        )

                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .offset(x: 4, y: -4)
                }
                Spacer()
            }

            Text("Welcome")
                .font(.title2.bold())
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.title3.bold())
                if !email.isEmpty {
                    Text(email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var illustration: some View {
        Image("FirstCardImage")
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
    }
}

#Preview {
    NoWalletsView(
        user: User(id: "1", email: "christopher@example.com", name: "Christopher Albertson", kycStatus: .accepted),
        requirements: .init(kycRequired: false),
        isBusy: false,
        onCreate: {},
        onJoin: {}
    )
    .padding()
}
