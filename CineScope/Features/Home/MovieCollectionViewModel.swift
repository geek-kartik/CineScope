//
//  MovieCollectionViewModel.swift
//  CineScope
//

import Foundation
import Observation

@Observable
@MainActor
public final class MovieCollectionViewModel {
    public let collectionType: CollectionType

    public private(set) var movies: [Movie] = []
    public private(set) var isLoading: Bool = false
    public private(set) var isLoadingMore: Bool = false
    public private(set) var errorMessage: String? = nil

    private let repository: MovieRepositoryProtocol
    private let prefetchThreshold: Int
    private var currentPage: Int = 0
    private var totalPages: Int = 1
    private var loadedMovieIDs: Set<Int> = []

    public init(
        collectionType: CollectionType,
        repository: MovieRepositoryProtocol = MovieRepository.shared,
        prefetchThreshold: Int = 4
    ) {
        self.collectionType = collectionType
        self.repository = repository
        self.prefetchThreshold = max(1, prefetchThreshold)
    }

    public var hasMorePages: Bool {
        currentPage < totalPages
    }

    public func loadInitialIfNeeded() async {
        guard movies.isEmpty, !isLoading, !isLoadingMore else { return }
        await loadPage(1, replacing: true)
    }

    public func loadMoreIfNeeded(at index: Int) async {
        guard shouldPrefetch(at: index) else { return }
        await loadMore()
    }

    public func loadMore() async {
        guard !isLoading, !isLoadingMore, currentPage < totalPages else { return }
        await loadPage(currentPage + 1, replacing: false)
    }

    public func retry() async {
        if movies.isEmpty {
            await loadPage(1, replacing: true)
        } else {
            await loadMore()
        }
    }

    public func shouldPrefetch(at index: Int) -> Bool {
        guard !movies.isEmpty, currentPage < totalPages else { return false }
        return index >= max(0, movies.count - prefetchThreshold)
    }

    private func loadPage(_ page: Int, replacing: Bool) async {
        if replacing {
            isLoading = true
        } else {
            isLoadingMore = true
        }
        errorMessage = nil

        defer {
            if replacing {
                isLoading = false
            } else {
                isLoadingMore = false
            }
        }

        do {
            let result = try await fetchPage(page)
            guard !Task.isCancelled else { return }

            if replacing {
                movies = result.results
                loadedMovieIDs = Set(result.results.map(\.id))
            } else {
                let newMovies = result.results.filter { !loadedMovieIDs.contains($0.id) }
                movies.append(contentsOf: newMovies)
                loadedMovieIDs.formUnion(newMovies.map(\.id))
            }

            currentPage = result.page
            totalPages = result.totalPages
        } catch let apiError as APIError {
            guard !Task.isCancelled, apiError != .cancelled else { return }
            errorMessage = apiError.localizedDescription
        } catch {
            guard !Task.isCancelled else { return }
            errorMessage = error.localizedDescription
        }
    }

    private func fetchPage(_ page: Int) async throws -> PageResult<Movie> {
        switch collectionType {
        case .trending:
            return try await repository.getTrending(timeWindow: "day", page: page)
        case .nowPlaying:
            return try await repository.getNowPlaying(page: page)
        case .topRated:
            return try await repository.getTopRated(page: page)
        case .popular:
            return try await repository.getPopular(page: page)
        case .upcoming:
            return try await repository.getUpcoming(page: page)
        }
    }
}
