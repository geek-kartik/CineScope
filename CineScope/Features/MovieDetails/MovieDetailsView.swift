//
//  MovieDetailsView.swift
//  CineScope
//

import SwiftUI
import SwiftData

public struct MovieDetailsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: MovieDetailsViewModel
    @State private var isOverviewExpanded: Bool = false
    @State private var nextSelectedMovie: Movie? = nil

    public init(
        movieId: Int,
        initialMovie: Movie? = nil,
        movieRepository: MovieRepositoryProtocol = MovieRepository.shared,
        userMovieRepository: UserMovieRepositoryProtocol? = nil
    ) {
        let repo = userMovieRepository ?? UserMovieRepository(context: PersistenceController.shared.container.mainContext)
        _viewModel = State(initialValue: MovieDetailsViewModel(
            movieId: movieId,
            initialMovie: initialMovie,
            movieRepository: movieRepository,
            userMovieRepository: repo
        ))
    }

    public var body: some View {
        ZStack {
            CineColors.backgroundPrimary.ignoresSafeArea()

            ScrollView {
                VStack(spacing: CineSpacing.xl) {
                    // Hero backdrop & poster
                    DetailHeroBanner(
                        detail: viewModel.movieDetail,
                        fallbackMovie: viewModel.initialMovie
                    )

                    // Action bar
                    DetailActionBar(
                        isInWatchlist: viewModel.userStatus.isInWatchlist,
                        isFavorite: viewModel.userStatus.isFavorite,
                        isWatched: viewModel.userStatus.isWatched,
                        hasTrailer: viewModel.movieDetail?.trailerURL != nil,
                        movieTitle: viewModel.movieDetail?.title ?? viewModel.initialMovie?.title ?? "Movie",
                        movieURL: viewModel.movieDetail?.trailerURL,
                        onWatchlistTapped: {
                            viewModel.toggleWatchlist()
                        },
                        onFavoriteTapped: {
                            viewModel.toggleFavorite()
                        },
                        onWatchedTapped: {
                            viewModel.toggleWatched()
                        },
                        onTrailerTapped: {
                            viewModel.showTrailerSheet = true
                        }
                    )

                    // Synopsis / Overview
                    synopsisSection

                    // Cast Section
                    if let cast = viewModel.movieDetail?.credits?.cast, !cast.isEmpty {
                        CastCarouselView(cast: cast)
                    }

                    // Movie Facts Grid
                    if let detail = viewModel.movieDetail {
                        MovieMetaGridView(detail: detail)
                    }

                    // Personal Rating & Review Section
                    PersonalReviewSection(
                        rating: $viewModel.personalRating,
                        reviewText: $viewModel.personalReview,
                        onSave: { rating, review in
                            viewModel.savePersonalReview(rating: rating, review: review)
                        }
                    )

                    // Recommendations / Similar movies
                    recommendationsSection

                    Spacer(minLength: CineSpacing.xxxl)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $nextSelectedMovie) { movie in
            MovieDetailsView(movieId: movie.id, initialMovie: movie)
        }
        .sheet(isPresented: $viewModel.showTrailerSheet) {
            if let trailerURL = viewModel.movieDetail?.trailerURL {
                SafariTrailerView(url: trailerURL)
                    .ignoresSafeArea()
            }
        }
        .task {
            await viewModel.loadDetails()
        }
    }

    // MARK: - Subviews

    private var synopsisSection: some View {
        VStack(alignment: .leading, spacing: CineSpacing.s) {
            Text("Synopsis")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(CineColors.textPrimary)

            let overview = viewModel.movieDetail?.overview ?? viewModel.initialMovie?.overview ?? "No overview available."

            VStack(alignment: .leading, spacing: CineSpacing.xs) {
                Text(overview)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(CineColors.textSecondary)
                    .lineSpacing(4)
                    .lineLimit(isOverviewExpanded ? nil : 4)

                if overview.count > 180 {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isOverviewExpanded.toggle()
                        }
                    } label: {
                        Text(isOverviewExpanded ? "Show Less" : "Read More")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(CineColors.crimson)
                    }
                    .padding(.top, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, CineSpacing.l)
    }

    @ViewBuilder
    private var recommendationsSection: some View {
        let recommendations = viewModel.movieDetail?.recommendations?.results
            ?? viewModel.movieDetail?.similar?.results
            ?? []

        if !recommendations.isEmpty {
            VStack(alignment: .leading, spacing: CineSpacing.m) {
                Text("More Like This")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(CineColors.textPrimary)
                    .padding(.horizontal, CineSpacing.l)

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: CineSpacing.m) {
                        ForEach(recommendations.prefix(10)) { movie in
                            Button {
                                nextSelectedMovie = movie
                            } label: {
                                MovieCardView(movie: movie)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, CineSpacing.l)
                }
            }
        }
    }
}
