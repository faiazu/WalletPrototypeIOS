//
//  AppConfig.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import Foundation

/// Central place for runtime configuration (base URLs, feature flags, etc).
struct AppConfig {
    static let shared = AppConfig()

    let baseURL: URL

    init() {
        // Prefer an env override, fall back to localhost for dev.
        if let baseURLString = ProcessInfo.processInfo.environment["BASE_URL"],
           let url = URL(string: baseURLString) {
            self.baseURL = url
        } else {
            self.baseURL = URL(string: "http://localhost:3000")!
        }
    }
}
