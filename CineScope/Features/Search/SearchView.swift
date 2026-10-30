//
//  SearchView.swift
//  CineScope
//

import SwiftUI

public struct SearchView: View {
    @Environment(AppRouter.self) private var router

    @State private var viewModel: SearchViewModel

    public init(movieRepository: MovieRepositoryProtocol = MovieRepository.shared) {
        _viewModel = State(initialValue: SearchViewModel(movieRepository: movieRepository))
    }

    public var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.searchPath) {
            ZStack {
                CineColors.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: CineSpacing.m) {
                    // Search bar
                    SearchBarView(text: $viewModel.query) {
                        viewModel.handleQueryChange()
                    }
                    .padding(.horizontal, CineSpacing.l)
                    .padding(.top, CineSpacing.s)

                    // Genre filter pills
                    genreScrollView

                    // Results or Suggestions
                    ScrollView {
                        VStack(spacing: CineSpacing.l) {
                            if viewModel.isLoading && viewModel.searchResults.isEmpty {
                                loadingSkeleton
                            } else if let error = viewModel.errorMessage, viewModel.searchResults.isEmpty {
                                errorStateView(error)
                            } else if shouldShowInitialState {
                                initialContent
                            } else if viewModel.searchResults.isEmpty && !viewModel.isLoading {
                                emptyResultsView
                            } else {
                                resultsList
                            }
                        }
                        .padding(.horizontal, CineSpacing.l)
                        .padding(.bottom, CineSpacing.xl)
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: AppRoute.self) { route in
                AppRouteView(route: route)
            }
            .task {
                await viewModel.loadSuggestions()
            }
            .onChange(of: router.pendingSearchQuery, initial: true) { _, pendingQuery in
                guard let pendingQuery, !pendingQuery.isEmpty else { return }
                viewModel.query = pendingQuery
                router.pendingSearchQuery = nil
            }
            .onDisappear {
                viewModel.cancelActiveSearch()
            }
        }
    }

    private var shouldShowInitialState: Bool {
        viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && viewModel.selectedGenre == nil
    }

    // MARK: - Subviews

    private var genreScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CineSpacing.s) {
                GenrePill(
                    text: "All",
                    isSelected: viewModel.selectedGenre == nil
                ) {
                    viewModel.selectedGenre = nil
                }

                ForEach(MovieGenres.standard) { genre in
                    GenrePill(
                        text: genre.name,
                        isSelected: viewModel.selectedGenre?.id == genre.id
                    ) {
                        if viewModel.selectedGenre?.id == genre.id {
                            viewModel.selectedGenre = nil
                        } else {
                            viewModel.selectedGenre = genre
                        }
                    }
                }
            }
            .padding(.horizontal, CineSpacing.l)
            .padding(.vertical, CineSpacing.xs)
        }
    }

    private var initialContent: some View {
        VStack(alignment: .leading, spacing: CineSpacing.xl) {
            // Recent Searches
            if !viewModel.recentSearches.isEmpty {
                VStack(alignment: .leading, spacing: CineSpacing.m) {
                    HStack {
                        Text("Recent Searches")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(CineColors.textPrimary)
                        Spacer()
                        Button("Clear") {
                            viewModel.clearAllRecentSearches()
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(CineColors.crimson)
                    }

                    FlowLayout(spacing: CineSpacing.s) {
                        ForEach(viewModel.recentSearches, id: \.self) { term in
                            Button {
                                viewModel.selectRecentSearch(term)
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "clock.arrow.circlepath")
                                        .font(.system(size: 11))
                                        .foregroundStyle(CineColors.textTertiary)
                                    Text(term)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(CineColors.textPrimary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(CineColors.backgroundElevated)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(CineColors.surfaceBorder, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.top, CineSpacing.s)
            }

            // Trending Suggestions
            if !viewModel.trendingSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: CineSpacing.m) {
                    Text("Popular Suggestions")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(CineColors.textPrimary)

                    LazyVStack(spacing: CineSpacing.m) {
                        ForEach(viewModel.trendingSuggestions) { movie in
                            Button {
                                router.push(.movie(id: movie.id, movie: movie))
                            } label: {
                                SearchResultRow(movie: movie)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var resultsList: some View {
        LazyVStack(spacing: CineSpacing.m) {
            ForEach(viewModel.searchResults) { movie in
                Button {
                    router.push(.movie(id: movie.id, movie: movie))
                } label: {
                    SearchResultRow(movie: movie)
                }
                .buttonStyle(.plain)
                .onAppear {
                    guard viewModel.shouldLoadMore(after: movie) else { return }
                    viewModel.loadMore()
                }
            }

            if viewModel.isLoadingMore {
                ProgressView()
                    .tint(CineColors.crimson)
                    .padding()
            }
        }
    }

    private var emptyResultsView: some View {
        VStack(spacing: CineSpacing.m) {
            Image(systemName: "film")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(CineColors.textTertiary)
                .padding(.top, CineSpacing.xxl)

            Text("No Results Found")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(CineColors.textPrimary)

            Text("We couldn't find any movies matching \"\(viewModel.query)\". Try checking the spelling or searching for another title.")
                .font(.system(size: 14))
                .foregroundStyle(CineColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, CineSpacing.l)
        }
        .padding(.vertical, CineSpacing.xl)
    }

    private var loadingSkeleton: some View {
        VStack(spacing: CineSpacing.m) {
            ForEach(0..<4, id: \.self) { _ in
                HStack(spacing: CineSpacing.m) {
                    RoundedRectangle(cornerRadius: CineRadius.m)
                        .fill(CineColors.backgroundElevated)
                        .frame(width: 75, height: 110)
                        .shimmering()

                    VStack(alignment: .leading, spacing: CineSpacing.s) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(CineColors.backgroundElevated)
                            .frame(width: 180, height: 16)
                            .shimmering()

                        RoundedRectangle(cornerRadius: 4)
                            .fill(CineColors.backgroundElevated)
                            .frame(width: 90, height: 12)
                            .shimmering()

                        RoundedRectangle(cornerRadius: 4)
                            .fill(CineColors.backgroundElevated)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .shimmering()
                    }
                }
                .padding(CineSpacing.m)
                .background(
                    RoundedRectangle(cornerRadius: CineRadius.l)
                        .fill(CineColors.backgroundElevated.opacity(0.4))
                )
            }
        }
    }

    private func errorStateView(_ error: String) -> some View {
        VStack(spacing: CineSpacing.m) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(CineColors.crimson)
                .padding(.top, CineSpacing.xl)

            Text("Search Error")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(CineColors.textPrimary)

            Text(error)
                .font(.system(size: 14))
                .foregroundStyle(CineColors.textSecondary)
                .multilineTextAlignment(.center)

            PrimaryCineButton(title: "Retry", icon: "arrow.clockwise") {
                viewModel.handleQueryChange()
            }
        }
        .padding(.vertical, CineSpacing.xl)
    }
}

// Simple FlowLayout for chips
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        return CGSize(width: width, height: currentY + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
