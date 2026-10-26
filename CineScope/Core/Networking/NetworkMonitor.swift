//
//  NetworkMonitor.swift
//  CineScope
//

import Foundation
import Network
import Observation

@Observable
public final class NetworkMonitor: @unchecked Sendable {
    public static let shared = NetworkMonitor()

    public private(set) var isConnected: Bool = true
    public private(set) var isExpensive: Bool = false

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.cinescope.networkmonitor")

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
                self?.isExpensive = path.isExpensive
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
