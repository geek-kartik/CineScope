//
//  APIEndpointTests.swift
//  CineScopeTests
//

import Testing
import Foundation
@testable import CineScope

struct APIEndpointTests {

    @Test func testEndpointPaths() {
        #expect(APIEndpoint.trending(timeWindow: "day").path == "/trending/movie/day")
        #expect(APIEndpoint.popular(page: 1).path == "/movie/popular")
        #expect(APIEndpoint.nowPlaying(page: 1).path == "/movie/now_playing")
        #expect(APIEndpoint.upcoming(page: 1).path == "/movie/upcoming")
        #expect(APIEndpoint.topRated(page: 1).path == "/movie/top_rated")
        #expect(APIEndpoint.movieDetails(id: 42).path == "/movie/42")
        #expect(APIEndpoint.search(query: "Inception").path == "/search/movie")
        #expect(APIEndpoint.discoverByGenre(genreId: 28).path == "/discover/movie")
    }

    @Test func testAPIKeyQueryParamInjection() throws {
        let endpoint = APIEndpoint.popular(page: 2)
        let request = try endpoint.urlRequest(credential: "abcdef1234567890abcdef1234567890")

        let urlString = request.url?.absoluteString ?? ""
        #expect(urlString.contains("api_key=abcdef1234567890abcdef1234567890"))
        #expect(urlString.contains("page=2"))
        #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test func testBearerTokenHeaderInjection() throws {
        let jwtToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJmYWtlX3Rva2VuX3Rlc3QifQ.abcdef123456789"
        let endpoint = APIEndpoint.movieDetails(id: 550)
        let request = try endpoint.urlRequest(credential: jwtToken)

        let urlString = request.url?.absoluteString ?? ""
        #expect(!urlString.contains("api_key="))
        #expect(urlString.contains("append_to_response=credits%2Cvideos%2Crecommendations%2Csimilar") || urlString.contains("append_to_response=credits,videos,recommendations,similar"))
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer \(jwtToken)")
    }

    @Test func testSearchEndpointQueryItems() throws {
        let endpoint = APIEndpoint.search(query: "The Matrix", page: 3)
        let request = try endpoint.urlRequest(credential: "dummy_key")

        let urlString = request.url?.absoluteString ?? ""
        #expect(urlString.contains("query=The%20Matrix") || urlString.contains("query=The+Matrix"))
        #expect(urlString.contains("page=3"))
        #expect(urlString.contains("include_adult=false"))
    }
}
