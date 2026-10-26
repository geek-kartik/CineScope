//
//  UserMovieRepository.swift
//  CineScope
//

import Foundation
import SwiftData

@MainActor
public final class UserMovieRepository: UserMovieRepositoryProtocol {
    private let context: ModelContext
    private let container: ModelContainer?

    public init(context: ModelContext, container: ModelContainer? = nil) {
        self.context = context
        self.container = container
    }

    public func fetchWatchlist() -> [SavedMovieItem] {
        let descriptor = FetchDescriptor<SavedMovieItem>(
            predicate: #Predicate { $0.isWatchlist },
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    public func fetchFavorites() -> [SavedMovieItem] {
        let descriptor = FetchDescriptor<SavedMovieItem>(
            predicate: #Predicate { $0.isFavorite },
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    public func fetchWatched() -> [SavedMovieItem] {
        let descriptor = FetchDescriptor<SavedMovieItem>(
            predicate: #Predicate { $0.isWatched },
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    public func getItem(id: Int) -> SavedMovieItem? {
        let targetId = id
        let descriptor = FetchDescriptor<SavedMovieItem>(
            predicate: #Predicate<SavedMovieItem> { item in
                item.id == targetId
            }
        )
        return (try? context.fetch(descriptor))?.first
    }

    public func status(for movieId: Int) -> UserMovieStatus {
        guard let item = getItem(id: movieId) else {
            return .empty
        }
        return UserMovieStatus(
            isInWatchlist: item.isWatchlist,
            isFavorite: item.isFavorite,
            isWatched: item.isWatched,
            userRating: item.userRating,
            userReview: item.userReview
        )
    }

    @discardableResult
    public func toggleWatchlist(movie: Movie, detail: MovieDetail? = nil) -> Bool {
        let item = getOrCreateItem(movie: movie, detail: detail)
        item.isWatchlist.toggle()
        cleanupOrSave(item)
        return item.isWatchlist
    }

    @discardableResult
    public func toggleFavorite(movie: Movie, detail: MovieDetail? = nil) -> Bool {
        let item = getOrCreateItem(movie: movie, detail: detail)
        item.isFavorite.toggle()
        cleanupOrSave(item)
        return item.isFavorite
    }

    @discardableResult
    public func toggleWatched(movie: Movie, detail: MovieDetail? = nil) -> Bool {
        let item = getOrCreateItem(movie: movie, detail: detail)
        item.isWatched.toggle()
        if item.isWatched {
            item.dateWatched = Date()
        } else {
            item.dateWatched = nil
        }
        cleanupOrSave(item)
        return item.isWatched
    }

    public func updateUserReview(movieId: Int, rating: Double?, review: String?) {
        guard let item = getItem(id: movieId) else { return }
        item.userRating = rating
        item.userReview = review
        cleanupOrSave(item)
    }

    public func removeItem(movieId: Int) {
        if let item = getItem(id: movieId) {
            context.delete(item)
            try? context.save()
        }
    }

    public func clearAllData() {
        let descriptor = FetchDescriptor<SavedMovieItem>()
        if let allItems = try? context.fetch(descriptor) {
            for item in allItems {
                context.delete(item)
            }
            try? context.save()
        }
    }

    public func libraryStatistics() -> LibraryStats {
        let watched = fetchWatched()
        let totalWatched = watched.count

        let totalMinutes = watched.reduce(0) { sum, item in
            sum + (item.runtime ?? 110)
        }

        let ratings = watched.compactMap(\.userRating)
        let avgRating: Double? = ratings.isEmpty ? nil : (ratings.reduce(0, +) / Double(ratings.count))

        var genreCounts: [String: Int] = [:]
        for item in watched {
            for genre in item.genreNames {
                genreCounts[genre, default: 0] += 1
            }
        }
        let topGenres = genreCounts.sorted { $0.value > $1.value }.prefix(3).map(\.key)

        return LibraryStats(
            totalWatched: totalWatched,
            totalRuntimeMinutes: totalMinutes,
            averageRating: avgRating,
            topGenres: Array(topGenres)
        )
    }

    // MARK: - Private Helpers

    private func getOrCreateItem(movie: Movie, detail: MovieDetail?) -> SavedMovieItem {
        if let existing = getItem(id: movie.id) {
            if let detail = detail {
                if existing.runtime == nil { existing.runtime = detail.runtime }
                if existing.genresCSV.isEmpty {
                    existing.genresCSV = detail.genres.map(\.name).joined(separator: ", ")
                }
            }
            return existing
        }

        let genres = detail?.genres.map(\.name).joined(separator: ", ")
            ?? movie.genreNames.joined(separator: ", ")

        let newItem = SavedMovieItem(
            id: movie.id,
            title: movie.title,
            overview: movie.overview,
            posterPath: movie.posterPath,
            backdropPath: movie.backdropPath,
            releaseDate: movie.releaseDate,
            voteAverage: movie.voteAverage,
            voteCount: movie.voteCount,
            runtime: detail?.runtime,
            genresCSV: genres,
            isWatchlist: false,
            isFavorite: false,
            isWatched: false,
            dateAdded: Date()
        )
        context.insert(newItem)
        return newItem
    }

    private func cleanupOrSave(_ item: SavedMovieItem) {
        let isReviewEmpty = (item.userReview?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let hasNoReviewOrRating = isReviewEmpty && item.userRating == nil

        if !item.isWatchlist && !item.isFavorite && !item.isWatched && hasNoReviewOrRating {
            context.delete(item)
        }
        try? context.save()
    }
}
