//
//  UserMovieRepositoryProtocol.swift
//  CineScope
//

import Foundation

public struct LibraryStats: Equatable, Sendable {
    public let totalWatched: Int
    public let totalRuntimeMinutes: Int
    public let averageRating: Double?
    public let topGenres: [String]

    public init(
        totalWatched: Int = 0,
        totalRuntimeMinutes: Int = 0,
        averageRating: Double? = nil,
        topGenres: [String] = []
    ) {
        self.totalWatched = totalWatched
        self.totalRuntimeMinutes = totalRuntimeMinutes
        self.averageRating = averageRating
        self.topGenres = topGenres
    }

    public var formattedWatchTime: String {
        let hours = totalRuntimeMinutes / 60
        let minutes = totalRuntimeMinutes % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

@MainActor
public protocol UserMovieRepositoryProtocol: AnyObject {
    func fetchWatchlist() -> [SavedMovieItem]
    func fetchFavorites() -> [SavedMovieItem]
    func fetchWatched() -> [SavedMovieItem]
    func getItem(id: Int) -> SavedMovieItem?
    func status(for movieId: Int) -> UserMovieStatus
    @discardableResult func toggleWatchlist(movie: Movie, detail: MovieDetail?) -> Bool
    @discardableResult func toggleFavorite(movie: Movie, detail: MovieDetail?) -> Bool
    @discardableResult func toggleWatched(movie: Movie, detail: MovieDetail?) -> Bool
    func updateUserReview(movieId: Int, rating: Double?, review: String?)
    func removeItem(movieId: Int)
    func clearAllData()
    func libraryStatistics() -> LibraryStats
}
