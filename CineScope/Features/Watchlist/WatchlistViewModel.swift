//
//  WatchlistViewModel.swift
//  CineScope
//

import Foundation
import Observation

public enum WatchlistViewMode: String, CaseIterable, Sendable {
    case grid = "Grid"
    case list = "List"
}

public enum WatchlistSortOption: String, CaseIterable, Identifiable, Sendable {
    case dateAdded = "Date Added"
    case title = "Title"
    case rating = "Rating"
    case releaseYear = "Release Year"

    public var id: String { rawValue }
}

public enum WatchlistFilter: String, CaseIterable, Identifiable, Sendable {
    case all = "All"
    case unwatched = "Unwatched"
    case watched = "Watched"

    public var id: String { rawValue }
}

@Observable
@MainActor
public final class WatchlistViewModel {
    public var viewMode: WatchlistViewMode = .grid
    public var sortOption: WatchlistSortOption = .dateAdded
    public var filterOption: WatchlistFilter = .all

    public var allItems: [SavedMovieItem] = []

    private let repository: UserMovieRepositoryProtocol

    public init(repository: UserMovieRepositoryProtocol) {
        self.repository = repository
        loadWatchlist()
    }

    public func loadWatchlist() {
        allItems = repository.fetchWatchlist()
    }

    public var filteredAndSortedItems: [SavedMovieItem] {
        var items = allItems

        // Filter
        switch filterOption {
        case .all:
            break
        case .unwatched:
            items = items.filter { !$0.isWatched }
        case .watched:
            items = items.filter { $0.isWatched }
        }

        // Sort
        switch sortOption {
        case .dateAdded:
            items.sort { $0.dateAdded > $1.dateAdded }
        case .title:
            items.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .rating:
            items.sort { $0.voteAverage > $1.voteAverage }
        case .releaseYear:
            items.sort { ($0.releaseDate ?? "") > ($1.releaseDate ?? "") }
        }

        return items
    }

    public func removeFromWatchlist(_ item: SavedMovieItem) {
        let movie = item.toMovie()
        repository.toggleWatchlist(movie: movie, detail: nil)
        loadWatchlist()
    }

    public func toggleWatched(_ item: SavedMovieItem) {
        let movie = item.toMovie()
        repository.toggleWatched(movie: movie, detail: nil)
        loadWatchlist()
    }
}
