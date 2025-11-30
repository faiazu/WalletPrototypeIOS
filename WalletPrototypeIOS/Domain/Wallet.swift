//
//  Wallet.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import Foundation

struct WalletMember: Codable, Equatable {
    let id: String?
    let walletId: String?
    let userId: String?
    let role: String?
    let joinedAt: String?
    let user: User?
}

struct Wallet: Codable, Equatable, Identifiable {
    let id: String
    let name: String?
    let members: [WalletMember]?
    let adminId: String?
    let createdAt: String?
}

struct Card: Codable, Equatable {
    let id: String?
    let externalCardId: String?
    let last4: String?
    let status: String?
    let providerName: String?
    let walletId: String?
    let userId: String?

    var displayId: String {
        externalCardId ?? id ?? "card"
    }

    var maskedDisplay: String {
        guard let last4 else { return "****" }
        return "**** \(last4)"
    }
}

struct Balances: Codable, Equatable {
    let poolDisplay: Double?
    let memberEquity: [MemberEquity]?
}

struct MemberEquity: Codable, Equatable {
    let userId: String
    let balance: Double
}

struct WalletBootstrapResponse: Codable {
    let wallet: Wallet
    let card: Card
    let balances: Balances
}
