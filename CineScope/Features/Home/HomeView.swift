//
//  HomeView.swift
//  CineScope
//

import SwiftUI

public struct HomeView: View {
    @Environment(AppRouter.self) private var router

    @State private var viewModel: HomeViewModel
    @State private var showKeySetup: Bool = false

    private let networkMonitor = NetworkMonitor.shared

    public init(
        movieRepository: MovieRepositoryProtocol = MovieRepository.shared,
        userMovieRepository: UserMovieRepositoryProtocol
    ) {
        _viewModel = State(initialValue: HomeViewModel(
            movieRepository: movieRepository,
            userMovieRepository: userMovieRepository
        ))
    }

    public var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.discoverPath) {
            ZStack {
                CineColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: CineSpacing.xl) {
                        // Offline banner
                        if !networkMonitor.isConnected {
                            offlineBanner
                        }

                        // Missing API credentials banner
                        if viewModel.isMissingCredentials {
                            missingKeyBanner
                        }

                        if viewModel.isLoading && viewModel.trendingMovies.isEmpty {
                            HomeSkeletonView()
                        } else if let error = viewModel.errorMessage, viewModel.trendingMovies.isEmpty {
                            errorView(message: error)
                        } else {
                            // Featured Spotlight Hero
                            if let hero = viewModel.heroMovie {
                                HeroMovieCard(
                                    movie: hero,
                                    isInWatchlist: viewModel.isInWatchlist(movie: hero),
                                    onDetailsTapped: {
                                        router.push(.movie(id: hero.id, movie: hero))
                                    },
                                    onWatchlistTapped: {
                                        viewModel.toggleWatchlist(for: hero)
                                    },
                                    onTrailerTapped: {
                                        Task {
                                            await viewModel.openHeroTrailer()
                                        }
                                    }
                                )
                            }

                            // 1. Trending Today
                            if !viewModel.trendingMovies.isEmpty {
                                MovieRowSection(
                                    title: "Trending Today",
                                    subtitle: "Most watched movies today",
                                    movies: viewModel.trendingMovies,
                                    showRank: false,
                                    isLoadingMore: viewModel.isLoadingMore(section: .trending),
                                    onMovieSelected: { router.push(.movie(id: $0.id, movie: $0)) },
                                    onPrefetch: { movie in
                                        guard viewModel.shouldLoadMore(section: .trending, movie: movie) else { return }
                                        Task { await viewModel.loadMore(section: .trending) }
                                    },
                                    onSeeAll: { router.push(.collection(.trending)) }
                                )
                            }

                            // 2. Now Playing
                            if !viewModel.nowPlayingMovies.isEmpty {
                                MovieRowSection(
                                    title: "Now Playing",
                                    subtitle: "Currently in theaters",
                                    movies: viewModel.nowPlayingMovies,
                                    showRank: false,
                                    isLoadingMore: viewModel.isLoadingMore(section: .nowPlaying),
                                    onMovieSelected: { router.push(.movie(id: $0.id, movie: $0)) },
                                    onPrefetch: { movie in
                                        guard viewModel.shouldLoadMore(section: .nowPlaying, movie: movie) else { return }
                                        Task { await viewModel.loadMore(section: .nowPlaying) }
                                    },
                                    onSeeAll: { router.push(.collection(.nowPlaying)) }
                                )
                            }

                            // 3. Top Rated (with rank badges)
                            if !viewModel.topRatedMovies.isEmpty {
                                MovieRowSection(
                                    title: "Top Rated All-Time",
                                    subtitle: "Highest rated by audiences",
                                    movies: viewModel.topRatedMovies,
                                    showRank: true,
                                    isLoadingMore: viewModel.isLoadingMore(section: .topRated),
                                    onMovieSelected: { router.push(.movie(id: $0.id, movie: $0)) },
                                    onPrefetch: { movie in
                                        guard viewModel.shouldLoadMore(section: .topRated, movie: movie) else { return }
                                        Task { await viewModel.loadMore(section: .topRated) }
                                    },
                                    onSeeAll: { router.push(.collection(.topRated)) }
                                )
                            }

                            // 4. Popular Worldwide
                            if !viewModel.popularMovies.isEmpty {
                                MovieRowSection(
                                    title: "Popular Worldwide",
                                    subtitle: "Global favorites right now",
                                    movies: viewModel.popularMovies,
                                    showRank: false,
                                    isLoadingMore: viewModel.isLoadingMore(section: .popular),
                                    onMovieSelected: { router.push(.movie(id: $0.id, movie: $0)) },
                                    onPrefetch: { movie in
                                        guard viewModel.shouldLoadMore(section: .popular, movie: movie) else { return }
                                        Task { await viewModel.loadMore(section: .popular) }
                                    },
                                    onSeeAll: { router.push(.collection(.popular)) }
                                )
                            }

                            // 5. Upcoming Releases
                            if !viewModel.upcomingMovies.isEmpty {
                                MovieRowSection(
                                    title: "Upcoming Releases",
                                    subtitle: "Coming soon to theaters",
                                    movies: viewModel.upcomingMovies,
                                    showRank: false,
                                    isLoadingMore: viewModel.isLoadingMore(section: .upcoming),
                                    onMovieSelected: { router.push(.movie(id: $0.id, movie: $0)) },
                                    onPrefetch: { movie in
                                        guard viewModel.shouldLoadMore(section: .upcoming, movie: movie) else { return }
                                        Task { await viewModel.loadMore(section: .upcoming) }
                                    },
                                    onSeeAll: { router.push(.collection(.upcoming)) }
                                )
                            }

                            Spacer(minLength: CineSpacing.xxl)
                        }
                    }
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
            .navigationTitle("CineScope")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 6) {
                        Image(systemName: "film.stack.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(CineColors.crimson)
                        Text("CINESCOPE")
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(Color.white)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showKeySetup = true
                    } label: {
                        Image(systemName: APIConfig.shared.hasCredentials ? "key.fill" : "key")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(APIConfig.shared.hasCredentials ? CineColors.gold : CineColors.textSecondary)
                    }
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                AppRouteView(route: route)
            }
            .sheet(isPresented: $showKeySetup) {
                APIKeySetupSheet {
                    Task {
                        await viewModel.loadFeed()
                    }
                }
            }
            .sheet(isPresented: $viewModel.showTrailerSheet) {
                if let url = viewModel.activeTrailerURL {
                    SafariTrailerView(url: url)
                        .ignoresSafeArea()
                }
            }
            .task {
                await viewModel.loadFeed()
            }
            .onReceive(NotificationCenter.default.publisher(for: .apiConfigDidChange)) { _ in
                Task {
                    await viewModel.loadFeed()
                }
            }
        }
    }

    private var offlineBanner: some View {
        HStack(spacing: CineSpacing.s) {
            Image(systemName: "wifi.slash")
                .foregroundStyle(CineColors.gold)
            Text("Offline Mode — Browsing cached movie catalog")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(CineColors.textPrimary)
            Spacer()
        }
        .padding(.horizontal, CineSpacing.l)
        .padding(.vertical, 10)
        .background(CineColors.gold.opacity(0.15))
    }

    private var missingKeyBanner: some View {
        HStack(spacing: CineSpacing.m) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(CineColors.crimson)

            VStack(alignment: .leading, spacing: 2) {
                Text("TMDB API Key Required")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.white)
                Text("Connect your TMDB account to load real-time movies")
                    .font(.system(size: 12))
                    .foregroundStyle(CineColors.textSecondary)
            }

            Spacer()

            Button("Configure") {
                showKeySetup = true
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(CineColors.crimson)
            .clipShape(Capsule())
        }
        .padding(CineSpacing.m)
        .background(
            RoundedRectangle(cornerRadius: CineRadius.m)
                .fill(CineColors.backgroundElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: CineRadius.m)
                        .stroke(CineColors.crimson.opacity(0.4), lineWidth: 1)
                )
        )
        .padding(.horizontal, CineSpacing.l)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: CineSpacing.l) {
            Image(systemName: "network.slash")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(CineColors.textTertiary)

            Text("Unable to Load Movies")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(CineColors.textPrimary)

            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(CineColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, CineSpacing.xl)

            PrimaryCineButton(title: "Try Again", icon: "arrow.clockwise") {
                Task {
                    await viewModel.loadFeed()
                }
            }
        }
        .padding(.vertical, CineSpacing.xxxl)
    }
}
