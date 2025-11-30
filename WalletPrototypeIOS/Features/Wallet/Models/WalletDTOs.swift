//
//  WalletDTOs.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import Foundation

// API-facing DTOs
struct WalletBootstrapDTO: Codable {
    let wallet: WalletDTO
    let card: CardDTO
    let balances: BalancesDTO
}

struct WalletDTO: Codable {
    let id: String
    let name: String?
    let adminId: String?
    let createdAt: String?
    let members: [WalletMemberDTO]?
}

struct WalletMemberDTO: Codable {
    let id: String?
    let walletId: String?
    let userId: String?
    let role: String?
    let joinedAt: String?
    let user: User?
}

struct CardDTO: Codable {
    let id: String?
    let externalCardId: String?
    let last4: String?
    let status: String?
    let providerName: String?
    let walletId: String?
    let userId: String?
}

struct BalancesDTO: Codable {
    let poolDisplay: Double?
    let memberEquity: [MemberEquityDTO]?
}

struct MemberEquityDTO: Codable {
    let userId: String
    let balance: Double
}

// Mapping to domain models
extension WalletBootstrapDTO {
    func toDomain() -> WalletBootstrapResponse {
        WalletBootstrapResponse(
            wallet: wallet.toDomain(),
            card: card.toDomain(),
            balances: balances.toDomain()
        )
    }
}

extension WalletDTO {
    func toDomain() -> Wallet {
        Wallet(
            id: id,
            name: name,
            members: members?.map { $0.toDomain() },
            adminId: adminId,
            createdAt: createdAt
        )
    }
}

extension WalletMemberDTO {
    func toDomain() -> WalletMember {
        WalletMember(
            id: id,
            walletId: walletId,
            userId: userId,
            role: role,
            joinedAt: joinedAt,
            user: user
        )
    }
}

extension CardDTO {
    func toDomain() -> Card {
        Card(
            id: id,
            externalCardId: externalCardId,
            last4: last4,
            status: status,
            providerName: providerName,
            walletId: walletId,
            userId: userId
        )
    }
}

extension BalancesDTO {
    func toDomain() -> Balances {
        Balances(
            poolDisplay: poolDisplay,
            memberEquity: memberEquity?.map { $0.toDomain() }
        )
    }
}

extension MemberEquityDTO {
    func toDomain() -> MemberEquity {
        MemberEquity(userId: userId, balance: balance)
    }
}
