//
//  MovieDetail.swift
//  CineScope
//

import Foundation

nonisolated public struct ProductionCompany: Codable, Identifiable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let logoPath: String?
    public let originCountry: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case logoPath = "logo_path"
        case originCountry = "origin_country"
    }

    public init(id: Int, name: String, logoPath: String? = nil, originCountry: String? = nil) {
        self.id = id
        self.name = name
        self.logoPath = logoPath
        self.originCountry = originCountry
    }
}

nonisolated public struct MovieDetail: Codable, Identifiable, Sendable {
    public let id: Int
    public let title: String
    public let originalTitle: String?
    public let tagline: String?
    public let overview: String
    public let posterPath: String?
    public let backdropPath: String?
    public let releaseDate: String?
    public let runtime: Int?
    public let voteAverage: Double
    public let voteCount: Int
    public let status: String?
    public let budget: Int?
    public let revenue: Int?
    public let originalLanguage: String?
    public let genres: [Genre]
    public let productionCompanies: [ProductionCompany]?
    public let credits: Credits?
    public let videos: VideoResponse?
    public let recommendations: PageResult<Movie>?
    public let similar: PageResult<Movie>?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case originalTitle = "original_title"
        case tagline
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case runtime
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case status
        case budget
        case revenue
        case originalLanguage = "original_language"
        case genres
        case productionCompanies = "production_companies"
        case credits
        case videos
        case recommendations
        case similar
    }

    public init(
        id: Int,
        title: String,
        originalTitle: String? = nil,
        tagline: String? = nil,
        overview: String,
        posterPath: String? = nil,
        backdropPath: String? = nil,
        releaseDate: String? = nil,
        runtime: Int? = nil,
        voteAverage: Double = 0.0,
        voteCount: Int = 0,
        status: String? = nil,
        budget: Int? = nil,
        revenue: Int? = nil,
        originalLanguage: String? = nil,
        genres: [Genre] = [],
        productionCompanies: [ProductionCompany]? = nil,
        credits: Credits? = nil,
        videos: VideoResponse? = nil,
        recommendations: PageResult<Movie>? = nil,
        similar: PageResult<Movie>? = nil
    ) {
        self.id = id
        self.title = title
        self.originalTitle = originalTitle
        self.tagline = tagline
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.runtime = runtime
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.status = status
        self.budget = budget
        self.revenue = revenue
        self.originalLanguage = originalLanguage
        self.genres = genres
        self.productionCompanies = productionCompanies
        self.credits = credits
        self.videos = videos
        self.recommendations = recommendations
        self.similar = similar
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

    public var formattedRuntime: String {
        guard let runtime = runtime, runtime > 0 else { return "N/A" }
        let hours = runtime / 60
        let minutes = runtime % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    public var formattedReleaseDate: String {
        guard let releaseDate = releaseDate, !releaseDate.isEmpty else { return "N/A" }
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        if let date = inputFormatter.date(from: releaseDate) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .medium
            return outputFormatter.string(from: date)
        }
        return releaseDate
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

    public var formattedBudget: String {
        guard let budget = budget, budget > 0 else { return "N/A" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: budget)) ?? "$\(budget)"
    }

    public var formattedRevenue: String {
        guard let revenue = revenue, revenue > 0 else { return "N/A" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: revenue)) ?? "$\(revenue)"
    }

    public var director: CrewMember? {
        credits?.director
    }

    public var trailerVideo: Video? {
        videos?.primaryTrailer
    }

    public var trailerURL: URL? {
        trailerVideo?.youTubeURL
    }

    public func toMovie() -> Movie {
        Movie(
            id: id,
            title: title,
            originalTitle: originalTitle,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage,
            voteCount: voteCount,
            popularity: nil,
            genreIds: genres.map(\.id),
            adult: false
        )
    }
}
