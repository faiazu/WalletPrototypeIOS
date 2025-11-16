//
//  APIClient.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-15.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case serverError(statusCode: Int)
    case decodingFailed(Error)
    case noData
    case underlying(Error)
}

final class APIClient {
    static let shared = APIClient()
    private init() {}

    // change this when backend is live
    private let baseURL = URL(string: "http://localhost:3000")!

    // Generic helper for JSON APIs.
    func send<RequestBody: Encodable, ResponseBody: Decodable>(
        path: String,
        method: String = "GET",
        body: RequestBody? = nil,
        headers: [String: String] = [:]
    ) async throws -> ResponseBody {

        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.noData
            }
            guard (200..<300).contains(httpResponse.statusCode) else {
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            }

            return try JSONDecoder().decode(ResponseBody.self, from: data)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.underlying(error)
        }
    }
}

