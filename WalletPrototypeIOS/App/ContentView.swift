//
//  ContentView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-15.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if let user = appState.currentUser {
                // Logged-in flow (placeholder for now)
                VStack(spacing: 16) {
                    Text("Home")
                        .font(.largeTitle)
                        .bold()
                    Text("Logged in as \(user.email)")
                }
            } else {
                // Logged-out flow → show Google sign-in
                AuthRootView()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}

