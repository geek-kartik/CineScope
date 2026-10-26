//
//  MovieRowSection.swift
//  CineScope
//

import SwiftUI

public struct MovieRowSection: View {
    public let title: String
    public var subtitle: String? = nil
    public let movies: [Movie]
    public var showRank: Bool = false
    public var onMovieSelected: (Movie) -> Void
    public var onSeeAll: (() -> Void)? = nil

    public init(
        title: String,
        subtitle: String? = nil,
        movies: [Movie],
        showRank: Bool = false,
        onMovieSelected: @escaping (Movie) -> Void,
        onSeeAll: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.movies = movies
        self.showRank = showRank
        self.onMovieSelected = onMovieSelected
        self.onSeeAll = onSeeAll
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: CineSpacing.m) {
            SectionHeaderView(
                title: title,
                subtitle: subtitle,
                seeAllAction: onSeeAll
            )

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: CineSpacing.m) {
                    ForEach(Array(movies.enumerated()), id: \.element.id) { index, movie in
                        Button {
                            onMovieSelected(movie)
                        } label: {
                            MovieCardView(
                                movie: movie,
                                rank: showRank ? (index + 1) : nil
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, CineSpacing.l)
            }
        }
    }
}
