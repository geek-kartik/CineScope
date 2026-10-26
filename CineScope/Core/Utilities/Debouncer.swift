//
//  Debouncer.swift
//  CineScope
//

import Foundation

public final class Debouncer: @unchecked Sendable {
    private let delay: TimeInterval
    private var task: Task<Void, Never>?
    private let lock = NSLock()

    public init(delay: TimeInterval = 0.3) {
        self.delay = delay
    }

    public func debounce(action: @escaping @Sendable () async -> Void) {
        lock.lock()
        task?.cancel()
        task = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                if !Task.isCancelled {
                    await action()
                }
            } catch {
                // Cancelled
            }
        }
        lock.unlock()
    }

    public func cancel() {
        lock.lock()
        task?.cancel()
        task = nil
        lock.unlock()
    }
}
