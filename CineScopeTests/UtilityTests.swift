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
        let counter = Counter()

        debouncer.debounce {
            await counter.increment()
        }
        try await Task.sleep(nanoseconds: 40_000_000)

        let earlyCount = await counter.value
        #expect(earlyCount == 0)

        try await waitForCount(counter, expected: 1)
        let finalCount = await counter.value
        #expect(finalCount == 1)
    }

    @Test func testDebouncerCancelsPreviousCalls() async throws {
        let debouncer = Debouncer(delay: 0.1)
        let counter = Counter()

        debouncer.debounce {
            await counter.increment()
        }
        try await Task.sleep(nanoseconds: 40_000_000)
        debouncer.debounce {
            await counter.increment()
        }

        try await waitForCount(counter, expected: 1)

        // Wait past the original deadline to confirm the first call was cancelled.
        try await Task.sleep(nanoseconds: 250_000_000)
        let finalCount = await counter.value
        #expect(finalCount == 1)
    }

    private func waitForCount(
        _ counter: Counter,
        expected: Int,
        timeout: TimeInterval = 2
    ) async throws {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if await counter.value >= expected {
                return
            }
            try await Task.sleep(nanoseconds: 20_000_000)
        }
    }
}

private actor Counter {
    private(set) var value = 0

    func increment() {
        value += 1
    }
}
