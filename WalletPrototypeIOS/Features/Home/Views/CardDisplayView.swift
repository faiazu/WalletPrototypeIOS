//
//  CardDisplayView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import SwiftUI
import CoreGraphics

/// Simple reusable card display that shows balance, masked number, and holder details.
struct CardDisplayView: View {
    let cardTitle: String
    let balanceText: String
    let maskedNumber: String
    let validFrom: String
    let expires: String
    let holder: String
    let chipImageName: String
    let brandImageName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(cardTitle)
                .font(StyleGuide.Fonts.heading(32))

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: StyleGuide.Radius.lg, style: .continuous)
                    .fill(StyleGuide.Colors.cardGradient)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Available Balance")
                        .font(StyleGuide.Fonts.caption)
                        .foregroundStyle(.white.opacity(0.9))

                    Text(balanceText)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)

                    Text(maskedNumber)
                        .font(.title3.monospacedDigit().weight(.bold))
                        .foregroundStyle(.white)

                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Valid From")
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.7))
                            Text(validFrom)
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Expires")
                                .font(.footnote)
                                .foregroundStyle(.white.opacity(0.7))
                            Text(expires)
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Card Holder")
                            .font(StyleGuide.Fonts.caption)
                            .foregroundStyle(.white.opacity(0.8))
                        Text(holder)
                            .font(.headline.bold())
                            .foregroundStyle(.white)
                    }
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .overlay(alignment: .topTrailing) {
                if let chip = UIImage(named: chipImageName) {
                    Image(uiImage: chip)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 46, height: 36)
                        .padding(.top, 12)
                        .padding(.trailing, 12)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if let brand = UIImage(named: brandImageName) {
                    Image(uiImage: brand)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 32)
                        .padding(.trailing, 12)
                        .padding(.bottom, 12)
                }
            }
            .frame(height: 240)
            .clipShape(RoundedRectangle(cornerRadius: StyleGuide.Radius.lg, style: .continuous))
            .shadow(radius: 6, y: 4)
        }
    }
}

#Preview {
    CardDisplayView(
        cardTitle: "Groceries",
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
