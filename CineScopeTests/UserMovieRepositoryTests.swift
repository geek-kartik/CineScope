//
//  UserMovieRepositoryTests.swift
//  CineScopeTests
//

import Testing
import Foundation
import SwiftData
@testable import CineScope

@MainActor
struct UserMovieRepositoryTests {

    private func createTestRepository() -> (UserMovieRepository, ModelContainer) {
        let schema = Schema([SavedMovieItem.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        let context = container.mainContext
        let repo = UserMovieRepository(context: context, container: container)
        return (repo, container)
    }

    @Test func testWatchlistAddAndRemove() {
        let (repo, _container) = createTestRepository()
        let movie = MockData.sampleMovie

        // Initially empty
        #expect(repo.fetchWatchlist().isEmpty)
        #expect(repo.status(for: movie.id).isInWatchlist == false)

        // Add to watchlist
        let added = repo.toggleWatchlist(movie: movie)
        #expect(added == true)
        #expect(repo.fetchWatchlist().count == 1)
        #expect(repo.status(for: movie.id).isInWatchlist == true)

        // Toggle again (remove from watchlist)
        let removed = repo.toggleWatchlist(movie: movie)
        #expect(removed == false)
        #expect(repo.fetchWatchlist().isEmpty)
        #expect(repo.status(for: movie.id).isInWatchlist == false)
        _ = _container
    }

    @Test func testFavoriteAndWatchedIndependence() {
        let (repo, _container) = createTestRepository()
        let movie = MockData.sampleMovie

        // Mark as favorite
        repo.toggleFavorite(movie: movie)
        #expect(repo.status(for: movie.id).isFavorite == true)
        #expect(repo.status(for: movie.id).isInWatchlist == false)
        #expect(repo.status(for: movie.id).isWatched == false)

        // Mark as watched
        repo.toggleWatched(movie: movie)
        #expect(repo.status(for: movie.id).isWatched == true)
        #expect(repo.status(for: movie.id).isFavorite == true)

        let item = repo.getItem(id: movie.id)
        #expect(item?.dateWatched != nil)
        _ = _container
    }

    @Test func testPersonalReviewAndStatistics() {
        let (repo, _container) = createTestRepository()
        let movie1 = MockData.sampleMovie
        let movie2 = MockData.sampleMovie2

        // Save review for movie 1
        repo.toggleWatched(movie: movie1)
        repo.updateUserReview(movieId: movie1.id, rating: 5.0, review: "Masterpiece cinema!")

        // Save review for movie 2
        repo.toggleWatched(movie: movie2)
        repo.updateUserReview(movieId: movie2.id, rating: 4.0, review: "Classic dialogue.")

        let status1 = repo.status(for: movie1.id)
        #expect(status1.userRating == 5.0)
        #expect(status1.userReview == "Masterpiece cinema!")

        // Check library statistics
        let stats = repo.libraryStatistics()
        #expect(stats.totalWatched == 2)
        #expect(stats.averageRating == 4.5)
        #expect(stats.totalRuntimeMinutes > 0)
        _ = _container
    }

    @Test func testClearAllData() {
        let (repo, _container) = createTestRepository()
        repo.toggleWatchlist(movie: MockData.sampleMovie)
        repo.toggleFavorite(movie: MockData.sampleMovie2)

        #expect(!repo.fetchWatchlist().isEmpty)
        #expect(!repo.fetchFavorites().isEmpty)

        repo.clearAllData()
        #expect(repo.fetchWatchlist().isEmpty)
        #expect(repo.fetchFavorites().isEmpty)
        #expect(repo.fetchWatched().isEmpty)
        _ = _container
    }
}
