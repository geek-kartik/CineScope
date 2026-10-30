//
//  MovieRepository.swift
//  CineScope
//

import Foundation

public actor MovieRepository: MovieRepositoryProtocol {
    public static let shared = MovieRepository()

    private enum CacheTTL {
        static let trending: TimeInterval = 10 * 60
        static let list: TimeInterval = 30 * 60
        static let details: TimeInterval = 12 * 60 * 60
        static let search: TimeInterval = 2 * 60
    }

    private let apiClient: APIClientProtocol
    private let cache: MovieCacheStore
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(
        apiClient: APIClientProtocol = URLSessionAPIClient.shared,
        cache: MovieCacheStore = .shared
    ) {
        self.apiClient = apiClient
        self.cache = cache
    }

    public func getTrending(timeWindow: String = "day", page: Int = 1) async throws -> PageResult<Movie> {
        let endpoint = APIEndpoint.trending(timeWindow: timeWindow, page: page)
        return try await fetchWithCache(
            key: "trending_\(timeWindow)_\(page)",
            endpoint: endpoint,
            ttl: CacheTTL.trending
        )
    }

    public func getPopular(page: Int = 1) async throws -> PageResult<Movie> {
        let endpoint = APIEndpoint.popular(page: page)
        return try await fetchWithCache(
            key: "popular_\(page)",
            endpoint: endpoint,
            ttl: CacheTTL.list
        )
    }

    public func getNowPlaying(page: Int = 1) async throws -> PageResult<Movie> {
        let endpoint = APIEndpoint.nowPlaying(page: page)
        return try await fetchWithCache(
            key: "now_playing_\(page)",
            endpoint: endpoint,
            ttl: CacheTTL.list
        )
    }

    public func getUpcoming(page: Int = 1) async throws -> PageResult<Movie> {
        let endpoint = APIEndpoint.upcoming(page: page)
        return try await fetchWithCache(
            key: "upcoming_\(page)",
            endpoint: endpoint,
            ttl: CacheTTL.list
        )
    }

    public func getTopRated(page: Int = 1) async throws -> PageResult<Movie> {
        let endpoint = APIEndpoint.topRated(page: page)
        return try await fetchWithCache(
            key: "top_rated_\(page)",
            endpoint: endpoint,
            ttl: CacheTTL.list
        )
    }

    public func getMovieDetails(id: Int) async throws -> MovieDetail {
        let endpoint = APIEndpoint.movieDetails(id: id)
        return try await fetchWithCache(
            key: "details_\(id)",
            endpoint: endpoint,
            ttl: CacheTTL.details
        )
    }

    public func searchMovies(query: String, page: Int = 1) async throws -> PageResult<Movie> {
        let endpoint = APIEndpoint.search(query: query, page: page)
        let normalizedQuery = query
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return try await fetchWithCache(
            key: "search_\(normalizedQuery)_\(page)",
            endpoint: endpoint,
            ttl: CacheTTL.search
        )
    }

    public func getMoviesByGenre(genreId: Int, page: Int = 1) async throws -> PageResult<Movie> {
        let endpoint = APIEndpoint.discoverByGenre(genreId: genreId, page: page)
        return try await fetchWithCache(
            key: "genre_\(genreId)_\(page)",
            endpoint: endpoint,
            ttl: CacheTTL.list
        )
    }

    // MARK: - Caching Helper

    /// Returns a fresh cached value immediately. On a miss (or stale entry) it
    /// fetches from the network and updates the cache. If the request fails and
    /// a stale entry exists, the stale value is returned so the app keeps
    /// working offline. Cancellation is never masked by stale data.
    private func fetchWithCache<T: Codable & Sendable>(
        key: String,
        endpoint: APIEndpoint,
        ttl: TimeInterval
    ) async throws -> T {
        let cachedEntry = await cache.entry(for: key)

        if let cachedEntry, cachedEntry.isFresh(),
           let cachedValue = try? decoder.decode(T.self, from: cachedEntry.data) {
            return cachedValue
        }

        do {
            let result: T = try await apiClient.request(endpoint)
            if let data = try? encoder.encode(result) {
                await cache.store(data: data, for: key, ttl: ttl)
            }
            return result
        } catch APIError.cancelled {
            throw APIError.cancelled
        } catch {
            if let cachedEntry,
               let staleValue = try? decoder.decode(T.self, from: cachedEntry.data) {
                return staleValue
            }
            throw error
        }
    }

    public func clearCache() async {
        await cache.removeAll()
    }

    public func cacheDiskUsageBytes() async -> Int {
        await cache.diskUsageBytes()
    }
}
