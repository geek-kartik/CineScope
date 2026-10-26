//
//  HTTPMethod.swift
//  CineScope
//

import Foundation

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}

public enum APIError: LocalizedError, Equatable, Sendable {
    case missingCredentials
    case invalidURL
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case rateLimited
    case serverError(statusCode: Int)
    case decodingError(String)
    case networkError(String)
    case offline
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .missingCredentials:
            return "TMDB API credentials are required. Please configure your API key or token in Settings."
        case .invalidURL:
            return "The requested URL was invalid."
        case .badRequest:
            return "The request parameters were invalid."
        case .unauthorized:
            return "Invalid API credentials (401). Please check your TMDB API Key or Access Token."
        case .forbidden:
            return "Access forbidden (403). Your API key does not have permission."
        case .notFound:
            return "The requested movie or resource was not found."
        case .rateLimited:
            return "Too many requests (429). Please wait a moment and try again."
        case .serverError(let code):
            return "TMDB server returned an error (HTTP \(code)). Please try again later."
        case .decodingError(let msg):
            return "Failed to parse movie data: \(msg)"
        case .networkError(let msg):
            return "Network connection issue: \(msg)"
        case .offline:
            return "No internet connection. Showing cached content if available."
        case .cancelled:
            return "Request was cancelled."
        }
    }

    public var isAuthError: Bool {
        switch self {
        case .missingCredentials, .unauthorized, .forbidden:
            return true
        default:
            return false
        }
    }
}
