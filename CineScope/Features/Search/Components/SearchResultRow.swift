//
//  SearchResultRow.swift
//  CineScope
//

import SwiftUI

public struct SearchResultRow: View {
    public let movie: Movie

    public init(movie: Movie) {
        self.movie = movie
    }

    public var body: some View {
        HStack(alignment: .top, spacing: CineSpacing.m) {
            // Poster
            CachedAsyncImage(url: movie.posterURL(size: "w185"))
                .frame(width: 75, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: CineRadius.m))
                .overlay(
                    RoundedRectangle(cornerRadius: CineRadius.m)
                        .stroke(CineColors.surfaceBorder, lineWidth: 1)
                )

            // Info
            VStack(alignment: .leading, spacing: CineSpacing.xs) {
                Text(movie.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(CineColors.textPrimary)
                    .lineLimit(2)

                HStack(spacing: CineSpacing.s) {
                    Text(movie.formattedYear)
                        .font(.system(size: 13))
                        .foregroundStyle(CineColors.textSecondary)

                    if let genre = movie.primaryGenre {
                        Text("•")
                            .foregroundStyle(CineColors.textTertiary)
                        Text(genre)
                            .font(.system(size: 13))
                            .foregroundStyle(CineColors.textSecondary)
                    }

                    Spacer()

                    if movie.voteAverage > 0 {
                        RatingBadge(rating: movie.voteAverage, compact: true)
                    }
                }

                if !movie.overview.isEmpty {
                    Text(movie.overview)
                        .font(.system(size: 12))
                        .foregroundStyle(CineColors.textTertiary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }

            Spacer()
        }
        .padding(CineSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: CineRadius.l)
                .fill(CineColors.backgroundElevated.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: CineRadius.l)
                        .stroke(CineColors.surfaceBorder.opacity(0.6), lineWidth: 1)
                )
        )
    }
}
