//
//  MockAPIClient.swift
//  CineScopeTests
//

import Foundation
@testable import CineScope

public final class MockAPIClient: APIClientProtocol, @unchecked Sendable {
    public var shouldThrowError: APIError? = nil
    public var customResponse: Any? = nil

    private let lock = NSLock()
    private var _requestCount = 0

    public var requestCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return _requestCount
    }

    public init() {}

    public func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T {
        lock.lock()
        _requestCount += 1
        lock.unlock()

        if let err = shouldThrowError {
            throw err
        }

        if let custom = customResponse as? T {
            return custom
        }

        switch endpoint {
        case .movieDetails:
            let data = MockData.sampleDetailJSON.data(using: .utf8)!
            return try JSONDecoder().decode(T.self, from: data)
        case .trending, .popular, .nowPlaying, .upcoming, .topRated, .search, .discoverByGenre, .recommendations, .similar:
            let data = MockData.samplePageResultJSON.data(using: .utf8)!
            return try JSONDecoder().decode(T.self, from: data)
        case .genres:
            let response = GenreResponse(genres: MovieGenres.standard)
            return response as! T
        case .validateCredentials:
            return true as! T
        case .credits, .videos:
            let data = MockData.sampleDetailJSON.data(using: .utf8)!
            return try JSONDecoder().decode(T.self, from: data)
        }
    }

    public func validateCredentials() async throws -> Bool {
        if let err = shouldThrowError {
            throw err
        }
        return true
    }
}
