//
//  APIClientProtocol.swift
//  CineScope
//

import Foundation

public protocol APIClientProtocol: Sendable {
    func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T
    func validateCredentials() async throws -> Bool
}
