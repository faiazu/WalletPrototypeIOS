//
//  User.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-15.
//

import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    let email: String
    // to add: name, createdAt, avatarURL, etc.
}
