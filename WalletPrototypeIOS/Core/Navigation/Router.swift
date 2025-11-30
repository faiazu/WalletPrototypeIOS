//
//  Router.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-19.
//

import Combine

final class Router: ObservableObject {
    @Published var path: [Route] = []

    func push(route: Route) {
        path.append(route)
    }

    func goToWallet() {
        path.append(.wallet)
    }

    func goToCardSettings() {
        path.append(.cardSettings)
    }

    func goToEditUsers() {
        path.append(.editUsers)
    }

    func pop() {
        _ = path.popLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}

enum Route: Hashable {
    case wallet
    case cardSettings
    case editUsers
    // Later:
    // case walletDetails(id: String)
    // case transaction(id: String)
    // case settings
}
