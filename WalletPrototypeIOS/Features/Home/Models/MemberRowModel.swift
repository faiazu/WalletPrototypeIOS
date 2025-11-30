//
//  MemberRowModel.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import Foundation

struct MemberRowModel: Identifiable {
    let id = UUID()
    let name: String
    let role: String
    let status: String
    let amount: String
}
