//
//  AppRouter.swift
//  CineScope
//

import Foundation
import Observation

public enum AppTab: String, CaseIterable, Identifiable, Sendable {
    case discover
    case search
    case watchlist
    case library
    case settings

    public var id: String { rawValue }
}

public enum AppRoute: Hashable, Sendable {
    case movie(id: Int, movie: Movie?)
    case collection(CollectionType)
}

@Observable
@MainActor
public final class AppRouter {
    public var selectedTab: AppTab = .discover

    public var discoverPath: [AppRoute] = []
    public var searchPath: [AppRoute] = []
    public var watchlistPath: [AppRoute] = []
    public var libraryPath: [AppRoute] = []
    public var settingsPath: [AppRoute] = []

    public var pendingSearchQuery: String? = nil

    public init() {}

    public func path(for tab: AppTab) -> [AppRoute] {
        switch tab {
        case .discover: return discoverPath
        case .search: return searchPath
        case .watchlist: return watchlistPath
        case .library: return libraryPath
        case .settings: return settingsPath
        }
    }

    public func setPath(_ path: [AppRoute], for tab: AppTab) {
        switch tab {
        case .discover: discoverPath = path
        case .search: searchPath = path
        case .watchlist: watchlistPath = path
        case .library: libraryPath = path
        case .settings: settingsPath = path
        }
    }

    public func push(_ route: AppRoute, in tab: AppTab? = nil) {
        let target = tab ?? selectedTab
        setPath(path(for: target) + [route], for: target)
    }

    public func popToRoot(in tab: AppTab? = nil) {
        setPath([], for: tab ?? selectedTab)
    }

    public func openMovie(id: Int, movie: Movie? = nil) {
        selectedTab = .discover
        setPath([.movie(id: id, movie: movie)], for: .discover)
    }

    public func openCollection(_ type: CollectionType) {
        selectedTab = .discover
        setPath([.collection(type)], for: .discover)
    }

    @discardableResult
    public func handle(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased() else { return false }

        let isCustomScheme = scheme == "cinescope"
        let host = url.host?.lowercased()
        let isUniversalLink = scheme == "https" && (host == "cinescope.app" || host == "www.cinescope.app")

        guard isCustomScheme || isUniversalLink else { return false }

        var segments = url.pathComponents.filter { $0 != "/" }
        if isCustomScheme, let host, !host.isEmpty {
            segments.insert(host, at: 0)
        }
        guard let resource = segments.first?.lowercased() else { return false }

        switch resource {
        case "movie":
            guard segments.count > 1, let id = Int(segments[1]) else { return false }
            openMovie(id: id)
            return true

        case "collection":
            guard segments.count > 1, let type = CollectionType(deepLinkSlug: segments[1]) else {
                return false
            }
            openCollection(type)
            return true

        case "search":
            selectedTab = .search
            setPath([], for: .search)
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            pendingSearchQuery = components?.queryItems?.first(where: { $0.name == "q" })?.value
            return true

        case "watchlist":
            selectedTab = .watchlist
            return true

        case "library":
            selectedTab = .library
            return true

        case "settings":
            selectedTab = .settings
            return true

        default:
            return false
        }
    }
}
