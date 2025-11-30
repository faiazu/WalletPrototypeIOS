//
//  CurrencyFormatter.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import Foundation

/// Shared currency formatter to avoid re-creating NumberFormatter.
enum CurrencyFormatter {
    static let shared: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }()

    static func string(from amount: Double?) -> String {
        guard let amount else { return "—" }
        return shared.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}
