//
//  WalletPrototypeIOSApp.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-15.
//

import SwiftUI

@main
struct WalletPrototypeIOSApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var router = Router()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(router)
        }
    }
}
