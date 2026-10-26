//
//  TrailerPlayerView.swift
//  CineScope
//

import SwiftUI
import SafariServices

public struct SafariTrailerView: UIViewControllerRepresentable {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        let vc = SFSafariViewController(url: url, configuration: config)
        vc.preferredBarTintColor = UIColor(CineColors.backgroundPrimary)
        vc.preferredControlTintColor = UIColor(CineColors.crimson)
        return vc
    }

    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
