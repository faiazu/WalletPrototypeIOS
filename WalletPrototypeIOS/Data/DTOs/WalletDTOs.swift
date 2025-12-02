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
    let cards: [CardDTO]
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
    let nickname: String?
    let status: CardStatus?
    let providerName: String?
    let walletId: String?
    let userId: String?
    let user: User?
}

struct BalancesDTO: Codable {
    let poolDisplay: Double?
    let memberEquity: [MemberEquityDTO]?
}

struct MemberEquityDTO: Codable {
    let userId: String
    let balance: Double
}

struct WalletDetailsDTO: Codable {
    let wallet: WalletDTO
    let balances: BalancesDTO?
}

struct WalletDetailsResponse {
    let wallet: Wallet
    let balances: Balances?
}

// Mapping to domain models
extension WalletBootstrapDTO {
    func toDomain() -> WalletBootstrapResponse {
        WalletBootstrapResponse(
            wallet: wallet.toDomain(),
            cards: cards.map { $0.toDomain() },
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
            nickname: nickname,
            status: status ?? .unknown,
            providerName: providerName,
            walletId: walletId,
            userId: userId,
            user: user
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

extension WalletDetailsDTO {
    func toDomain() -> WalletDetailsResponse {
        WalletDetailsResponse(
            wallet: wallet.toDomain(),
            balances: balances?.toDomain()
        )
    }
}
