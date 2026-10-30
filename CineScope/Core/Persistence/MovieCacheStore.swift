//
//  MovieCacheStore.swift
//  CineScope
//

import CryptoKit
import Foundation

/// Actor-isolated, disk-backed cache used for TMDB responses.
///
/// Entries are kept in memory for fast reads and mirrored to the caches
/// directory so the app can still render content after a cold launch with no
/// network connection. Each entry carries its own TTL, allowing hot feeds,
/// movie details, and search results to expire at different rates.
public actor MovieCacheStore {
    public struct Entry: Codable, Sendable, Equatable {
        public let data: Data
        public let storedAt: Date
        public let ttl: TimeInterval

        public init(data: Data, storedAt: Date, ttl: TimeInterval) {
            self.data = data
            self.storedAt = storedAt
            self.ttl = ttl
        }

        public var expiresAt: Date {
            storedAt.addingTimeInterval(ttl)
        }

        public func isFresh(at date: Date = Date()) -> Bool {
            date < expiresAt
        }
    }

    private struct DiskEntry: Codable {
        let key: String
        let entry: Entry
    }

    public static let shared = MovieCacheStore()

    private let directory: URL
    private let maxEntries: Int
    private let maxTotalBytes: Int
    private let maxAge: TimeInterval
    private let fileManager: FileManager
    private let encoder = JSONEncoder()

    private var memory: [String: Entry] = [:]

    public init(
        directory: URL? = nil,
        maxEntries: Int = 300,
        maxTotalBytes: Int = 64 * 1024 * 1024,
        maxAge: TimeInterval = 7 * 24 * 60 * 60,
        fileManager: FileManager = .default
    ) {
        let resolvedDirectory = directory ?? fileManager
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("CineScopeResponseCache", isDirectory: true)
            ?? fileManager.temporaryDirectory.appendingPathComponent("CineScopeResponseCache", isDirectory: true)

        self.directory = resolvedDirectory
        self.maxEntries = maxEntries
        self.maxTotalBytes = maxTotalBytes
        self.maxAge = maxAge
        self.fileManager = fileManager

        try? fileManager.createDirectory(at: resolvedDirectory, withIntermediateDirectories: true)
        self.memory = Self.loadEntriesFromDisk(directory: resolvedDirectory, fileManager: fileManager)
    }

    public func entry(for key: String) -> Entry? {
        memory[key]
    }

    public func store(data: Data, for key: String, ttl: TimeInterval, now: Date = Date()) {
        let entry = Entry(data: data, storedAt: now, ttl: ttl)
        memory[key] = entry
        writeToDisk(key: key, entry: entry)
        enforceLimits(now: now)
    }

    public func removeAll() {
        memory.removeAll()

        guard let files = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else {
            return
        }
        for file in files {
            try? fileManager.removeItem(at: file)
        }
    }

    public func prune(now: Date = Date()) {
        enforceLimits(now: now)
    }

    public func diskUsageBytes() -> Int {
        guard let files = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.fileSizeKey]
        ) else {
            return 0
        }

        return files.reduce(0) { total, file in
            let size = (try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            return total + size
        }
    }

    // MARK: - Disk

    private nonisolated static func loadEntriesFromDisk(
        directory: URL,
        fileManager: FileManager
    ) -> [String: Entry] {
        guard let files = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        ) else {
            return [:]
        }

        let decoder = JSONDecoder()
        var entries: [String: Entry] = [:]

        for file in files where file.pathExtension == "json" {
            guard let data = try? Data(contentsOf: file),
                  let diskEntry = try? decoder.decode(DiskEntry.self, from: data) else {
                try? fileManager.removeItem(at: file)
                continue
            }
            entries[diskEntry.key] = diskEntry.entry
        }

        return entries
    }

    private func writeToDisk(key: String, entry: Entry) {
        let diskEntry = DiskEntry(key: key, entry: entry)
        guard let data = try? encoder.encode(diskEntry) else { return }
        try? data.write(to: fileURL(for: key), options: .atomic)
    }

    private func removeEntry(forKey key: String) {
        memory.removeValue(forKey: key)
        try? fileManager.removeItem(at: fileURL(for: key))
    }

    private func fileURL(for key: String) -> URL {
        directory.appendingPathComponent("\(Self.fileName(for: key)).json")
    }

    // MARK: - Eviction

    private func enforceLimits(now: Date) {
        // Drop entries older than the maximum retention window first.
        let agedKeys = memory
            .filter { !isWithinMaxAge($0.value, now: now) }
            .map(\.key)
        for key in agedKeys {
            removeEntry(forKey: key)
        }

        // Then enforce the entry-count limit, oldest first.
        if memory.count > maxEntries {
            let overflow = memory
                .sorted { $0.value.storedAt < $1.value.storedAt }
                .prefix(memory.count - maxEntries)
            for (key, _) in overflow {
                removeEntry(forKey: key)
            }
        }

        // Finally enforce the size budget, oldest first.
        var totalBytes = diskUsageBytes()
        guard totalBytes > maxTotalBytes else { return }

        for (key, _) in memory.sorted(by: { $0.value.storedAt < $1.value.storedAt }) {
            guard totalBytes > maxTotalBytes else { break }
            let fileSize = (try? fileURL(for: key).resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            removeEntry(forKey: key)
            totalBytes -= fileSize
        }
    }

    private func isWithinMaxAge(_ entry: Entry, now: Date) -> Bool {
        now.timeIntervalSince(entry.storedAt) <= maxAge
    }

    private nonisolated static func fileName(for key: String) -> String {
        let digest = SHA256.hash(data: Data(key.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
