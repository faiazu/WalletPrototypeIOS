//
//  ContentView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-15.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var router: Router

    var body: some View {
        ZStack {
            Group {
                if appState.currentUser != nil {
                    LoggedInShellView(appState: appState)
                        .environmentObject(router)
                } else {
                    // Logged-out flow: show auth screen
                    AuthRootView()
                }
            }

            if appState.showAuthTransition {
                BubblesOverlayView()
                    .transition(.opacity)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(Router())
}
