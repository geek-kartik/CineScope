//
//  DetailHeroBanner.swift
//  CineScope
//

import SwiftUI

public struct DetailHeroBanner: View {
    public let detail: MovieDetail?
    public let fallbackMovie: Movie?

    public init(detail: MovieDetail?, fallbackMovie: Movie?) {
        self.detail = detail
        self.fallbackMovie = fallbackMovie
    }

    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Backdrop
            GeometryReader { proxy in
                CachedAsyncImage(url: detail?.backdropURL(size: "w1280") ?? fallbackMovie?.backdropURL(size: "w1280"))
                    .frame(width: proxy.size.width, height: 380)
                    .clipped()
            }
            .frame(height: 380)

            // Gradient fade
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
            .frame(height: 380)

            // Content header
            HStack(alignment: .bottom, spacing: CineSpacing.l) {
                // Poster thumbnail
                CachedAsyncImage(url: detail?.posterURL(size: "w500") ?? fallbackMovie?.posterURL(size: "w500"))
                    .frame(width: 110, height: 165)
                    .clipShape(RoundedRectangle(cornerRadius: CineRadius.m))
                    .overlay(
                        RoundedRectangle(cornerRadius: CineRadius.m)
                            .stroke(CineColors.surfaceBorder, lineWidth: 1)
                    )
                    .shadow(color: CineShadow.deep, radius: 10, x: 0, y: 6)

                // Title & key metadata
                VStack(alignment: .leading, spacing: CineSpacing.xs) {
                    Text(title)
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundStyle(Color.white)
                        .lineLimit(3)

                    if let tagline = detail?.tagline, !tagline.isEmpty {
                        Text("\"\(tagline)\"")
                            .font(.system(size: 13, weight: .regular).italic())
                            .foregroundStyle(CineColors.textSecondary)
                            .lineLimit(2)
                    }

                    // Metadata row
                    HStack(spacing: CineSpacing.s) {
                        Text(year)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(CineColors.textSecondary)

                        if let runtime = detail?.formattedRuntime, runtime != "N/A" {
                            Text("•")
                                .foregroundStyle(CineColors.textTertiary)
                            Text(runtime)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(CineColors.textSecondary)
                        }

                        if rating > 0 {
                            Spacer()
                            RatingBadge(rating: rating, compact: true)
                        }
                    }

                    // Genres
                    if !genres.isEmpty {
                        Text(genres.prefix(3).joined(separator: ", "))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(CineColors.crimsonLight)
                            .lineLimit(1)
                            .padding(.top, 2)
                    }
                }
            }
            .padding(.horizontal, CineSpacing.l)
            .padding(.bottom, CineSpacing.m)
        }
        .frame(height: 380)
    }

    private var title: String {
        detail?.title ?? fallbackMovie?.title ?? "Movie"
    }

    private var year: String {
        detail?.formattedYear ?? fallbackMovie?.formattedYear ?? "N/A"
    }

    private var rating: Double {
        detail?.voteAverage ?? fallbackMovie?.voteAverage ?? 0.0
    }

    private var genres: [String] {
        if let g = detail?.genres, !g.isEmpty {
            return g.map(\.name)
        }
        return fallbackMovie?.genreNames ?? []
    }
}
