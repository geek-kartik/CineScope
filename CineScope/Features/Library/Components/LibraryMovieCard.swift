//
//  LibraryMovieCard.swift
//  CineScope
//

import SwiftUI

public struct LibraryMovieCard: View {
    public let item: SavedMovieItem

    public init(item: SavedMovieItem) {
        self.item = item
    }

    public var body: some View {
        HStack(alignment: .top, spacing: CineSpacing.m) {
            // Poster
            CachedAsyncImage(url: item.posterURL(size: "w185"))
                .frame(width: 75, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: CineRadius.m))
                .overlay(
                    RoundedRectangle(cornerRadius: CineRadius.m)
                        .stroke(CineColors.surfaceBorder, lineWidth: 1)
                )

            // Info
            VStack(alignment: .leading, spacing: CineSpacing.xs) {
                Text(item.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(CineColors.textPrimary)
                    .lineLimit(1)

                HStack(spacing: CineSpacing.s) {
                    Text(item.formattedYear)
                        .font(.system(size: 13))
                        .foregroundStyle(CineColors.textSecondary)

                    if let userRating = item.userRating {
                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(CineColors.gold)
                            Text("\(Int(userRating))/5 (My Rating)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(CineColors.gold)
                        }
                    } else if item.voteAverage > 0 {
                        RatingBadge(rating: item.voteAverage, compact: true)
                    }
                }

                if let review = item.userReview, !review.isEmpty {
                    Text("\"\(review)\"")
                        .font(.system(size: 12, weight: .regular).italic())
                        .foregroundStyle(CineColors.textSecondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }

                Spacer()

                // Status badges
                HStack(spacing: CineSpacing.s) {
                    if item.isWatched {
                        statusBadge(text: "Watched", icon: "checkmark.circle.fill", color: CineColors.emerald)
                    }
                    if item.isFavorite {
                        statusBadge(text: "Favorite", icon: "heart.fill", color: CineColors.crimson)
                    }
                    if item.isWatchlist {
                        statusBadge(text: "Watchlist", icon: "bookmark.fill", color: CineColors.cyan)
                    }
                }
            }
        }
        .padding(CineSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: CineRadius.l)
                .fill(CineColors.backgroundElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: CineRadius.l)
                        .stroke(CineColors.surfaceBorder, lineWidth: 1)
                )
        )
    }

    private func statusBadge(text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
}
