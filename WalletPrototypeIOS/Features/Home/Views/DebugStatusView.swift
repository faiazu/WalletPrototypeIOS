//
//  DebugStatusView.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import SwiftUI

struct DebugStatusView: View {
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Debug/Status")
                .font(.caption)
                .foregroundStyle(.secondary)
            StatusBanner(text: message, style: .info)
        }
    }
}

#Preview {
    DebugStatusView(message: "Using demo data; API not fully wired.")
        .padding()
}
