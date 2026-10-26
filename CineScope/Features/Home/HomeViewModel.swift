//
//  HomeViewModel.swift
//  CineScope
//

import Foundation
import Observation

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

    private let movieRepository: MovieRepositoryProtocol
    private let userMovieRepository: UserMovieRepositoryProtocol
    private let apiConfig: APIConfig

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

        if !apiConfig.hasCredentials {
            isMissingCredentials = true
            return
        }
        isMissingCredentials = false

        if trendingMovies.isEmpty {
            isLoading = true
        }
        errorMessage = nil

        do {
            async let trendingTask = movieRepository.getTrending(timeWindow: "day", page: 1)
            async let nowPlayingTask = movieRepository.getNowPlaying(page: 1)
            async let topRatedTask = movieRepository.getTopRated(page: 1)
            async let popularTask = movieRepository.getPopular(page: 1)
            async let upcomingTask = movieRepository.getUpcoming(page: 1)

            let (trending, nowPlaying, topRated, popular, upcoming) = try await (
                trendingTask, nowPlayingTask, topRatedTask, popularTask, upcomingTask
            )

            self.trendingMovies = trending.results
            self.heroMovie = trending.results.first ?? popular.results.first
            self.nowPlayingMovies = nowPlaying.results
            self.topRatedMovies = topRated.results
            self.popularMovies = popular.results
            self.upcomingMovies = upcoming.results
            self.isLoading = false
            self.isRefreshing = false
        } catch let apiErr as APIError {
            self.isLoading = false
            self.isRefreshing = false
            if apiErr.isAuthError {
                self.isMissingCredentials = true
            }
            self.errorMessage = apiErr.localizedDescription
        } catch {
            self.isLoading = false
            self.isRefreshing = false
            self.errorMessage = error.localizedDescription
        }
    }

    public func refresh() async {
        isRefreshing = true
        await loadFeed()
    }

    public func isInWatchlist(movie: Movie) -> Bool {
        userMovieRepository.status(for: movie.id).isInWatchlist
    }

    public func toggleWatchlist(for movie: Movie) {
        userMovieRepository.toggleWatchlist(movie: movie, detail: nil)
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
}
