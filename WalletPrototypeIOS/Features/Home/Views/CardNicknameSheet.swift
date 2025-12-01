//
//  CardNicknameSheet.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-12-03.
//

import SwiftUI

/// Simple sheet for capturing a nickname when creating a new card.
struct CardNicknameSheet: View {
    let isBusy: Bool
    let onSubmit: (String?) async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Card nickname (optional)")) {
                    TextField("Groceries card", text: $text)
                        .textInputAutocapitalization(.words)
                        .disableAutocorrection(false)
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
                                Text("Create Card")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(isBusy || isSubmitting)
                }
            }
            .navigationTitle("Create Card")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func submit() {
        let nickname = text.trimmingCharacters(in: .whitespacesAndNewlines)

        Task {
            isSubmitting = true
            await onSubmit(nickname.isEmpty ? nil : nickname)
            isSubmitting = false
            dismiss()
        }
    }
}

#Preview {
    CardNicknameSheet(isBusy: false) { _ in }
}
