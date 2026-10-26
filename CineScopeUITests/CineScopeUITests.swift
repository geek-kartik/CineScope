//
//  CineScopeUITests.swift
//  CineScopeUITests
//

import XCTest

final class CineScopeUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testAppLaunchAndTabNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify Tab bar exists
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5.0))

        // Verify tabs exist
        XCTAssertTrue(tabBar.buttons["Discover"].exists)
        XCTAssertTrue(tabBar.buttons["Search"].exists)
        XCTAssertTrue(tabBar.buttons["Watchlist"].exists)
        XCTAssertTrue(tabBar.buttons["Library"].exists)
        XCTAssertTrue(tabBar.buttons["Settings"].exists)

        // Navigate to Settings
        tabBar.buttons["Settings"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 3.0))

        // Navigate to Watchlist
        tabBar.buttons["Watchlist"].tap()
        XCTAssertTrue(app.navigationBars["Watchlist"].waitForExistence(timeout: 3.0))

        // Navigate back to Discover
        tabBar.buttons["Discover"].tap()
        XCTAssertTrue(app.navigationBars["CineScope"].waitForExistence(timeout: 3.0))
    }

    @MainActor
    func testSearchTabInteraction() throws {
        let app = XCUIApplication()
        app.launch()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5.0))

        // Tap Search
        tabBar.buttons["Search"].tap()
        XCTAssertTrue(app.navigationBars["Search"].waitForExistence(timeout: 3.0))

        // Tap Search text field
        let searchField = app.textFields.firstMatch
        if searchField.waitForExistence(timeout: 3.0) {
            searchField.tap()
            searchField.typeText("Matrix")
        }
    }
}
