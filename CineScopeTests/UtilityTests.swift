//
//  UtilityTests.swift
//  CineScopeTests
//

import Testing
import Foundation
@testable import CineScope

struct UtilityTests {

    @Test func testDebouncerDelaysExecution() async throws {
        let debouncer = Debouncer(delay: 0.1)
        var counter = 0

        debouncer.debounce {
            counter += 1
        }
        try await Task.sleep(nanoseconds: 50_000_000)
        #expect(counter == 0)

        try await Task.sleep(nanoseconds: 200_000_000)
        #expect(counter == 1)
    }

    @Test func testDebouncerCancelsPreviousCalls() async throws {
        let debouncer = Debouncer(delay: 0.15)
        var counter = 0

        debouncer.debounce {
            counter += 1
        }
        try await Task.sleep(nanoseconds: 50_000_000)
        debouncer.debounce {
            counter += 1
        }
        try await Task.sleep(nanoseconds: 300_000_000)
        #expect(counter == 1)
    }
}
