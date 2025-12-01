//
//  WalletEntrySheet.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-12-01.
//

import SwiftUI

struct WalletEntrySheet: View {
    enum Mode {
        case create
        case join

        var title: String {
            switch self {
            case .create: return "Create Wallet"
            case .join: return "Join Wallet"
            }
        }

        var placeholder: String {
            switch self {
            case .create: return "Groceries"
            case .join: return "Invite code or Wallet ID"
            }
        }

        var actionTitle: String {
            switch self {
            case .create: return "Create"
            case .join: return "Join"
            }
        }
    }

    let mode: Mode
    let isBusy: Bool
    let onSubmit: (String) async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(mode == .create ? "Wallet name" : "Code")) {
                    TextField(mode.placeholder, text: $text)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }

                Section {
                    Button {
                        submit()
                    } label: {
                        HStack {
                            Spacer()
                            if isSubmitting {
                                ProgressView()
                            } else {
                                Text(mode.actionTitle)
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(isBusy || isSubmitting || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle(mode.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func submit() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        Task {
            isSubmitting = true
            await onSubmit(trimmed)
            isSubmitting = false
            dismiss()
        }
    }
}

#Preview {
    WalletEntrySheet(mode: .create, isBusy: false) { _ in }
}
