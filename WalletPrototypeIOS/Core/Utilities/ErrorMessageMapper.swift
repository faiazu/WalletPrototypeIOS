//
//  ErrorMessageMapper.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-30.
//

import Foundation

/// Converts backend error payloads into short, user-friendly strings.
enum ErrorMessageMapper {
    static func message(for error: Error) -> String {
        if let apiError = error as? APIError {
            switch apiError {
            case let .serverError(_, body):
                if let parsed = parsedServerMessage(from: body) {
                    return parsed
                }
                return apiError.localizedDescription
            default:
                return apiError.localizedDescription
            }
        }

        return error.localizedDescription
    }

    static func parsedServerMessage(from body: String?) -> String? {
        guard let body, !body.isEmpty else { return nil }

        if let data = body.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let message = json["error"] as? String {
            return message
        }

        return body
    }
}
