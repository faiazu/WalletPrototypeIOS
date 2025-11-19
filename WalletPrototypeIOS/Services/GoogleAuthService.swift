//
//  GoogleAuthService.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-15.
//

import Foundation
import UIKit
import GoogleSignIn

// Handles Google Sign-in and returns the Google ID Token
// Send this ID Token to backend later
@MainActor
final class GoogleAuthService {
    
    static let shared = GoogleAuthService()
    
    private init() { }
    
    // Presents the Google Sign-In UI and returns the ID Token String\
    func signIn(presenting viewController: UIViewController) async throws -> String {
        // 1. Ensure configuration is set (recommended: via Info.plist key `GIDClientID`)
        if GIDSignIn.sharedInstance.configuration == nil {
            guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
                throw NSError(
                    domain: "GoogleAuthService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "Missing GIDClientID in Info.plist"]
                )
            }
            
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }
        
        // 2. Start the sign-in flow (new SDK: async/await with `withPresenting:`)
        let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
        
        // 3. Extract the ID token from the signed-in user
        guard let idToken = signInResult.user.idToken?.tokenString else {
            throw NSError(
                domain: "GoogleAuthService",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Google sign-in did not return an ID token"]
            )
        }
        
        return idToken
    }
    
    // Simple helper to sign out.
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
}

