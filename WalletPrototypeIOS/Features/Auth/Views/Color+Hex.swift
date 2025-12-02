//
//  Color+Hex.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-12-02.
//

import SwiftUI

extension Color {
    /// Initialize a SwiftUI Color from a hex string.
    /// Supports the following formats (with or without leading '#'):
    /// - RGB (3 or 6 hex digits): "FFF", "FFFFFF"
    /// - ARGB (8 hex digits): "FF112233" (alpha first)
    /// If `alpha` is provided, it overrides any alpha parsed from the hex string.
    init(hex: String, alpha: Double? = nil) {
        // Remove non-hex characters (e.g., leading '#', spaces)
        let cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .uppercased()

        var a: UInt64 = 255
        var r: UInt64 = 0
        var g: UInt64 = 0
        var b: UInt64 = 0

        func expand(_ c: Character) -> String { "\(c)\(c)" }

        switch cleaned.count {
        case 3:
            // e.g., "FAB" -> "FF", "AA", "BB"
            let chars = Array(cleaned)
            let rr = expand(chars[0])
            let gg = expand(chars[1])
            let bb = expand(chars[2])
            Scanner(string: rr).scanHexInt64(&r)
            Scanner(string: gg).scanHexInt64(&g)
            Scanner(string: bb).scanHexInt64(&b)

        case 6:
            // "RRGGBB"
            let rr = String(cleaned.prefix(2))
            let gg = String(cleaned.dropFirst(2).prefix(2))
            let bb = String(cleaned.dropFirst(4).prefix(2))
            Scanner(string: rr).scanHexInt64(&r)
            Scanner(string: gg).scanHexInt64(&g)
            Scanner(string: bb).scanHexInt64(&b)

        case 8:
            // "AARRGGBB" (alpha first)
            let aa = String(cleaned.prefix(2))
            let rr = String(cleaned.dropFirst(2).prefix(2))
            let gg = String(cleaned.dropFirst(4).prefix(2))
            let bb = String(cleaned.dropFirst(6).prefix(2))
            Scanner(string: aa).scanHexInt64(&a)
            Scanner(string: rr).scanHexInt64(&r)
            Scanner(string: gg).scanHexInt64(&g)
            Scanner(string: bb).scanHexInt64(&b)

        default:
            // Fallback to clear if format is invalid
            self = Color.clear
            return
        }

        let finalA = alpha.map { max(0, min(1, $0)) } ?? Double(a) / 255.0
        self = Color(
            .sRGB,
            red: Double(r) / 255.0,
            green: Double(g) / 255.0,
            blue: Double(b) / 255.0,
            opacity: finalA
        )
    }
}
