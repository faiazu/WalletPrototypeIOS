//
//  CardDisplayView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import SwiftUI

struct CardDisplayView: View {
    let walletName: String
    let balanceText: String
    let maskedNumber: String
    let validFrom: String
    let expires: String
    let holder: String
    let chipImageName: String
    let brandImageName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(walletName)
                .font(.system(size: 32, weight: .bold))

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 220)
                    .shadow(radius: 6, y: 4)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Available Balance")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))

                    Text(balanceText)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)

                    Text(maskedNumber)
                        .font(.title3.monospacedDigit().weight(.bold))
                        .foregroundStyle(.white)

                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Valid From")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.7))
                            Text(validFrom)
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Expires")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.7))
                            Text(expires)
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Card Holder")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.7))
                        Text(holder)
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)

                VStack(alignment: .trailing, spacing: 12) {
                    if let chip = UIImage(named: chipImageName) {
                        Image(uiImage: chip)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 46, height: 36)
                            .padding(.top, 12)
                            .padding(.trailing, 12)
                    }
                    Spacer()
                    if let brand = UIImage(named: brandImageName) {
                        Image(uiImage: brand)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 32)
                            .padding(.trailing, 12)
                            .padding(.bottom, 12)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
    }
}

#Preview {
    CardDisplayView(
        walletName: "Groceries",
        balanceText: "$0.00",
        maskedNumber: "**** **** **** 7641",
        validFrom: "10/25",
        expires: "10/30",
        holder: "Will Jonas",
        chipImageName: "CardChipImage",
        brandImageName: "MastercardLogo"
    )
    .padding()
}
