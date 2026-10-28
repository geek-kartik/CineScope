//
//  ModelTests.swift
//  CineScopeTests
//

import Testing
import Foundation
@testable import CineScope

struct ModelTests {

    @Test func testUserMovieStatusDefaults() {
        let status = UserMovieStatus.empty
        #expect(status.isInWatchlist == false)
        #expect(status.isFavorite == false)
        #expect(status.isWatched == false)
        #expect(status.userRating == nil)
        #expect(status.userReview == nil)
    }

    @Test func testGenreDecoding() throws {
        let json = """
        {"id": 18, "name": "Drama"}
        """
        let data = json.data(using: .utf8)!
        let genre = try JSONDecoder().decode(Genre.self, from: data)
        #expect(genre.id == 18)
        #expect(genre.name == "Drama")
    }

    @Test func testCreditsDecoding() throws {
        let json = """
        {
          "id": 550,
          "cast": [{"id": 1, "name": "Edward Norton", "character": "The Narrator", "order": 0, "profile_path": null}],
          "crew": [{"id": 7467, "name": "David Fincher", "job": "Director", "department": "Directing", "profile_path": null}]
        }
        """
        let data = json.data(using: .utf8)!
        let credits = try JSONDecoder().decode(Credits.self, from: data)
        #expect(credits.director?.name == "David Fincher")
        #expect(credits.cast.count == 1)
        #expect(credits.cast[0].character == "The Narrator")
    }

    @Test func testLibraryStatsDefaults() {
        let stats = LibraryStats()
        #expect(stats.totalWatched == 0)
        #expect(stats.totalRuntimeMinutes == 0)
        #expect(stats.averageRating == nil)
        #expect(stats.topGenres.isEmpty)
    }
}
