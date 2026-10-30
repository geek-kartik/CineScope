//
//  SearchCancellationTests.swift
//  CineScopeTests
//

import Foundation
import Testing
import os
@testable import CineScope

@MainActor
struct SearchCancellationTests {

    @Test func cancellingSearchPreventsLateResultsFromBeingApplied() async throws {
        let repository = SlowSearchMovieRepository(delayNanoseconds: 5_000_000_000)
        let viewModel = SearchViewModel(movieRepository: repository)

        viewModel.query = "batman"
        viewModel.handleQueryChange()

        // Wait for the debounce interval plus a small buffer so the request is in flight.
        try await Task.sleep(nanoseconds: 500_000_000)
        #expect(repository.searchCallCount == 1)

        viewModel.cancelActiveSearch()
        try await Task.sleep(nanoseconds: 100_000_000)

        #expect(viewModel.searchResults.isEmpty)
        #expect(viewModel.isLoading == false)
    }
}

private final class SlowSearchMovieRepository: MovieRepositoryProtocol, @unchecked Sendable {
    private let delayNanoseconds: UInt64
    private let callCount = OSAllocatedUnfairLock(initialState: 0)

    init(delayNanoseconds: UInt64) {
        self.delayNanoseconds = delayNanoseconds
    }

    var searchCallCount: Int {
        callCount.withLock { $0 }
    }

    func getTrending(timeWindow: String, page: Int) async throws -> PageResult<Movie> {
        PageResult()
    }

    func getPopular(page: Int) async throws -> PageResult<Movie> {
        PageResult()
    }

    func getNowPlaying(page: Int) async throws -> PageResult<Movie> {
        PageResult()
    }

    func getUpcoming(page: Int) async throws -> PageResult<Movie> {
        PageResult()
    }

    func getTopRated(page: Int) async throws -> PageResult<Movie> {
        PageResult()
    }

    func getMovieDetails(id: Int) async throws -> MovieDetail {
        throw APIError.notFound
    }

    func searchMovies(query: String, page: Int) async throws -> PageResult<Movie> {
        callCount.withLock { $0 += 1 }

        try await Task.sleep(nanoseconds: delayNanoseconds)
        return PageResult(page: page, results: [MockData.sampleMovie], totalPages: 1, totalResults: 1)
    }

    func getMoviesByGenre(genreId: Int, page: Int) async throws -> PageResult<Movie> {
        PageResult()
    }
}
