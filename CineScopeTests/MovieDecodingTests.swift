//
//  MovieDecodingTests.swift
//  CineScopeTests
//

import Testing
import Foundation
@testable import CineScope

struct MovieDecodingTests {

    @Test func testMovieDecoding() throws {
        let data = MockData.sampleMovieJSON.data(using: .utf8)!
        let movie = try JSONDecoder().decode(Movie.self, from: data)

        #expect(movie.id == 550)
        #expect(movie.title == "Fight Club")
        #expect(movie.formattedYear == "1999")
        #expect(movie.formattedRating == "8.4")
        #expect(movie.genreNames.contains("Drama"))
        #expect(movie.genreNames.contains("Thriller"))
        #expect(movie.posterURL()?.absoluteString == "https://image.tmdb.org/t/p/w500/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg")
    }

    @Test func testPageResultDecoding() throws {
        let data = MockData.samplePageResultJSON.data(using: .utf8)!
        let pageResult = try JSONDecoder().decode(PageResult<Movie>.self, from: data)

        #expect(pageResult.page == 1)
        #expect(pageResult.totalPages == 5)
        #expect(pageResult.totalResults == 10)
        #expect(pageResult.results.count == 2)
        #expect(pageResult.hasMorePages == true)
        #expect(pageResult.results[0].title == "Fight Club")
        #expect(pageResult.results[1].title == "Pulp Fiction")
    }

    @Test func testMovieDetailDecoding() throws {
        let data = MockData.sampleDetailJSON.data(using: .utf8)!
        let detail = try JSONDecoder().decode(MovieDetail.self, from: data)

        #expect(detail.id == 550)
        #expect(detail.title == "Fight Club")
        #expect(detail.formattedRuntime == "2h 19m")
        #expect(detail.formattedBudget.isEmpty == false)
        #expect(detail.formattedRevenue.isEmpty == false)
        #expect(detail.director?.name == "David Fincher")
        #expect(detail.credits?.cast.count == 2)
        #expect(detail.credits?.cast[0].name == "Edward Norton")
        #expect(detail.trailerVideo?.key == "O1bDmxUgkAM")
        #expect(detail.trailerURL?.absoluteString == "https://www.youtube.com/watch?v=O1bDmxUgkAM")
    }

    @Test func testTrailerPriority() {
        let teaser = Video(id: "1", key: "teaser123", name: "Teaser", site: "YouTube", type: "Teaser", official: false)
        let trailer = Video(id: "2", key: "trailer456", name: "Main Trailer", site: "YouTube", type: "Trailer", official: true)
        let vimeo = Video(id: "3", key: "vimeo789", name: "Clip", site: "Vimeo", type: "Clip")

        let response = VideoResponse(id: 100, results: [teaser, vimeo, trailer])
        #expect(response.primaryTrailer?.key == "trailer456")
    }
}
