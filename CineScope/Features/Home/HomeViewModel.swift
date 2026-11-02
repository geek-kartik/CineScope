//
//  HomeViewModel.swift
//  CineScope
//

import Foundation
import Observation

public enum HomeSection: String, CaseIterable, Identifiable, Sendable {
    case trending
    case nowPlaying
    case topRated
    case popular
    case upcoming

    public var id: String { rawValue }
}

@Observable
@MainActor
public final class HomeViewModel {
    public var heroMovie: Movie?
    public var trendingMovies: [Movie] = []
    public var nowPlayingMovies: [Movie] = []
    public var topRatedMovies: [Movie] = []
    public var popularMovies: [Movie] = []
    public var upcomingMovies: [Movie] = []

    public var isLoading: Bool = false
    public var isRefreshing: Bool = false
    public var errorMessage: String? = nil
    public var isMissingCredentials: Bool = false

    public var activeTrailerURL: URL? = nil
    public var showTrailerSheet: Bool = false

    public private(set) var loadingMoreSections: Set<HomeSection> = []
    public private(set) var watchlistMovieIDs: Set<Int> = []

    private let movieRepository: MovieRepositoryProtocol
    private let userMovieRepository: UserMovieRepositoryProtocol
    private let apiConfig: APIConfig
    private let prefetchThreshold: Int = 3
    private var currentPages: [HomeSection: Int] = [:]
    private var totalPagesBySection: [HomeSection: Int] = [:]
    private var feedGeneration: Int = 0

    public init(
        movieRepository: MovieRepositoryProtocol = MovieRepository.shared,
        userMovieRepository: UserMovieRepositoryProtocol,
        apiConfig: APIConfig = .shared
    ) {
        self.movieRepository = movieRepository
        self.userMovieRepository = userMovieRepository
        self.apiConfig = apiConfig
    }

    public func loadFeed() async {
        guard !isLoading else { return }

        refreshUserMovieState()

        if !apiConfig.hasCredentials {
            isMissingCredentials = true
            isLoading = false
            isRefreshing = false
            return
        }
        isMissingCredentials = false

        isLoading = true
        errorMessage = nil

        feedGeneration += 1
        let generation = feedGeneration

        defer {
            isLoading = false
            isRefreshing = false
        }

        do {
            async let trendingTask = movieRepository.getTrending(timeWindow: "day", page: 1)
            async let nowPlayingTask = movieRepository.getNowPlaying(page: 1)
            async let topRatedTask = movieRepository.getTopRated(page: 1)
            async let popularTask = movieRepository.getPopular(page: 1)
            async let upcomingTask = movieRepository.getUpcoming(page: 1)

            let (trending, nowPlaying, topRated, popular, upcoming) = try await (
                trendingTask, nowPlayingTask, topRatedTask, popularTask, upcomingTask
            )

            guard !Task.isCancelled, generation == feedGeneration else { return }

            self.trendingMovies = trending.results
            self.heroMovie = trending.results.first ?? popular.results.first
            self.nowPlayingMovies = nowPlaying.results
            self.topRatedMovies = topRated.results
            self.popularMovies = popular.results
            self.upcomingMovies = upcoming.results
            self.currentPages = [
                .trending: trending.page,
                .nowPlaying: nowPlaying.page,
                .topRated: topRated.page,
                .popular: popular.page,
                .upcoming: upcoming.page
            ]
            self.totalPagesBySection = [
                .trending: trending.totalPages,
                .nowPlaying: nowPlaying.totalPages,
                .topRated: topRated.totalPages,
                .popular: popular.totalPages,
                .upcoming: upcoming.totalPages
            ]
            // Any in-flight "load more" requests belong to the previous feed
            // generation and should not append stale pages.
            self.loadingMoreSections.removeAll()
        } catch let apiErr as APIError {
            guard !Task.isCancelled, apiErr != .cancelled, generation == feedGeneration else { return }
            if apiErr.isAuthError {
                self.isMissingCredentials = true
            }
            self.errorMessage = apiErr.localizedDescription
        } catch {
            guard !Task.isCancelled, generation == feedGeneration else { return }
            self.errorMessage = error.localizedDescription
        }
    }

