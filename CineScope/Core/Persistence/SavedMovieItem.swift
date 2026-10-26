//
//  SavedMovieItem.swift
//  CineScope
//

import Foundation
import SwiftData

@Model
public final class SavedMovieItem {
    @Attribute(.unique) public var id: Int
    public var title: String
    public var overview: String
    public var posterPath: String?
    public var backdropPath: String?
    public var releaseDate: String?
    public var voteAverage: Double
    public var voteCount: Int
    public var runtime: Int?
    public var genresCSV: String
    public var isWatchlist: Bool
    public var isFavorite: Bool
    public var isWatched: Bool
    public var dateAdded: Date
    public var dateWatched: Date?
    public var userRating: Double?
    public var userReview: String?

    public init(
        id: Int,
        title: String,
        overview: String,
        posterPath: String? = nil,
        backdropPath: String? = nil,
        releaseDate: String? = nil,
        voteAverage: Double = 0.0,
        voteCount: Int = 0,
        runtime: Int? = nil,
        genresCSV: String = "",
        isWatchlist: Bool = false,
        isFavorite: Bool = false,
        isWatched: Bool = false,
        dateAdded: Date = Date(),
        dateWatched: Date? = nil,
        userRating: Double? = nil,
        userReview: String? = nil
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.runtime = runtime
        self.genresCSV = genresCSV
        self.isWatchlist = isWatchlist
        self.isFavorite = isFavorite
        self.isWatched = isWatched
        self.dateAdded = dateAdded
        self.dateWatched = dateWatched
        self.userRating = userRating
        self.userReview = userReview
    }

    public func toMovie() -> Movie {
        Movie(
            id: id,
            title: title,
            originalTitle: nil,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            voteCount: voteCount,
            popularity: nil,
            genreIds: nil,
            adult: false
        )
    }

    public func posterURL(size: String = "w500") -> URL? {
        guard let posterPath = posterPath, !posterPath.isEmpty else { return nil }
        let cleanPath = posterPath.hasPrefix("/") ? posterPath : "/\(posterPath)"
        return URL(string: "https://image.tmdb.org/t/p/\(size)\(cleanPath)")
    }

    public var formattedYear: String {
        guard let releaseDate = releaseDate, releaseDate.count >= 4 else { return "N/A" }
        return String(releaseDate.prefix(4))
    }

    public var formattedRating: String {
        if voteAverage > 0 {
            return String(format: "%.1f", voteAverage)
        }
        return "NR"
    }

    public var genreNames: [String] {
        if genresCSV.isEmpty { return [] }
        return genresCSV.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
}
