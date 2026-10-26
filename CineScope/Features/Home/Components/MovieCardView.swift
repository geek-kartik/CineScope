//
//  MovieCardView.swift
//  CineScope
//

import SwiftUI

public struct MovieCardView: View {
    public let movie: Movie
    public var rank: Int? = nil
    public var width: CGFloat = 145
    public var height: CGFloat = 215

    public init(movie: Movie, rank: Int? = nil, width: CGFloat = 145, height: CGFloat = 215) {
        self.movie = movie
        self.rank = rank
        self.width = width
        self.height = height
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CineSpacing.xs) {
            ZStack(alignment: .topTrailing) {
                CachedAsyncImage(url: movie.posterURL(size: "w500"))
                    .frame(width: width, height: height)
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

            // Title
            Text(movie.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(CineColors.textPrimary)
                .lineLimit(1)
                .frame(width: width, alignment: .leading)

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
            .frame(width: width, alignment: .leading)
        }
        .contentShape(Rectangle())
    }
}
