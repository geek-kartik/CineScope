//
//  WatchlistMovieRow.swift
//  CineScope
//

import SwiftUI

public struct WatchlistMovieRow: View {
    public let item: SavedMovieItem
    public let onToggleWatched: () -> Void
    public let onRemove: () -> Void

    public init(
        item: SavedMovieItem,
        onToggleWatched: @escaping () -> Void,
        onRemove: @escaping () -> Void
    ) {
        self.item = item
        self.onToggleWatched = onToggleWatched
        self.onRemove = onRemove
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

            // Details
            VStack(alignment: .leading, spacing: CineSpacing.xs) {
                Text(item.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(CineColors.textPrimary)
                    .lineLimit(2)

                HStack(spacing: CineSpacing.s) {
                    Text(item.formattedYear)
                        .font(.system(size: 13))
                        .foregroundStyle(CineColors.textSecondary)

                    if let runtime = item.runtime, runtime > 0 {
                        Text("•")
                            .foregroundStyle(CineColors.textTertiary)
                        Text("\(runtime)m")
                            .font(.system(size: 13))
                            .foregroundStyle(CineColors.textSecondary)
                    }

                    Spacer()

                    if item.voteAverage > 0 {
                        RatingBadge(rating: item.voteAverage, compact: true)
                    }
                }

                if !item.genresCSV.isEmpty {
                    Text(item.genresCSV)
                        .font(.system(size: 12))
                        .foregroundStyle(CineColors.textTertiary)
                        .lineLimit(1)
                }

                Spacer()

                // Quick Action buttons
                HStack(spacing: CineSpacing.m) {
                    Button(action: onToggleWatched) {
                        HStack(spacing: 4) {
                            Image(systemName: item.isWatched ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 13))
                            Text(item.isWatched ? "Watched" : "Mark Watched")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(item.isWatched ? CineColors.emerald : CineColors.textSecondary)
                    }

                    Spacer()

                    Button(action: onRemove) {
                        Image(systemName: "trash")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.red.opacity(0.8))
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
}
