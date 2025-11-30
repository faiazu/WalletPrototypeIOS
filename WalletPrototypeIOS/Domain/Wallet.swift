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
    let status: CardStatus?
    let providerName: String?
    let walletId: String?
    let userId: String?
    let user: User?

    var displayId: String {
        externalCardId ?? id ?? "card"
    }

    var maskedDisplay: String {
        guard let last4 else { return "****" }
        return "**** \(last4)"
    }
}

enum CardStatus: String, Codable, Equatable {
    case active = "ACTIVE"
    case locked = "LOCKED"
    case canceled = "CANCELED"
    case suspended = "SUSPENDED"
    case unknown = "UNKNOWN"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self).uppercased()
        self = CardStatus(rawValue: raw) ?? .unknown
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
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
    let cards: [Card]
    let balances: Balances
}
