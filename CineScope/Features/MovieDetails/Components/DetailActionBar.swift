//
//  DetailActionBar.swift
//  CineScope
//

import SwiftUI

public struct DetailActionBar: View {
    public let isInWatchlist: Bool
    public let isFavorite: Bool
    public let isWatched: Bool
    public let hasTrailer: Bool
    public let movieTitle: String
    public let movieURL: URL?

    public let onWatchlistTapped: () -> Void
    public let onFavoriteTapped: () -> Void
    public let onWatchedTapped: () -> Void
    public let onTrailerTapped: () -> Void

    public init(
        isInWatchlist: Bool,
        isFavorite: Bool,
        isWatched: Bool,
        hasTrailer: Bool,
        movieTitle: String,
        movieURL: URL? = nil,
        onWatchlistTapped: @escaping () -> Void,
        onFavoriteTapped: @escaping () -> Void,
        onWatchedTapped: @escaping () -> Void,
        onTrailerTapped: @escaping () -> Void
    ) {
        self.isInWatchlist = isInWatchlist
        self.isFavorite = isFavorite
        self.isWatched = isWatched
        self.hasTrailer = hasTrailer
        self.movieTitle = movieTitle
        self.movieURL = movieURL
        self.onWatchlistTapped = onWatchlistTapped
        self.onFavoriteTapped = onFavoriteTapped
        self.onWatchedTapped = onWatchedTapped
        self.onTrailerTapped = onTrailerTapped
    }

    public var body: some View {
        HStack(spacing: CineSpacing.m) {
            // Watchlist primary action
            Button(action: onWatchlistTapped) {
                HStack(spacing: 6) {
                    Image(systemName: isInWatchlist ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 14, weight: .bold))
                    Text(isInWatchlist ? "In Watchlist" : "Add to Watchlist")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    isInWatchlist ?
                    AnyShapeStyle(CineColors.crimsonGradient) :
                    AnyShapeStyle(CineColors.backgroundElevated)
                )
                .clipShape(RoundedRectangle(cornerRadius: CineRadius.m))
                .overlay(
                    RoundedRectangle(cornerRadius: CineRadius.m)
                        .stroke(isInWatchlist ? Color.clear : CineColors.surfaceBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            // Favorite button
            RoundActionButton(
                icon: isFavorite ? "heart.fill" : "heart",
                isFilled: isFavorite,
                filledColor: CineColors.crimson,
                action: onFavoriteTapped
            )

            // Watched button
            RoundActionButton(
                icon: isWatched ? "checkmark.circle.fill" : "checkmark.circle",
                isFilled: isWatched,
                filledColor: CineColors.emerald,
                action: onWatchedTapped
            )

            // Trailer button
            if hasTrailer {
                RoundActionButton(
                    icon: "play.fill",
                    isFilled: false,
                    action: onTrailerTapped
                )
            }

            // Native ShareLink
            if let shareURL = movieURL ?? URL(string: "https://www.themoviedb.org/movie") {
                ShareLink(item: shareURL, subject: Text(movieTitle), message: Text("Check out \(movieTitle) on CineScope!")) {
                    ZStack {
                        Circle()
                            .fill(CineColors.backgroundElevated.opacity(0.85))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle().stroke(CineColors.surfaceBorder, lineWidth: 1)
                            )
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(CineColors.textPrimary)
                    }
                }
            }
        }
        .padding(.horizontal, CineSpacing.l)
    }
}
