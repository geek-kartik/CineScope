//
//  MovieCacheStoreTests.swift
//  CineScopeTests
//

import Foundation
import Testing
@testable import CineScope

struct MovieCacheStoreTests {

    private func makeDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("CineScopeCacheTests-\(UUID().uuidString)", isDirectory: true)
    }

    private func cleanUp(_ directory: URL) {
        try? FileManager.default.removeItem(at: directory)
    }

    @Test func storesEntryWithTTLMetadata() async {
        let directory = makeDirectory()
        defer { cleanUp(directory) }

        let store = MovieCacheStore(directory: directory)
        let now = Date(timeIntervalSince1970: 1_000)
        let payload = Data("payload".utf8)

        await store.store(data: payload, for: "trending_day_1", ttl: 60, now: now)

        let entry = await store.entry(for: "trending_day_1")
        #expect(entry?.data == payload)
        #expect(entry?.isFresh(at: now.addingTimeInterval(59)) == true)
        #expect(entry?.isFresh(at: now.addingTimeInterval(61)) == false)
    }

    @Test func persistsEntriesAcrossInstances() async {
        let directory = makeDirectory()
        defer { cleanUp(directory) }

        let payload = Data("persisted".utf8)
        let firstStore = MovieCacheStore(directory: directory)
        await firstStore.store(data: payload, for: "details_550", ttl: 60)

        let secondStore = MovieCacheStore(directory: directory)
        let entry = await secondStore.entry(for: "details_550")

        #expect(entry?.data == payload)
    }

    @Test func removeAllClearsMemoryAndDisk() async {
        let directory = makeDirectory()
        defer { cleanUp(directory) }

        let store = MovieCacheStore(directory: directory)
        await store.store(data: Data("value".utf8), for: "key", ttl: 60)
        await store.removeAll()

        let entry = await store.entry(for: "key")
        let bytes = await store.diskUsageBytes()

        #expect(entry == nil)
        #expect(bytes == 0)
    }

    @Test func evictsOldestEntriesWhenOverCountLimit() async {
        let directory = makeDirectory()
        defer { cleanUp(directory) }

        let store = MovieCacheStore(directory: directory, maxEntries: 2)
        let base = Date(timeIntervalSince1970: 1_000)

        for index in 0..<3 {
            await store.store(
                data: Data("value-\(index)".utf8),
                for: "key-\(index)",
                ttl: 60,
                now: base.addingTimeInterval(Double(index))
            )
        }

        let evicted = await store.entry(for: "key-0")
        let second = await store.entry(for: "key-1")
        let third = await store.entry(for: "key-2")

        #expect(evicted == nil)
        #expect(second != nil)
        #expect(third != nil)
    }

    @Test func prunesEntriesOlderThanRetentionWindow() async {
        let directory = makeDirectory()
        defer { cleanUp(directory) }

        let store = MovieCacheStore(directory: directory, maxAge: 10)
        let base = Date(timeIntervalSince1970: 1_000)

        await store.store(data: Data("old".utf8), for: "old", ttl: 60, now: base)
        await store.prune(now: base.addingTimeInterval(11))

        let entry = await store.entry(for: "old")
        #expect(entry == nil)
    }
}
