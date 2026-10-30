//
//  AppRouterTests.swift
//  CineScopeTests
//

import Testing
import Foundation
@testable import CineScope

@MainActor
struct AppRouterTests {

    @Test func testMovieDeepLinkSelectsDiscoverAndPushesMovie() {
        let router = AppRouter()

        let handled = router.handle(URL(string: "cinescope://movie/550")!)

        #expect(handled)
        #expect(router.selectedTab == .discover)
        #expect(router.discoverPath == [.movie(id: 550, movie: nil)])
    }

    @Test func testCollectionDeepLinkMapsSlugToCollectionType() {
        let router = AppRouter()

        let handled = router.handle(URL(string: "cinescope://collection/top-rated")!)

        #expect(handled)
        #expect(router.discoverPath == [.collection(.topRated)])
    }

    @Test func testUniversalLinkIsSupported() {
        let router = AppRouter()

        let handled = router.handle(URL(string: "https://cinescope.app/movie/680")!)

        #expect(handled)
        #expect(router.discoverPath == [.movie(id: 680, movie: nil)])
    }

    @Test func testSearchDeepLinkSetsPendingQuery() {
        let router = AppRouter()

        let handled = router.handle(URL(string: "cinescope://search?q=matrix")!)

        #expect(handled)
        #expect(router.selectedTab == .search)
        #expect(router.searchPath.isEmpty)
        #expect(router.pendingSearchQuery == "matrix")
    }

    @Test func testTabDeepLinks() {
        let router = AppRouter()

        #expect(router.handle(URL(string: "cinescope://watchlist")!))
        #expect(router.selectedTab == .watchlist)

        #expect(router.handle(URL(string: "cinescope://library")!))
        #expect(router.selectedTab == .library)

        #expect(router.handle(URL(string: "cinescope://settings")!))
        #expect(router.selectedTab == .settings)
    }

    @Test func testUnsupportedURLsAreRejected() {
        let router = AppRouter()

        #expect(!router.handle(URL(string: "https://example.com/movie/550")!))
        #expect(!router.handle(URL(string: "cinescope://unknown/123")!))
        #expect(!router.handle(URL(string: "cinescope://collection/not-a-collection")!))
        #expect(router.discoverPath.isEmpty)
    }

    @Test func testPushUsesSelectedTabAndPopToRootResetsIt() {
        let router = AppRouter()
        router.selectedTab = .watchlist

        router.push(.movie(id: 550, movie: nil))
        #expect(router.watchlistPath.count == 1)

        router.popToRoot()
        #expect(router.watchlistPath.isEmpty)
        #expect(router.discoverPath.isEmpty)
    }
}
