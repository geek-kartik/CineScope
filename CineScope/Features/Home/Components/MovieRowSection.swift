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
    public var isLoadingMore: Bool = false
    public var onMovieSelected: (Movie) -> Void
    public var onPrefetch: ((Movie) -> Void)? = nil
    public var onSeeAll: (() -> Void)? = nil

    public init(
        title: String,
        subtitle: String? = nil,
        movies: [Movie],
        showRank: Bool = false,
        isLoadingMore: Bool = false,
        onMovieSelected: @escaping (Movie) -> Void,
        onPrefetch: ((Movie) -> Void)? = nil,
        onSeeAll: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.movies = movies
        self.showRank = showRank
        self.isLoadingMore = isLoadingMore
        self.onMovieSelected = onMovieSelected
        self.onPrefetch = onPrefetch
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
                        .onAppear {
                            guard index >= max(0, movies.count - 3) else { return }
                            onPrefetch?(movie)
                        }
                    }

                    if isLoadingMore {
                        ProgressView()
                            .tint(CineColors.crimson)
                            .frame(width: 80, height: 160)
                    }
                }
                .padding(.horizontal, CineSpacing.l)
            }
        }
    }
}
