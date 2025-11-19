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
            if appState.currentUser != nil {
                // Logged-in flow: show the home screen
                HomeRootView(appState: appState)
            } else {
                // Logged-out flow: show auth screen
                AuthRootView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}

