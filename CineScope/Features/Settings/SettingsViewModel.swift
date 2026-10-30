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
    }

    public func refreshState() async {
        hasCredentials = apiConfig.hasCredentials

        let imageBytes = await ImageLoader.shared.currentDiskUsageBytes()
        let responseBytes = await MovieRepository.shared.cacheDiskUsageBytes()
        cacheSize = Self.formattedSize(bytes: imageBytes + responseBytes)
    }

    public func clearImageCache() async {
        await ImageLoader.shared.clearCache()
        await MovieRepository.shared.clearCache()
        cacheSize = "0.0 MB"
        cacheClearedFeedback = true
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            self?.cacheClearedFeedback = false
        }
    }

    public func removeCredentials() {
        apiConfig.clearCredential()
        hasCredentials = apiConfig.hasCredentials
    }

    public func clearAllUserData() {
        userMovieRepository.clearAllData()
    }

    private static func formattedSize(bytes: Int) -> String {
        let mb = Double(bytes) / (1024 * 1024)
        return String(format: "%.1f MB", mb)
    }
}
