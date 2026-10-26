//
//  URLSessionAPIClient.swift
//  CineScope
//

import Foundation

public final class URLSessionAPIClient: APIClientProtocol, @unchecked Sendable {
    public static let shared = URLSessionAPIClient()

    private let session: URLSession
    private let config: APIConfig
    private let decoder: JSONDecoder

    public init(session: URLSession? = nil, config: APIConfig = .shared) {
        self.config = config

        let jsonDecoder = JSONDecoder()
        self.decoder = jsonDecoder

        if let session = session {
            self.session = session
        } else {
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 15.0
            sessionConfig.timeoutIntervalForResource = 30.0
            // 50 MB memory, 100 MB disk URL cache
            sessionConfig.urlCache = URLCache(
                memoryCapacity: 50 * 1024 * 1024,
                diskCapacity: 100 * 1024 * 1024,
                diskPath: "cinescope_url_cache"
            )
            sessionConfig.requestCachePolicy = .useProtocolCachePolicy
            self.session = URLSession(configuration: sessionConfig)
        }
    }

    public func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let credential = config.apiKeyOrToken, !credential.isEmpty else {
            throw APIError.missingCredentials
        }

        let request: URLRequest
        do {
            request = try endpoint.urlRequest(credential: credential)
        } catch {
            throw APIError.invalidURL
        }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError("Invalid response type")
            }

            switch httpResponse.statusCode {
            case 200...299:
                do {
                    return try decoder.decode(T.self, from: data)
                } catch let decodeErr {
                    #if DEBUG
                    print("Decoding error for \(endpoint.path): \(decodeErr)")
                    #endif
                    throw APIError.decodingError(decodeErr.localizedDescription)
                }
            case 400:
                throw APIError.badRequest
            case 401:
                throw APIError.unauthorized
            case 403:
                throw APIError.forbidden
            case 404:
                throw APIError.notFound
            case 429:
                throw APIError.rateLimited
            case 500...599:
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            default:
                throw APIError.serverError(statusCode: httpResponse.statusCode)
            }
        } catch let apiError as APIError {
            throw apiError
        } catch let urlError as URLError {
            if urlError.code == .cancelled {
                throw APIError.cancelled
            }

            // Check if we can recover from cached URL response when offline
            if urlError.code == .notConnectedToInternet ||
               urlError.code == .networkConnectionLost ||
               urlError.code == .cannotConnectToHost ||
               urlError.code == .timedOut {
                if let cached = session.configuration.urlCache?.cachedResponse(for: request) {
                    do {
                        return try decoder.decode(T.self, from: cached.data)
                    } catch {
                        throw APIError.offline
                    }
                }
                throw APIError.offline
            }
            throw APIError.networkError(urlError.localizedDescription)
        } catch {
            if (error as NSError).code == NSURLErrorCancelled {
                throw APIError.cancelled
            }
            throw APIError.networkError(error.localizedDescription)
        }
    }

    public func validateCredentials() async throws -> Bool {
        do {
            let _: ConfigValidationResponse = try await request(.validateCredentials)
            return true
        } catch APIError.unauthorized, APIError.forbidden {
            return false
        } catch {
            throw error
        }
    }
}

// Lightweight response for /configuration
private struct ConfigValidationResponse: Codable, Sendable {
    let images: ConfigImages?

    struct ConfigImages: Codable, Sendable {
        let baseUrl: String?
        enum CodingKeys: String, CodingKey {
            case baseUrl = "base_url"
        }
    }
}
