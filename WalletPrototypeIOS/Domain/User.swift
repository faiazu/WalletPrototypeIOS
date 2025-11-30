//
//  User.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-15.
//

import Foundation

enum KYCStatus: String, Codable, Equatable {
    case accepted = "ACCEPTED"
    case pending = "PENDING"
    case processing = "PROCESSING"
    case reviewing = "REVIEWING"
    case rejected = "REJECTED"
    case unknown = "UNKNOWN"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self).uppercased()
        self = KYCStatus(rawValue: rawValue) ?? .unknown
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

struct User: Identifiable, Codable, Equatable {
    let id: String
    let email: String
    let kycStatus: KYCStatus?
    // to add: name, createdAt, avatarURL, etc.
}
