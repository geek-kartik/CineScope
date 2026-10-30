//
//  MovieRepositoryCacheTests.swift
//  CineScopeTests
//

import Foundation
import Testing
@testable import CineScope

struct MovieRepositoryCacheTests {

    private func makeCache() -> (MovieCacheStore, URL) {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("CineScopeRepositoryCacheTests-\(UUID().uuidString)", isDirectory: true)
        return (MovieCacheStore(directory: directory), directory)
    }

    private func cleanUp(_ directory: URL) {
        try? FileManager.default.removeItem(at: directory)
    }

    @Test func freshCacheAvoidsDuplicateNetworkRequests() async throws {
        let (cache, directory) = makeCache()
        defer { cleanUp(directory) }

        let mockClient = MockAPIClient()
        let repository = MovieRepository(apiClient: mockClient, cache: cache)

        _ = try await repository.getPopular(page: 1)
        #expect(mockClient.requestCount == 1)

        _ = try await repository.getPopular(page: 1)
        #expect(mockClient.requestCount == 1)
    }

    @Test func staleCacheIsServedWhenNetworkFails() async throws {
        let (cache, directory) = makeCache()
        defer { cleanUp(directory) }

        let stalePage = PageResult(
            page: 1,
            results: [MockData.sampleMovie],
            totalPages: 5,
            totalResults: 10
        )
        let staleData = try JSONEncoder().encode(stalePage)
        await cache.store(data: staleData, for: "popular_1", ttl: -1)

        let mockClient = MockAPIClient()
        mockClient.shouldThrowError = .offline
        let repository = MovieRepository(apiClient: mockClient, cache: cache)

        let result = try await repository.getPopular(page: 1)

        #expect(result.results.first?.id == MockData.sampleMovie.id)
        #expect(mockClient.requestCount == 1)
    }

    @Test func cancellationIsNotMaskedByStaleCache() async throws {
        let (cache, directory) = makeCache()
        defer { cleanUp(directory) }

        let cachedPage = PageResult(page: 1, results: [MockData.sampleMovie], totalPages: 1, totalResults: 1)
        let cachedData = try JSONEncoder().encode(cachedPage)
        await cache.store(data: cachedData, for: "popular_1", ttl: -1)

        let mockClient = MockAPIClient()
        mockClient.shouldThrowError = .cancelled
        let repository = MovieRepository(apiClient: mockClient, cache: cache)

        await #expect(throws: APIError.cancelled) {
            _ = try await repository.getPopular(page: 1)
        }
    }

    @Test func clearCacheRemovesFreshEntries() async throws {
        let (cache, directory) = makeCache()
        defer { cleanUp(directory) }

        let mockClient = MockAPIClient()
        let repository = MovieRepository(apiClient: mockClient, cache: cache)

        _ = try await repository.getTopRated(page: 1)
        await repository.clearCache()

        _ = try await repository.getTopRated(page: 1)
        #expect(mockClient.requestCount == 2)
    }
}
