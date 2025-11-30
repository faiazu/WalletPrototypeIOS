//
//  APIClient.swift
//  WalletPrototypeIOS
//
//  Created by Faiaz on 2025-11-15.
//

import Foundation

// Represents the different kinds of errors that can happen when talking to backend
enum APIError: Error {
    // The base URL + path couldn't be combined into a valid URL
    case invalidURL

    // The server responded with a non-2xx status code
    // statusCode: HTTP status
    // body: The raw response body as a string (if any)
    case serverError(statusCode: Int, body: String?)

    // JSON decoding failed when trying to turn Data into Response
    case decodingFailed(Error)

    // The request succeeded but there was no data in the response
    case noData

    // Any other underlying error (ex networking, URLSession)
    case underlying(Error)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."

        case let .serverError(statusCode, body):
            if let body = body, !body.isEmpty {
                return "Server error \(statusCode): \(body)"
            } else {
                return "Server error \(statusCode)."
            }

        case let .decodingFailed(error):
            return "Failed to decode response: \(error.localizedDescription)"

        case .noData:
            return "No data returned from server."

        case let .underlying(error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// HTTPMethod enums instead of strings
enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

// API client:
//   - Building URLs relative to a base URL
//   - Attaching headers
//   - Encoding JSON request bodies
//   - Decoding JSON responses
//   - Normalizing errors into APIError
final class APIClient {
    static let shared = APIClient()

    private let baseURL: URL
    private let urlSession: URLSession
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    private var authToken: String?

    // Initializer, can use different baseURL / session / json stuff if needed
    init(
        baseURL: URL = URL(string: "http://localhost:3000")!,
        urlSession: URLSession = .shared,
        jsonEncoder: JSONEncoder = .init(),
        jsonDecoder: JSONDecoder = .init()
    ) {
        self.baseURL = baseURL
        self.urlSession = urlSession
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    // Store a token so future requests automatically attach Authorization if not overridden.
    func setAuthToken(_ token: String?) {
        authToken = token
    }

    // Sends a request that has a JSON body (ex POST /auth/google).
    //
    // Parameters:
    //   - path: Path relative to baseURL, ex "/auth/google"
    //   - method: HTTP method (POST, PUT, etc)
    //   - body: Encodable body that will be JSON encoded into the request
    //   - headers: Extra headers to attach (ex Authorization).
    //
    // Returns: Decoded response body as the type ResponseBody.
    func send<RequestBody: Encodable, ResponseBody: Decodable>(
        path: String,
        method: HTTPMethod,
        body: RequestBody,
        headers: [String: String] = [:]
    ) async throws -> ResponseBody {
        // Build URLRequest with method + headers
        var request = try makeRequest(path: path, method: method, headers: headers)

        // Encode the Swift body into JSON Data and set as httpBody.
        request.httpBody = try jsonEncoder.encode(body)

        // Perform the request and decode the response into ResponseBody.
        return try await perform(request: request)
    }

    // Sends a request that has no body (ex GET /me)
    //
    // Parameters:
    //   - path: Path relative to baseURL, e.g. "/me"
    //   - method: HTTP method (defaults to GET)
    //   - headers: Extra headers to attach
    //
    // Returns: Decoded response body as the type ResponseBody
    func send<ResponseBody: Decodable>(
        path: String,
        method: HTTPMethod = .get,
        headers: [String: String] = [:]
    ) async throws -> ResponseBody {
        // Build the URLRequest with method + headers.
        let request = try makeRequest(path: path, method: method, headers: headers)

        // Perform the request and decode the response into ResponseBody.
        return try await perform(request: request)
    }
    

    // Helpers

    // Builds a URLRequest from:
    //   - baseURL (e.g. http://localhost:3000)
    //   - path (e.g. "/auth/google")
    //   - method (GET/POST/etc)
    //   - headers (Authorization, custom headers, etc)
    //
    private func makeRequest(
        path: String,
        method: HTTPMethod,
        headers: [String: String]
    ) throws -> URLRequest {
        // Combine baseURL and path into a full URL.

        // appendingPathComponent handles leading/trailing slashes well
        let url = baseURL.appendingPathComponent(path)

        // Create the URLRequest from the final URL
        var request = URLRequest(url: url)

        // Set the HTTP method as a string, ex "GET", "POST", etc
        request.httpMethod = method.rawValue

        // Default headers for JSON APIs
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token = authToken, headers["Authorization"] == nil {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Apply any additional headers (ex Authorization)
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    // Actually performs the network request and handles:
    //   - Networking errors
    //   - HTTP status code checks
    //   - Decoding JSON into the expected ResponseBody type
    //
    private func perform<ResponseBody: Decodable>(request: URLRequest) async throws -> ResponseBody {
        do {
            // Ask URLSession to perform the request.

            // This returns the raw Data and a URLResponse.
            let (data, response) = try await urlSession.data(for: request)

            // Make sure we actually got an HTTPURLResponse (with status code, headers, etc.)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.noData
            }

            // Check that the status code is in 200-300 (success range)
            // If not, treat as an error and include:
            //   - the statusCode
            //   - the raw body string (if available) to help debugging
            guard (200..<300).contains(httpResponse.statusCode) else {
                let bodyString = data.isEmpty ? nil : String(data: data, encoding: .utf8)
                print("❌ API error for \(request.url?.absoluteString ?? "<no url>")")
                print("   Status: \(httpResponse.statusCode)")
                print("   Body: \(bodyString ?? "<no body>")")
                throw APIError.serverError(statusCode: httpResponse.statusCode, body: bodyString)
            }

            // Ensure there's actually data to decode.
            guard !data.isEmpty else {
                throw APIError.noData
            }

            // Try decoding the Data into the expected ResponseBody type
            do {
                let decoded = try jsonDecoder.decode(ResponseBody.self, from: data)
                return decoded
            } catch {
                // Wrap the decoding error to know it failed at JSON decoding stage
                throw APIError.decodingFailed(error)
            }
        } catch let apiError as APIError {
            // If already threw APIError, rethrow it
            throw apiError
        } catch {
            // Any other error (URLSession/network/etc) is wrapped as underlying
            throw APIError.underlying(error)
        }
    }
}
