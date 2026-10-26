//
//  Genre.swift
//  CineScope
//

import Foundation

nonisolated public struct Genre: Codable, Identifiable, Hashable, Sendable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

nonisolated public struct GenreResponse: Codable, Sendable {
    public let genres: [Genre]

    public init(genres: [Genre]) {
        self.genres = genres
    }
}

nonisolated public enum MovieGenres {
    public static let standard: [Genre] = [
        Genre(id: 28, name: "Action"),
        Genre(id: 12, name: "Adventure"),
        Genre(id: 16, name: "Animation"),
        Genre(id: 35, name: "Comedy"),
        Genre(id: 80, name: "Crime"),
        Genre(id: 99, name: "Documentary"),
        Genre(id: 18, name: "Drama"),
        Genre(id: 10751, name: "Family"),
        Genre(id: 14, name: "Fantasy"),
        Genre(id: 36, name: "History"),
        Genre(id: 27, name: "Horror"),
        Genre(id: 10402, name: "Music"),
        Genre(id: 9648, name: "Mystery"),
        Genre(id: 10749, name: "Romance"),
        Genre(id: 878, name: "Sci-Fi"),
        Genre(id: 10770, name: "TV Movie"),
        Genre(id: 53, name: "Thriller"),
        Genre(id: 10752, name: "War"),
        Genre(id: 37, name: "Western")
    ]

    private static let genreMap: [Int: String] = {
        var map: [Int: String] = [:]
        for genre in standard {
            map[genre.id] = genre.name
        }
        return map
    }()

    public static func name(for id: Int) -> String? {
        genreMap[id]
    }

    public static func names(for ids: [Int]?) -> [String] {
        guard let ids = ids else { return [] }
        return ids.compactMap { genreMap[$0] }
    }
}
