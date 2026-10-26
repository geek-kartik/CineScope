//
//  HeroMovieCard.swift
//  CineScope
//

import SwiftUI

public struct HeroMovieCard: View {
    public let movie: Movie
    public var isInWatchlist: Bool = false
    public let onDetailsTapped: () -> Void
    public let onWatchlistTapped: () -> Void
    public let onTrailerTapped: () -> Void

    public init(
        movie: Movie,
        isInWatchlist: Bool = false,
        onDetailsTapped: @escaping () -> Void,
        onWatchlistTapped: @escaping () -> Void,
        onTrailerTapped: @escaping () -> Void
    ) {
        self.movie = movie
        self.isInWatchlist = isInWatchlist
        self.onDetailsTapped = onDetailsTapped
        self.onWatchlistTapped = onWatchlistTapped
        self.onTrailerTapped = onTrailerTapped
    }

    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Backdrop Image
            CachedAsyncImage(url: movie.backdropURL(size: "w1280"))
                .frame(maxWidth: .infinity)
                .frame(height: 440)
                .clipped()

            // Gradient Overlays
            LinearGradient(
                colors: [
                    Color.clear,
                    CineColors.backgroundPrimary.opacity(0.4),
                    CineColors.backgroundPrimary.opacity(0.85),
                    CineColors.backgroundPrimary
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 440)

            // Content Overlay
            VStack(alignment: .leading, spacing: CineSpacing.s) {
                // Top Tag: Featured Movie
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(CineColors.crimson)
                        Text("FEATURED SPOTLIGHT")
                            .font(.system(size: 11, weight: .black))
                            .foregroundStyle(CineColors.textPrimary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(CineColors.surfaceGlass)
                            .overlay(Capsule().stroke(CineColors.crimson.opacity(0.5), lineWidth: 1))
                    )

                    Spacer()

                    RatingBadge(rating: movie.voteAverage)
                }

                // Title
                Text(movie.title)
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(Color.white)
                    .lineLimit(2)
                    .shadow(color: Color.black.opacity(0.8), radius: 4, x: 0, y: 2)

                // Meta row: Year • Genres
                HStack(spacing: CineSpacing.s) {
                    Text(movie.formattedYear)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(CineColors.textSecondary)

                    if !movie.genreNames.isEmpty {
                        Text("•")
                            .foregroundStyle(CineColors.textTertiary)
                        Text(movie.genreNames.prefix(2).joined(separator: ", "))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(CineColors.textSecondary)
                    }
                }

                // Overview snippet
                Text(movie.overview)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(CineColors.textSecondary.opacity(0.9))
                    .lineLimit(2)
                    .padding(.top, CineSpacing.xxs)

                // Action buttons
                HStack(spacing: CineSpacing.m) {
                    PrimaryCineButton(
                        title: "Details",
                        icon: "info.circle.fill",
                        action: onDetailsTapped
                    )

                    SecondaryCineButton(
                        title: isInWatchlist ? "Saved" : "Watchlist",
                        icon: isInWatchlist ? "checkmark" : "plus",
                        action: onWatchlistTapped
                    )

                    RoundActionButton(
                        icon: "play.fill",
                        isFilled: false,
                        size: 44,
                        action: onTrailerTapped
                    )
                }
                .padding(.top, CineSpacing.xs)
            }
            .padding(.horizontal, CineSpacing.l)
            .padding(.bottom, CineSpacing.l)
        }
        .frame(height: 440)
    }
}
