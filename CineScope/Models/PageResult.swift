//
//  PageResult.swift
//  CineScope
//

import Foundation

nonisolated public struct PageResult<T: Codable & Sendable>: Codable, Sendable {
    public let page: Int
    public let results: [T]
    public let totalPages: Int
    public let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }

    public init(page: Int = 1, results: [T] = [], totalPages: Int = 1, totalResults: Int = 0) {
        self.page = page
        self.results = results
        self.totalPages = totalPages
        self.totalResults = totalResults
    }

    public var hasMorePages: Bool {
        page < totalPages
    }
}
