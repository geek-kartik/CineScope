//
//  Video.swift
//  CineScope
//

import Foundation

nonisolated public struct Video: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let key: String
    public let name: String
    public let site: String
    public let type: String
    public let official: Bool?
    public let publishedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case key
        case name
        case site
        case type
        case official
        case publishedAt = "published_at"
    }

    public init(
        id: String,
        key: String,
        name: String,
        site: String,
        type: String,
        official: Bool? = nil,
        publishedAt: String? = nil
    ) {
        self.id = id
        self.key = key
        self.name = name
        self.site = site
        self.type = type
        self.official = official
        self.publishedAt = publishedAt
    }

    public var isYouTubeTrailer: Bool {
        site.caseInsensitiveCompare("YouTube") == .orderedSame &&
        (type.caseInsensitiveCompare("Trailer") == .orderedSame || type.caseInsensitiveCompare("Teaser") == .orderedSame)
    }

    public var youTubeURL: URL? {
        guard site.caseInsensitiveCompare("YouTube") == .orderedSame else { return nil }
        return URL(string: "https://www.youtube.com/watch?v=\(key)")
    }

    public var youTubeThumbnailURL: URL? {
        guard site.caseInsensitiveCompare("YouTube") == .orderedSame else { return nil }
        return URL(string: "https://img.youtube.com/vi/\(key)/hqdefault.jpg")
    }
}

nonisolated public struct VideoResponse: Codable, Sendable {
    public let id: Int?
    public let results: [Video]

    public init(id: Int? = nil, results: [Video] = []) {
        self.id = id
        self.results = results
    }

    public var primaryTrailer: Video? {
        results.first { $0.isYouTubeTrailer && ($0.official == true) && $0.type.caseInsensitiveCompare("Trailer") == .orderedSame }
        ?? results.first { $0.isYouTubeTrailer && $0.type.caseInsensitiveCompare("Trailer") == .orderedSame }
        ?? results.first { $0.isYouTubeTrailer }
        ?? results.first { $0.site.caseInsensitiveCompare("YouTube") == .orderedSame }
    }
}
