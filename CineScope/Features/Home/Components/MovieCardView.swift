//
//  MovieCardView.swift
//  CineScope
//

import SwiftUI

public struct MovieCardView: View {
    public let movie: Movie
    public var rank: Int? = nil
    /// When both dimensions are supplied the card renders at a fixed size.
    /// When they are `nil` the card stretches to the width proposed by its
    /// container, which lets grids adapt to iPhone and iPad widths.
    public var width: CGFloat? = nil
    public var height: CGFloat? = nil

    public init(
        movie: Movie,
        rank: Int? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil
    ) {
        self.movie = movie
        self.rank = rank
        self.width = width
        self.height = height
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CineSpacing.xs) {
            poster

            // Title
            Text(movie.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(CineColors.textPrimary)
                .lineLimit(1)
                .frame(maxWidth: contentWidth, alignment: .leading)

            // Year and Genre
            HStack(spacing: 4) {
                Text(movie.formattedYear)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(CineColors.textSecondary)

                if let genre = movie.primaryGenre {
                    Text("•")
                        .font(.system(size: 10))
                        .foregroundStyle(CineColors.textTertiary)
                    Text(genre)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(CineColors.textSecondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: contentWidth, alignment: .leading)
        }
        .frame(maxWidth: contentWidth, alignment: .leading)
        .contentShape(Rectangle())
    }

    private var contentWidth: CGFloat? {
        width ?? .infinity
    }

    private var poster: some View {
        ZStack(alignment: .topTrailing) {
            posterImage
                .clipShape(RoundedRectangle(cornerRadius: CineRadius.m))
                .overlay(
                    RoundedRectangle(cornerRadius: CineRadius.m)
                        .stroke(CineColors.surfaceBorder.opacity(0.8), lineWidth: 1)
                )
                .shadow(color: CineShadow.medium, radius: 8, x: 0, y: 4)

            // Top badges
            HStack {
                if let rank = rank {
                    RankBadge(rank: rank)
                }
                Spacer()
                if movie.voteAverage > 0 {
                    RatingBadge(rating: movie.voteAverage, compact: true)
                }
            }
            .padding(CineSpacing.xs)
        }
    }

    @ViewBuilder
    private var posterImage: some View {
        if let width, let height {
            CachedAsyncImage(url: movie.posterURL(size: "w500"))
                .frame(width: width, height: height)
                .clipped()
        } else {
            CachedAsyncImage(url: movie.posterURL(size: "w500"))
                .aspectRatio(2.0 / 3.0, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipped()
        }
    }
}
