//
//  CollectionType.swift
//  CineScope
//

import Foundation

public enum CollectionType: String, Identifiable, CaseIterable, Sendable {
    case trending = "Trending Today"
    case nowPlaying = "Now Playing"
    case topRated = "Top Rated All-Time"
    case popular = "Popular Worldwide"
    case upcoming = "Upcoming Releases"

    public var id: String { rawValue }

    public var deepLinkSlug: String {
        switch self {
        case .trending: return "trending"
        case .nowPlaying: return "now-playing"
        case .topRated: return "top-rated"
        case .popular: return "popular"
        case .upcoming: return "upcoming"
        }
    }

    public init?(deepLinkSlug: String) {
        guard let match = Self.allCases.first(where: {
            $0.deepLinkSlug.caseInsensitiveCompare(deepLinkSlug) == .orderedSame
        }) else {
            return nil
        }
        self = match
    }
}
