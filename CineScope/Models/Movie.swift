//
//  Movie.swift
//  CineScope
//

import Foundation

nonisolated public struct Movie: Codable, Identifiable, Hashable, Sendable {
    public let id: Int
    public let title: String
    public let originalTitle: String?
    public let overview: String
    public let posterPath: String?
    public let backdropPath: String?
    public let releaseDate: String?
    public let voteAverage: Double
    public let voteCount: Int
    public let popularity: Double?
    public let genreIds: [Int]?
    public let adult: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case originalTitle = "original_title"
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case popularity
        case genreIds = "genre_ids"
        case adult
    }

    public init(
        id: Int,
        title: String,
        originalTitle: String? = nil,
        overview: String,
        posterPath: String? = nil,
        backdropPath: String? = nil,
        releaseDate: String? = nil,
        voteAverage: Double = 0.0,
        voteCount: Int = 0,
        popularity: Double? = nil,
        genreIds: [Int]? = nil,
        adult: Bool? = nil
    ) {
        self.id = id
        self.title = title
        self.originalTitle = originalTitle
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.popularity = popularity
        self.genreIds = genreIds
        self.adult = adult
    }

    public func posterURL(size: String = "w500") -> URL? {
        guard let posterPath = posterPath, !posterPath.isEmpty else { return nil }
        let cleanPath = posterPath.hasPrefix("/") ? posterPath : "/\(posterPath)"
        return URL(string: "https://image.tmdb.org/t/p/\(size)\(cleanPath)")
    }

    public func backdropURL(size: String = "w1280") -> URL? {
        guard let backdropPath = backdropPath, !backdropPath.isEmpty else { return nil }
        let cleanPath = backdropPath.hasPrefix("/") ? backdropPath : "/\(backdropPath)"
        return URL(string: "https://image.tmdb.org/t/p/\(size)\(cleanPath)")
    }

    public var formattedYear: String {
        guard let releaseDate = releaseDate, releaseDate.count >= 4 else { return "N/A" }
        return String(releaseDate.prefix(4))
    }

    public var formattedRating: String {
        if voteAverage > 0 {
            return String(format: "%.1f", locale: Locale(identifier: "en_US_POSIX"), voteAverage)
        }
        return "NR"
    }

    public var genreNames: [String] {
        MovieGenres.names(for: genreIds)
    }

    public var primaryGenre: String? {
        genreNames.first
    }
}
