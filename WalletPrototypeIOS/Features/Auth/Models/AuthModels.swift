//
//  AuthModels.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-15.
//

import Foundation

// Body to send to backend when logging in with Google
struct GoogleLoginRequest: Codable {
    let idToken: String
}

// Response from backend after successful authentication (Google or demo)
struct LoginResponse: Codable {
    let user: User        // from Domain/User.swift
    let token: String     // backend's JWT or session token
    let personId: String?
}

