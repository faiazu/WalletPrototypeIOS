//
//  UserOverview.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-12-01.
//

import Foundation

struct UserOverview: Codable, Equatable {
    struct Requirements: Codable, Equatable {
        let kycRequired: Bool
    }

    struct WalletSummary: Codable, Equatable, Identifiable {
        let id: String
        let name: String?
        let role: String?
        let isAdmin: Bool?
        let memberCount: Int?
        let cardCount: Int?
        let hasCardForCurrentUser: Bool?
        let joinedAt: String?
        let createdAt: String?
    }

    let user: User
    let hasWallets: Bool
    let requirements: Requirements
    let wallets: [WalletSummary]

    var firstWalletId: String? {
        wallets.first?.id
    }
}
