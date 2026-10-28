//
//  ViewModelTests.swift
//  CineScopeTests
//

import Testing
import Foundation
import SwiftData
@testable import CineScope

@MainActor
struct ViewModelTests {

    private func createTestUserRepo() -> (UserMovieRepository, ModelContainer) {
        let schema = Schema([SavedMovieItem.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let repo = UserMovieRepository(context: container.mainContext, container: container)
        return (repo, container)
    }

    @Test func testHomeViewModelMissingKey() async {
        let (userRepo, _container) = createTestUserRepo()
        let config = APIConfig.shared
        config.clearCredential()

        let homeVM = HomeViewModel(
            movieRepository: MovieRepository(apiClient: MockAPIClient()),
            userMovieRepository: userRepo,
            apiConfig: config
        )

        await homeVM.loadFeed()
        #expect(homeVM.isMissingCredentials == true)
        #expect(homeVM.trendingMovies.isEmpty)
        _ = _container
    }

    @Test func testHomeViewModelLoadsFeedWithKey() async {
        let (userRepo, _container) = createTestUserRepo()
        let config = APIConfig.shared
        config.setCredential("valid_mock_token_key_1234567890")

        let mockClient = MockAPIClient()
        let movieRepo = MovieRepository(apiClient: mockClient)

        let homeVM = HomeViewModel(
            movieRepository: movieRepo,
            userMovieRepository: userRepo,
            apiConfig: config
        )

        await homeVM.loadFeed()
        #expect(homeVM.isMissingCredentials == false)
        #expect(homeVM.trendingMovies.count == 2)
        #expect(homeVM.heroMovie?.title == "Fight Club")
        #expect(homeVM.nowPlayingMovies.count == 2)
        _ = _container
    }

    @Test func testSearchViewModelRecentSearches() {
        let mockClient = MockAPIClient()
        let movieRepo = MovieRepository(apiClient: mockClient)
        let searchVM = SearchViewModel(movieRepository: movieRepo)

        searchVM.clearAllRecentSearches()
        #expect(searchVM.recentSearches.isEmpty)

        searchVM.query = "Batman"
        searchVM.selectRecentSearch("Batman")
        #expect(searchVM.query == "Batman")
    }

    @Test func testMovieDetailsViewModelSync() async {
        let (userRepo, _container) = createTestUserRepo()
        let mockClient = MockAPIClient()
        let movieRepo = MovieRepository(apiClient: mockClient)

        let detailVM = MovieDetailsViewModel(
            movieId: 550,
            initialMovie: MockData.sampleMovie,
            movieRepository: movieRepo,
            userMovieRepository: userRepo
        )

        await detailVM.loadDetails()
        #expect(detailVM.movieDetail?.title == "Fight Club")
        #expect(detailVM.movieDetail?.director?.name == "David Fincher")
        #expect(detailVM.userStatus.isInWatchlist == false)

        detailVM.toggleWatchlist()
        #expect(detailVM.userStatus.isInWatchlist == true)

        detailVM.savePersonalReview(rating: 5.0, review: "Great flick!")
        #expect(detailVM.personalRating == 5.0)
        #expect(detailVM.personalReview == "Great flick!")
        _ = _container
    }

    @Test func testWatchlistSortingAndFiltering() {
        let (userRepo, _container) = createTestUserRepo()
        let movieA = Movie(id: 1, title: "Avatar", overview: "", releaseDate: "2009-12-18", voteAverage: 7.6)
        let movieZ = Movie(id: 2, title: "Zodiac", overview: "", releaseDate: "2007-03-02", voteAverage: 7.7)

        userRepo.toggleWatchlist(movie: movieZ)
        userRepo.toggleWatchlist(movie: movieA)

        let watchlistVM = WatchlistViewModel(repository: userRepo)
        #expect(watchlistVM.allItems.count == 2)

        // Sort by Title (A-Z)
        watchlistVM.sortOption = .title
        let sorted = watchlistVM.filteredAndSortedItems
        #expect(sorted.first?.title == "Avatar")
        #expect(sorted.last?.title == "Zodiac")

        // Filter unwatched
        watchlistVM.filterOption = .unwatched
        #expect(watchlistVM.filteredAndSortedItems.count == 2)

        // Mark one as watched
        if let first = sorted.first {
            watchlistVM.toggleWatched(first)
        }
        #expect(watchlistVM.filteredAndSortedItems.count == 1)
        _ = _container
    }

    @Test func testSettingsViewModelCacheAndDataReset() {
        let (userRepo, _container) = createTestUserRepo()
        userRepo.toggleWatchlist(movie: MockData.sampleMovie)
        #expect(!userRepo.fetchWatchlist().isEmpty)

        let settingsVM = SettingsViewModel(userMovieRepository: userRepo)
        settingsVM.clearImageCache()
        #expect(settingsVM.cacheSize == "0.0 MB")

        settingsVM.clearAllUserData()
        #expect(userRepo.fetchWatchlist().isEmpty)
        _ = _container
    }

    @Test func testLibraryViewModelSegmentsAndStats() {
        let (userRepo, _container) = createTestUserRepo()

        let movie1 = Movie(id: 10, title: "Inception", overview: "", releaseDate: "2010-07-16", voteAverage: 8.8)
        let movie2 = Movie(id: 11, title: "Interstellar", overview: "", releaseDate: "2014-11-07", voteAverage: 8.6)

        userRepo.toggleWatchlist(movie: movie1)
        userRepo.toggleWatchlist(movie: movie2)
        userRepo.toggleWatched(movie: movie1)
        userRepo.toggleFavorite(movie: movie2)
        userRepo.updateUserReview(movieId: movie1.id, rating: 4.5, review: "Mind bending")

        let libVM = LibraryViewModel(repository: userRepo)
        libVM.loadLibrary()

        #expect(libVM.watchedMovies.count == 1)
        #expect(libVM.favoriteMovies.count == 1)
        #expect(libVM.reviewedMovies.count == 1)
        #expect(libVM.stats.totalWatched == 1)

        libVM.selectedSegment = .favorites
        #expect(libVM.currentItems.count == 1)
        #expect(libVM.currentItems.first?.id == movie2.id)

        libVM.selectedSegment = .reviews
        #expect(libVM.currentItems.count == 1)
        #expect(libVM.currentItems.first?.id == movie1.id)

        libVM.selectedSegment = .watched
        libVM.removeMovie(libVM.watchedMovies.first!)
        #expect(libVM.watchedMovies.isEmpty)
        _ = _container
    }
}
