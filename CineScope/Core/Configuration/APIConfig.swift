//
//  APIConfig.swift
//  CineScope
//

import Foundation

public final class APIConfig: @unchecked Sendable {
    public static let shared = APIConfig()

    public static let baseURLString = "https://api.themoviedb.org/3"
    public static let imageBaseURLString = "https://image.tmdb.org/t/p"

    private let userDefaultsKey = "cinescope_tmdb_api_key_or_token"
    private let lock = NSLock()

    private init() {}

    public var apiKeyOrToken: String? {
        lock.lock()
        defer { lock.unlock() }

        // 1. Check user-configured key in UserDefaults
        if let stored = UserDefaults.standard.string(forKey: userDefaultsKey),
           !stored.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return stored.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // 2. Check Process Environment
        if let envKey = ProcessInfo.processInfo.environment["TMDB_API_KEY"],
           !envKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return envKey.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let envToken = ProcessInfo.processInfo.environment["TMDB_ACCESS_TOKEN"],
           !envToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return envToken.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // 3. Check local bundled TMDBConfig.json if present
        if let url = Bundle.main.url(forResource: "TMDBConfig", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let key = json["apiKey"] as? String, !key.isEmpty, !key.contains("YOUR_") {
                return key
            }
            if let token = json["accessToken"] as? String, !token.isEmpty, !token.contains("YOUR_") {
                return token
            }
        }

        // 4. Check Info.plist
        if let infoKey = Bundle.main.object(forInfoDictionaryKey: "TMDB_API_KEY") as? String,
           !infoKey.isEmpty, !infoKey.contains("YOUR_") {
            return infoKey
        }

        return nil
    }

    public var hasCredentials: Bool {
        guard let key = apiKeyOrToken else { return false }
        return !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public var isBearerToken: Bool {
        guard let key = apiKeyOrToken else { return false }
        // TMDB v4 Read Access Tokens are long JWTs starting with eyJ
        return key.count > 40 || key.hasPrefix("eyJ")
    }

    public func setCredential(_ value: String) {
        lock.lock()
        defer { lock.unlock() }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        } else {
            UserDefaults.standard.set(trimmed, forKey: userDefaultsKey)
        }
        NotificationCenter.default.post(name: .apiConfigDidChange, object: nil)
    }

    public func clearCredential() {
        setCredential("")
    }
}

public extension Notification.Name {
    static let apiConfigDidChange = Notification.Name("cinescope_apiConfigDidChange")
}
