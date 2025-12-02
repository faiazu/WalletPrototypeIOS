//
//  CardCarouselView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-12-03.
//

import SwiftUI

/// Horizontally swipeable set of cards with smooth paging transitions.
struct CardCarouselView: View {
    let cards: [Card]
    let walletName: String?
    let balanceText: String
    let chipImageName: String
    let brandImageName: String
    let holderForCard: (Card) -> String
    @Binding var selectedCardId: String?

    var body: some View {
        GeometryReader { geo in
            let horizontalInset: CGFloat = 16
            let cardWidth = geo.size.width * 0.9 // slight gap between cards

            let selectionBinding = Binding<String?>(
                get: { selectedCardId ?? cards.first?.displayId },
                set: { newValue in selectedCardId = newValue }
            )

            TabView(selection: selectionBinding) {
                ForEach(cards, id: \.displayId) { card in
                    CardDisplayView(
                        cardTitle: title(for: card),
                        balanceText: balanceText,
                        maskedNumber: maskedNumber(for: card.last4),
                        validFrom: "10/25",
                        expires: "10/30",
                        holder: holderForCard(card),
                        chipImageName: chipImageName,
                        brandImageName: brandImageName
                    )
                    .frame(width: cardWidth)
                    .tag(card.displayId)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            .frame(height: 320)
            .padding(.horizontal, horizontalInset)
        }
        .frame(height: 340)
        .onAppear { selectedCardId = selectedCardId ?? cards.first?.displayId }
    }
}

private extension CardCarouselView {
    func title(for card: Card) -> String {
        if let nickname = card.nickname, !nickname.isEmpty {
            return nickname
        }
        if let walletName, !walletName.isEmpty {
            return walletName
        }
        return "Card"
    }

    func maskedNumber(for last4: String?) -> String {
        let suffix = last4 ?? "7641"
        return "**** **** **** \(suffix)"
    }
}

#Preview {
    CardCarouselView(
        cards: [
            Card(id: "1", externalCardId: "card_1", last4: "1234", nickname: "Groceries", status: .active, providerName: "SYNCTERA", walletId: "w1", userId: "u1", user: nil),
            Card(id: "2", externalCardId: "card_2", last4: "5678", nickname: "Travel", status: .active, providerName: "SYNCTERA", walletId: "w1", userId: "u1", user: nil)
        ],
        walletName: "Household",
        balanceText: "$0.00",
        chipImageName: "CardChipImage",
        brandImageName: "MastercardLogo",
        holderForCard: { _ in "Cardholder Name" },
        selectedCardId: .constant(nil)
    )
}
