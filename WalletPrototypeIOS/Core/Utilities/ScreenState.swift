//
//  ScreenState.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import Foundation

/// Simple UI state enum to standardize loading/error handling across view models.
enum ScreenState: Equatable {
    case idle
    case loading(message: String? = nil)
    case loaded
    case error(message: String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var message: String? {
        switch self {
        case let .loading(message): return message
        case let .error(message): return message
        default: return nil
        }
    }
}
