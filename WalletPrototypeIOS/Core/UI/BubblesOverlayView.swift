//
//  BubblesOverlayView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import SwiftUI

/// Lightweight bubbly overlay used during auth transitions (sign in/out).
struct BubblesOverlayView: View {
    @State private var animate = false

    private let bubbles: [(color: Color, size: CGFloat, x: CGFloat, y: CGFloat, opacity: Double)] = [
        (.blue.opacity(0.25), 140, -60, -80, 0.5),
        (.purple.opacity(0.3), 120, 80, -40, 0.4),
        (.cyan.opacity(0.25), 90, -40, 60, 0.45),
        (.indigo.opacity(0.25), 110, 100, 80, 0.35),
        (.blue.opacity(0.2), 160, 20, -120, 0.3)
    ]

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<bubbles.count, id: \.self) { index in
                    let bubble = bubbles[index]
                    Circle()
                        .fill(bubble.color)
                        .frame(width: bubble.size, height: bubble.size)
                        .position(
                            x: proxy.size.width / 2 + bubble.x,
                            y: proxy.size.height / 2 + bubble.y
                        )
                        .scaleEffect(animate ? 1.05 : 0.95)
                        .opacity(animate ? bubble.opacity : bubble.opacity * 0.6)
                        .blur(radius: 12)
                        .animation(
                            .easeInOut(duration: 1.4)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.08),
                            value: animate
                        )
                }
            }
            .onAppear { animate = true }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    ZStack {
        Color(.systemBackground).ignoresSafeArea()
        BubblesOverlayView()
    }
}
