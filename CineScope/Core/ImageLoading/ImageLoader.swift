//
//  ImageLoader.swift
//  CineScope
//

import ImageIO
import UIKit

/// Actor-isolated image pipeline with memory caching and request coalescing.
///
/// Multiple views requesting the same poster share a single network task, and
/// decoded images are downsampled before being cached to reduce memory pressure.
public actor ImageLoader {
    public static let shared = ImageLoader()

    private static let maxPixelSize: CGFloat = 1_000

    private let memoryCache = NSCache<NSURL, UIImage>()
    private let session: URLSession
    private var inFlight: [URL: Task<UIImage?, Never>] = [:]
    private var memoryWarningObserver: NSObjectProtocol?

    public init(session: URLSession? = nil) {
        memoryCache.countLimit = 200
        memoryCache.totalCostLimit = 100 * 1024 * 1024 // 100 MB

        if let session {
            self.session = session
        } else {
            let config = URLSessionConfiguration.default
            config.urlCache = URLCache(
                memoryCapacity: 50 * 1024 * 1024,
                diskCapacity: 200 * 1024 * 1024,
                diskPath: "cinescope_images"
            )
            self.session = URLSession(configuration: config)
        }
    }

    deinit {
        if let memoryWarningObserver {
            NotificationCenter.default.removeObserver(memoryWarningObserver)
        }
    }

    public func image(for url: URL) async -> UIImage? {
        installMemoryWarningObserverIfNeeded()

        let nsURL = url as NSURL

        if let cachedImage = memoryCache.object(forKey: nsURL) {
            return cachedImage
        }

        if let existingTask = inFlight[url] {
            return await existingTask.value
        }

        let task = Task<UIImage?, Never> { [weak self] in
            guard let self else { return nil }
            return await self.fetchImage(for: url)
        }
        inFlight[url] = task

        let image = await task.value
        inFlight[url] = nil
        return image
    }

    public func clearCache() {
        memoryCache.removeAllObjects()
        session.configuration.urlCache?.removeAllCachedResponses()
    }

    public func currentCacheDiskUsage() -> String {
        let bytes = session.configuration.urlCache?.currentDiskUsage ?? 0
        let mb = Double(bytes) / (1024 * 1024)
        return String(format: "%.1f MB", mb)
    }

    public func currentDiskUsageBytes() -> Int {
        session.configuration.urlCache?.currentDiskUsage ?? 0
    }

    // MARK: - Private

    private func installMemoryWarningObserverIfNeeded() {
        guard memoryWarningObserver == nil else { return }

        memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            Task { await self?.clearMemoryCache() }
        }
    }

    private func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }

    private func fetchImage(for url: URL) async -> UIImage? {
        do {
            let request = URLRequest(
                url: url,
                cachePolicy: .returnCacheDataElseLoad,
                timeoutInterval: 20.0
            )
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let image = Self.downsampledImage(from: data, maxPixelSize: Self.maxPixelSize) else {
                return nil
            }

            memoryCache.setObject(image, forKey: url as NSURL, cost: data.count)
            return image
        } catch {
            return nil
        }
    }

    private static func downsampledImage(from data: Data, maxPixelSize: CGFloat) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
