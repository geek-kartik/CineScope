//
//  PaginationTests.swift
//  CineScopeTests
//

import Testing
import Foundation
import SwiftData
@testable import CineScope

@MainActor
struct PaginationTests {

    private let movieOne = Movie(id: 1, title: "One", overview: "")
    private let movieTwo = Movie(id: 2, title: "Two", overview: "")
    private let movieThree = Movie(id: 3, title: "Three", overview: "")

    @Test func testCollectionPaginationPrefetchesAndDeduplicates() async {
        let repository = PagedMovieRepository(
            pageOne: PageResult(page: 1, results: [movieOne, movieTwo], totalPages: 2, totalResults: 3),
            pageTwo: PageResult(page: 2, results: [movieTwo, movieThree], totalPages: 2, totalResults: 3)
        )
        let viewModel = MovieCollectionViewModel(
            collectionType: .popular,
            repository: repository,
            prefetchThreshold: 1
        )

        await viewModel.loadInitialIfNeeded()

        #expect(viewModel.movies.map(\.id) == [1, 2])
        #expect(viewModel.hasMorePages)
        #expect(!viewModel.shouldPrefetch(at: 0))
        #expect(viewModel.shouldPrefetch(at: 1))

        await viewModel.loadMoreIfNeeded(at: 0)
        #expect(viewModel.movies.map(\.id) == [1, 2])

        await viewModel.loadMoreIfNeeded(at: 1)
        #expect(viewModel.movies.map(\.id) == [1, 2, 3])
        #expect(!viewModel.hasMorePages)

        await viewModel.loadMoreIfNeeded(at: 2)
        let collectionRequests = await repository.popularRequests
        #expect(collectionRequests == [1, 2])
    }

    @Test func testHomeSectionLoadMoreDeduplicates() async {
        let (userRepository, container) = createTestUserRepository()
        let config = APIConfig.shared
        config.setCredential("valid_mock_token_key_1234567890")

        let repository = PagedMovieRepository(
            pageOne: PageResult(page: 1, results: [movieOne, movieTwo], totalPages: 2, totalResults: 3),
            pageTwo: PageResult(page: 2, results: [movieTwo, movieThree], totalPages: 2, totalResults: 3)
        )
        let viewModel = HomeViewModel(
            movieRepository: repository,
            userMovieRepository: userRepository,
            apiConfig: config
        )

        await viewModel.loadFeed()
        #expect(viewModel.popularMovies.map(\.id) == [1, 2])
        #expect(viewModel.shouldLoadMore(section: .popular, movie: movieTwo))

        await viewModel.loadMore(section: .popular)

        #expect(viewModel.popularMovies.map(\.id) == [1, 2, 3])
        #expect(!viewModel.shouldLoadMore(section: .popular, movie: movieThree))
        let homeRequests = await repository.popularRequests
        #expect(homeRequests == [1, 2])
        _ = container
    }

    private func createTestUserRepository() -> (UserMovieRepository, ModelContainer) {
        let schema = Schema([SavedMovieItem.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let repository = UserMovieRepository(context: container.mainContext, container: container)
        return (repository, container)
    }
}

private actor PagedMovieRepository: MovieRepositoryProtocol {
    private let pageOne: PageResult<Movie>
    private let pageTwo: PageResult<Movie>
    private(set) var popularRequests: [Int] = []

    init(pageOne: PageResult<Movie>, pageTwo: PageResult<Movie>) {
        self.pageOne = pageOne
        self.pageTwo = pageTwo
    }

    func getTrending(timeWindow: String, page: Int) async throws -> PageResult<Movie> {
        pageResult(for: page)
    }

    func getPopular(page: Int) async throws -> PageResult<Movie> {
        popularRequests.append(page)
        return pageResult(for: page)
    }

    func getNowPlaying(page: Int) async throws -> PageResult<Movie> {
        pageResult(for: page)
    }

    func getUpcoming(page: Int) async throws -> PageResult<Movie> {
        pageResult(for: page)
    }

    func getTopRated(page: Int) async throws -> PageResult<Movie> {
        pageResult(for: page)
    }

    func getMovieDetails(id: Int) async throws -> MovieDetail {
        throw APIError.notFound
    }

    func searchMovies(query: String, page: Int) async throws -> PageResult<Movie> {
        pageResult(for: page)
    }

    func getMoviesByGenre(genreId: Int, page: Int) async throws -> PageResult<Movie> {
        pageResult(for: page)
    }

    private func pageResult(for page: Int) -> PageResult<Movie> {
        page == 1 ? pageOne : pageTwo
    }
}