    public func refresh() async {
        isRefreshing = true
        await loadFeed()
    }

    public func isLoadingMore(section: HomeSection) -> Bool {
        loadingMoreSections.contains(section)
    }

    public func shouldLoadMore(section: HomeSection, movie: Movie) -> Bool {
        let sectionMovies = movies(for: section)
        guard let index = sectionMovies.firstIndex(where: { $0.id == movie.id }) else {
            return false
        }
        guard (currentPages[section] ?? 1) < (totalPagesBySection[section] ?? 1) else {
            return false
        }
        return index >= max(0, sectionMovies.count - prefetchThreshold)
    }

    public func loadMore(section: HomeSection) async {
        guard !isLoading, !loadingMoreSections.contains(section) else { return }

        let nextPage = (currentPages[section] ?? 1) + 1
        guard nextPage <= (totalPagesBySection[section] ?? 1) else { return }

        let generation = feedGeneration
        loadingMoreSections.insert(section)
        defer { loadingMoreSections.remove(section) }

        do {
            let result = try await fetchPage(section: section, page: nextPage)
            guard !Task.isCancelled, generation == feedGeneration else { return }

            let existingIDs = Set(movies(for: section).map(\.id))
            let newMovies = result.results.filter { !existingIDs.contains($0.id) }
            append(newMovies, to: section)
            currentPages[section] = result.page
            totalPagesBySection[section] = result.totalPages
        } catch let apiError as APIError {
            guard !Task.isCancelled, apiError != .cancelled else { return }
        } catch {
            guard !Task.isCancelled else { return }
        }
    }

    public func refreshUserMovieState() {
        watchlistMovieIDs = Set(userMovieRepository.fetchWatchlist().map(\.id))
    }

    public func isInWatchlist(movie: Movie) -> Bool {
        watchlistMovieIDs.contains(movie.id)
    }

    public func toggleWatchlist(for movie: Movie) {
        let isNowInWatchlist = userMovieRepository.toggleWatchlist(movie: movie, detail: nil)
        if isNowInWatchlist {
            watchlistMovieIDs.insert(movie.id)
        } else {
            watchlistMovieIDs.remove(movie.id)
        }
    }

    public func openHeroTrailer() async {
        guard let hero = heroMovie else { return }
        do {
            let details = try await movieRepository.getMovieDetails(id: hero.id)
            if let trailerURL = details.trailerURL {
                self.activeTrailerURL = trailerURL
                self.showTrailerSheet = true
            }
        } catch {
            // Trailer fallback handled gracefully
        }
    }

    private func movies(for section: HomeSection) -> [Movie] {
        switch section {
        case .trending: return trendingMovies
        case .nowPlaying: return nowPlayingMovies
        case .topRated: return topRatedMovies
        case .popular: return popularMovies
        case .upcoming: return upcomingMovies
        }
    }

    private func append(_ movies: [Movie], to section: HomeSection) {
        switch section {
        case .trending: trendingMovies.append(contentsOf: movies)
        case .nowPlaying: nowPlayingMovies.append(contentsOf: movies)
        case .topRated: topRatedMovies.append(contentsOf: movies)
        case .popular: popularMovies.append(contentsOf: movies)
        case .upcoming: upcomingMovies.append(contentsOf: movies)
        }
    }

    private func fetchPage(section: HomeSection, page: Int) async throws -> PageResult<Movie> {
        switch section {
        case .trending:
            return try await movieRepository.getTrending(timeWindow: "day", page: page)
        case .nowPlaying:
            return try await movieRepository.getNowPlaying(page: page)
        case .topRated:
            return try await movieRepository.getTopRated(page: page)
        case .popular:
            return try await movieRepository.getPopular(page: page)
        case .upcoming:
            return try await movieRepository.getUpcoming(page: page)
        }
    }
}
