//
//  RootViewControllerProvider.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-15.
//

import UIKit

enum RootViewControllerProvider {
    static func rootViewController() -> UIViewController? {
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first(where: { $0.isKeyWindow })
        else {
            return nil
        }
        return window.rootViewController
    }
}


