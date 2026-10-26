//
//  MovieDetailsViewModel.swift
//  CineScope
//

import Foundation
import Observation

@Observable
@MainActor
public final class MovieDetailsViewModel {
    public let movieId: Int
    public var initialMovie: Movie?
    public var movieDetail: MovieDetail?

    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    public var showTrailerSheet: Bool = false

    public var userStatus: UserMovieStatus = .empty
    public var personalRating: Double? = nil
    public var personalReview: String = ""

    private let movieRepository: MovieRepositoryProtocol
    private let userMovieRepository: UserMovieRepositoryProtocol

    public init(
        movieId: Int,
        initialMovie: Movie? = nil,
        movieRepository: MovieRepositoryProtocol = MovieRepository.shared,
        userMovieRepository: UserMovieRepositoryProtocol
    ) {
        self.movieId = movieId
        self.initialMovie = initialMovie
        self.movieRepository = movieRepository
        self.userMovieRepository = userMovieRepository
        syncUserStatus()
    }

    public func loadDetails() async {
        syncUserStatus()
        guard !isLoading else { return }

        if movieDetail == nil {
            isLoading = true
        }
        errorMessage = nil

        do {
            let detail = try await movieRepository.getMovieDetails(id: movieId)
            self.movieDetail = detail
            self.isLoading = false
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }

    public func syncUserStatus() {
        let status = userMovieRepository.status(for: movieId)
        self.userStatus = status
        self.personalRating = status.userRating
        self.personalReview = status.userReview ?? ""
    }

    public func toggleWatchlist() {
        let movie = asMovie()
        _ = userMovieRepository.toggleWatchlist(movie: movie, detail: movieDetail)
        syncUserStatus()
    }

    public func toggleFavorite() {
        let movie = asMovie()
        _ = userMovieRepository.toggleFavorite(movie: movie, detail: movieDetail)
        syncUserStatus()
    }

    public func toggleWatched() {
        let movie = asMovie()
        _ = userMovieRepository.toggleWatched(movie: movie, detail: movieDetail)
        syncUserStatus()
    }

    public func savePersonalReview(rating: Double?, review: String) {
        userMovieRepository.updateUserReview(movieId: movieId, rating: rating, review: review)
        syncUserStatus()
    }

    private func asMovie() -> Movie {
        if let detail = movieDetail {
            return detail.toMovie()
        }
        if let initM = initialMovie {
            return initM
        }
        return Movie(
            id: movieId,
            title: "Movie #\(movieId)",
            overview: ""
        )
    }
}
