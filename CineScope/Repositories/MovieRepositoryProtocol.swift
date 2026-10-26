//
//  MovieRepositoryProtocol.swift
//  CineScope
//

import Foundation

public protocol MovieRepositoryProtocol: Sendable {
    func getTrending(timeWindow: String, page: Int) async throws -> PageResult<Movie>
    func getPopular(page: Int) async throws -> PageResult<Movie>
    func getNowPlaying(page: Int) async throws -> PageResult<Movie>
    func getUpcoming(page: Int) async throws -> PageResult<Movie>
    func getTopRated(page: Int) async throws -> PageResult<Movie>
    func getMovieDetails(id: Int) async throws -> MovieDetail
    func searchMovies(query: String, page: Int) async throws -> PageResult<Movie>
    func getMoviesByGenre(genreId: Int, page: Int) async throws -> PageResult<Movie>
}

public extension MovieRepositoryProtocol {
    func getTrending(timeWindow: String = "day", page: Int = 1) async throws -> PageResult<Movie> {
        try await getTrending(timeWindow: timeWindow, page: page)
    }
    func getPopular(page: Int = 1) async throws -> PageResult<Movie> {
        try await getPopular(page: page)
    }
    func getNowPlaying(page: Int = 1) async throws -> PageResult<Movie> {
        try await getNowPlaying(page: page)
    }
    func getUpcoming(page: Int = 1) async throws -> PageResult<Movie> {
        try await getUpcoming(page: page)
    }
    func getTopRated(page: Int = 1) async throws -> PageResult<Movie> {
        try await getTopRated(page: page)
    }
    func searchMovies(query: String, page: Int = 1) async throws -> PageResult<Movie> {
        try await searchMovies(query: query, page: page)
    }
    func getMoviesByGenre(genreId: Int, page: Int = 1) async throws -> PageResult<Movie> {
        try await getMoviesByGenre(genreId: genreId, page: page)
    }
}
