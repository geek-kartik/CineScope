//
//  LibraryViewModel.swift
//  CineScope
//

import Foundation
import Observation

public enum LibrarySegment: String, CaseIterable, Identifiable, Sendable {
    case watched = "Watched"
    case favorites = "Favorites"
    case reviews = "My Reviews"

    public var id: String { rawValue }
}

@Observable
@MainActor
public final class LibraryViewModel {
    public var selectedSegment: LibrarySegment = .watched
    public var stats: LibraryStats = LibraryStats()

    public var watchedMovies: [SavedMovieItem] = []
    public var favoriteMovies: [SavedMovieItem] = []
    public var reviewedMovies: [SavedMovieItem] = []

    private let repository: UserMovieRepositoryProtocol

    public init(repository: UserMovieRepositoryProtocol) {
        self.repository = repository
        loadLibrary()
    }

    public func loadLibrary() {
        self.watchedMovies = repository.fetchWatched()
        self.favoriteMovies = repository.fetchFavorites()
        self.reviewedMovies = watchedMovies.filter {
            let hasReview = !($0.userReview?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
            let hasRating = $0.userRating != nil
            return hasReview || hasRating
        }
        self.stats = repository.libraryStatistics()
    }

    public var currentItems: [SavedMovieItem] {
        switch selectedSegment {
        case .watched:
            return watchedMovies
        case .favorites:
            return favoriteMovies
        case .reviews:
            return reviewedMovies
        }
    }

    public func removeMovie(_ item: SavedMovieItem) {
        repository.removeItem(movieId: item.id)
        loadLibrary()
    }
}
