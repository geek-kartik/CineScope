//
//  UserMovieStatus.swift
//  CineScope
//

import Foundation

nonisolated public struct UserMovieStatus: Equatable, Sendable {
    public var isInWatchlist: Bool
    public var isFavorite: Bool
    public var isWatched: Bool
    public var userRating: Double?
    public var userReview: String?

    public init(
        isInWatchlist: Bool = false,
        isFavorite: Bool = false,
        isWatched: Bool = false,
        userRating: Double? = nil,
        userReview: String? = nil
    ) {
        self.isInWatchlist = isInWatchlist
        self.isFavorite = isFavorite
        self.isWatched = isWatched
        self.userRating = userRating
        self.userReview = userReview
    }

    public static let empty = UserMovieStatus()
}
