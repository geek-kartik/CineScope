//
//  ImageLoader.swift
//  CineScope
//

import UIKit

public final class ImageLoader: @unchecked Sendable {
    public static let shared = ImageLoader()

    private let memoryCache = NSCache<NSURL, UIImage>()
    private let session: URLSession

    private init() {
        memoryCache.countLimit = 200
        memoryCache.totalCostLimit = 100 * 1024 * 1024 // 100 MB

        let config = URLSessionConfiguration.default
        config.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 200 * 1024 * 1024,
            diskPath: "cinescope_images"
        )
        self.session = URLSession(configuration: config)
    }

    public func image(for url: URL) async -> UIImage? {
        let nsURL = url as NSURL

        // 1. Check memory cache
        if let cachedImage = memoryCache.object(forKey: nsURL) {
            return cachedImage
        }

        // 2. Fetch via URLSession (which checks URLCache disk cache)
        do {
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 20.0)
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let image = UIImage(data: data) else {
                return nil
            }

            memoryCache.setObject(image, forKey: nsURL, cost: data.count)
            return image
        } catch {
            return nil
        }
    }

    public func clearCache() {
        memoryCache.removeAllObjects()
        session.configuration.urlCache?.removeAllCachedResponses()
    }

    public func currentCacheDiskUsage() -> String {
        guard let urlCache = session.configuration.urlCache else { return "0 MB" }
        let bytes = urlCache.currentDiskUsage
        let mb = Double(bytes) / (1024 * 1024)
        return String(format: "%.1f MB", mb)
    }
}
