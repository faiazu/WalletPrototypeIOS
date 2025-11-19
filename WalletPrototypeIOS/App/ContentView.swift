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
        Group {
            if appState.currentUser != nil {
                // Logged-in flow
                NavigationStack(path: $router.path) {
                    HomeRootView(appState: appState)
                        .navigationDestination(for: Route.self) { route in
                            switch route {
                            case .wallet:
                                WalletRootView(appState: appState)
                            }
                        }
                }
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
        .environmentObject(Router())
}

