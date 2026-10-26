//
//  CachedAsyncImage.swift
//  CineScope
//

import SwiftUI

public struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var hasFailed = false

    public init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    public var body: some View {
        ZStack {
            if let image = image {
                content(Image(uiImage: image))
                    .transition(.opacity.animation(.easeInOut(duration: 0.25)))
            } else if hasFailed {
                ZStack {
                    CineColors.backgroundElevated
                    VStack(spacing: CineSpacing.xs) {
                        Image(systemName: "film")
                            .font(.system(size: 24, weight: .light))
                            .foregroundStyle(CineColors.textTertiary)
                    }
                }
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let url = url else {
            hasFailed = true
            return
        }

        isLoading = true
        hasFailed = false

        if let loaded = await ImageLoader.shared.image(for: url) {
            await MainActor.run {
                self.image = loaded
                self.isLoading = false
            }
        } else {
            await MainActor.run {
                self.hasFailed = true
                self.isLoading = false
            }
        }
    }
}

public extension CachedAsyncImage where Content == AnyView, Placeholder == AnyView {
    init(url: URL?, contentMode: ContentMode = .fill) {
        self.init(
            url: url,
            content: { img in
                AnyView(img.resizable().aspectRatio(contentMode: contentMode))
            },
            placeholder: {
                AnyView(
                    Rectangle()
                        .fill(CineColors.backgroundElevated)
                        .shimmering()
                )
            }
        )
    }
}
