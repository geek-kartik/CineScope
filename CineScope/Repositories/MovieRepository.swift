//
//  MovieRepository.swift
//  CineScope
//

import Foundation

public actor MovieRepository: MovieRepositoryProtocol {
    public static let shared = MovieRepository()

    private let apiClient: APIClientProtocol
    private var memoryCache: [String: Any] = [:]

    public init(apiClient: APIClientProtocol = URLSessionAPIClient.shared) {
        self.apiClient = apiClient
    }

    public func getTrending(timeWindow: String = "day", page: Int = 1) async throws -> PageResult<Movie> {
        let endpoint = APIEndpoint.trending(timeWindow: timeWindow, page: page)
        return try await fetchWithCache(key: "trending_\(timeWindow)_\(page)", endpoint: endpoint)
    }

    public func getPopular(page: Int = 1) async throws -> PageResult<Movie> {
        let endpoint = APIEndpoint.popular(page: page)
        return try await fetchWithCache(key: "popular_\(page)", endpoint: endpoint)
    }

    public func getNowPlaying(page: Int = 1) async throws -> PageResult<Movie> {
        let endpoint = APIEndpoint.nowPlaying(page: page)
        return try await fetchWithCache(key: "now_playing_\(page)", endpoint: endpoint)
    }

    public func getUpcoming(page: Int = 1) async throws -> PageResult<Movie> {
        let endpoint = APIEndpoint.upcoming(page: page)
        return try await fetchWithCache(key: "upcoming_\(page)", endpoint: endpoint)
    }

    public func getTopRated(page: Int = 1) async throws -> PageResult<Movie> {
        let endpoint = APIEndpoint.topRated(page: page)
        return try await fetchWithCache(key: "top_rated_\(page)", endpoint: endpoint)
    }

    public func getMovieDetails(id: Int) async throws -> MovieDetail {
        let endpoint = APIEndpoint.movieDetails(id: id)
        return try await fetchWithCache(key: "details_\(id)", endpoint: endpoint)
    }

    public func searchMovies(query: String, page: Int = 1) async throws -> PageResult<Movie> {
        let endpoint = APIEndpoint.search(query: query, page: page)
        return try await apiClient.request(endpoint)
    }

    public func getMoviesByGenre(genreId: Int, page: Int = 1) async throws -> PageResult<Movie> {
        let endpoint = APIEndpoint.discoverByGenre(genreId: genreId, page: page)
        return try await fetchWithCache(key: "genre_\(genreId)_\(page)", endpoint: endpoint)
    }

    // MARK: - Caching Helper

    private func fetchWithCache<T: Codable & Sendable>(key: String, endpoint: APIEndpoint) async throws -> T {
        do {
            let result: T = try await apiClient.request(endpoint)
            memoryCache[key] = result
            return result
        } catch let error as APIError {
            if case .offline = error, let cached = memoryCache[key] as? T {
                return cached
            }
            throw error
        } catch {
            if let cached = memoryCache[key] as? T {
                return cached
            }
            throw error
        }
    }

    public func clearCache() {
        memoryCache.removeAll()
    }
}
