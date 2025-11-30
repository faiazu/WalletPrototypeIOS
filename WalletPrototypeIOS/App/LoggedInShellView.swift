//
//  LoggedInShellView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import SwiftUI

/// Shell container for the logged-in experience with tabs for major sections.
struct LoggedInShellView: View {
    @ObservedObject var appState: AppState
    @EnvironmentObject var router: Router
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $router.path) {
                HomeRootView(appState: appState)
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .wallet:
                            WalletRootView(appState: appState)
                        case .cardSettings:
                            CardSettingsPlaceholderView(appState: appState)
                        case .editUsers:
                            EditUsersPlaceholderView(appState: appState)
                        }
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            NavigationStack {
                AccountPlaceholderView(appState: appState)
            }
            .tabItem {
                Label("Account", systemImage: "person.crop.circle.fill")
            }
            .tag(1)
        }
    }
}

#Preview {
    LoggedInShellView(appState: AppState())
        .environmentObject(Router())
}
