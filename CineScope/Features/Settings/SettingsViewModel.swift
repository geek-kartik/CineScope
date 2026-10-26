//
//  SettingsViewModel.swift
//  CineScope
//

import Foundation
import Observation

@Observable
@MainActor
public final class SettingsViewModel {
    public var hasCredentials: Bool = false
    public var cacheSize: String = "0 MB"
    public var showClearDataAlert: Bool = false
    public var cacheClearedFeedback: Bool = false

    private let userMovieRepository: UserMovieRepositoryProtocol
    private let apiConfig: APIConfig

    public init(
        userMovieRepository: UserMovieRepositoryProtocol,
        apiConfig: APIConfig = .shared
    ) {
        self.userMovieRepository = userMovieRepository
        self.apiConfig = apiConfig
        refreshState()
    }

    public func refreshState() {
        hasCredentials = apiConfig.hasCredentials
        cacheSize = ImageLoader.shared.currentCacheDiskUsage()
    }

    public func clearImageCache() {
        ImageLoader.shared.clearCache()
        Task {
            await MovieRepository.shared.clearCache()
        }
        cacheSize = "0.0 MB"
        cacheClearedFeedback = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            cacheClearedFeedback = false
        }
    }

    public func removeCredentials() {
        apiConfig.clearCredential()
        refreshState()
    }

    public func clearAllUserData() {
        userMovieRepository.clearAllData()
        refreshState()
    }
}
