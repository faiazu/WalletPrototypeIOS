//
//  StyleGuide.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-12-04.
//

import SwiftUI

enum StyleGuide {
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 18
    }

    enum Fonts {
        static func heading(_ size: CGFloat = 24) -> Font { .system(size: size, weight: .bold) }
        static var body: Font { .system(size: 16) }
        static var caption: Font { .footnote }
    }

    enum Colors {
        static let cardGradient = LinearGradient(
            colors: [Color.blue, Color.purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let surface = Color(.secondarySystemBackground)
        static let accent = Color.blue
        static let destructive = Color.red
    }
}
