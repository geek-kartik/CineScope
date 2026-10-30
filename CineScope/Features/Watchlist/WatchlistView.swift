//
//  WatchlistView.swift
//  CineScope
//

import SwiftUI

public struct WatchlistView: View {
    @Environment(AppRouter.self) private var router

    @State private var viewModel: WatchlistViewModel
    public var onExploreTapped: (() -> Void)? = nil

    private let columns = [
        GridItem(.flexible(), spacing: CineSpacing.m),
        GridItem(.flexible(), spacing: CineSpacing.m)
    ]

    public init(
        userMovieRepository: UserMovieRepositoryProtocol,
        onExploreTapped: (() -> Void)? = nil
    ) {
        _viewModel = State(initialValue: WatchlistViewModel(repository: userMovieRepository))
        self.onExploreTapped = onExploreTapped
    }

    public var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.watchlistPath) {
            ZStack {
                CineColors.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: CineSpacing.m) {
                    // Filter and View Mode Toolbar
                    controlsBar

                    if viewModel.filteredAndSortedItems.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            if viewModel.viewMode == .grid {
                                gridContent
                            } else {
                                listContent
                            }
                        }
                    }
                }
            }
            .navigationTitle("Watchlist")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: AppRoute.self) { route in
                AppRouteView(route: route)
            }
            .onAppear {
                viewModel.loadWatchlist()
            }
        }
    }

    // MARK: - Subviews

    private var controlsBar: some View {
        HStack {
            // Filter Picker
            Picker("Filter", selection: $viewModel.filterOption) {
                ForEach(WatchlistFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)

            Spacer()

            // Sort Menu
            Menu {
                Picker("Sort By", selection: $viewModel.sortOption) {
                    ForEach(WatchlistSortOption.allCases) { opt in
                        Text(opt.rawValue).tag(opt)
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down.circle")
                    .font(.system(size: 18))
                    .foregroundStyle(CineColors.textPrimary)
            }

            // Grid / List Toggle
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.viewMode = (viewModel.viewMode == .grid) ? .list : .grid
                }
            } label: {
                Image(systemName: viewModel.viewMode == .grid ? "rectangle.grid.1x2" : "square.grid.2x2")
                    .font(.system(size: 18))
                    .foregroundStyle(CineColors.crimson)
            }
        }
        .padding(.horizontal, CineSpacing.l)
        .padding(.top, CineSpacing.xs)
    }

    private var gridContent: some View {
        LazyVGrid(columns: columns, spacing: CineSpacing.l) {
            ForEach(viewModel.filteredAndSortedItems, id: \.id) { item in
                Button {
                    router.push(.movie(id: item.id, movie: item.toMovie()))
                } label: {
                    VStack(alignment: .leading, spacing: CineSpacing.xs) {
                        MovieCardView(
                            movie: item.toMovie(),
                            width: (UIScreen.main.bounds.width - 48) / 2,
                            height: ((UIScreen.main.bounds.width - 48) / 2) * 1.5
                        )

                        if item.isWatched {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 11))
                                    .foregroundStyle(CineColors.emerald)
                                Text("Watched")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(CineColors.emerald)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button(item.isWatched ? "Mark Unwatched" : "Mark as Watched") {
                        viewModel.toggleWatched(item)
                    }
                    Button(role: .destructive) {
                        viewModel.removeFromWatchlist(item)
                    } label: {
                        Label("Remove from Watchlist", systemImage: "trash")
                    }
                }
            }
        }
        .padding(CineSpacing.l)
    }

    private var listContent: some View {
        LazyVStack(spacing: CineSpacing.m) {
            ForEach(viewModel.filteredAndSortedItems, id: \.id) { item in
                Button {
                    router.push(.movie(id: item.id, movie: item.toMovie()))
                } label: {
                    WatchlistMovieRow(
                        item: item,
                        onToggleWatched: {
                            viewModel.toggleWatched(item)
                        },
                        onRemove: {
                            viewModel.removeFromWatchlist(item)
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(CineSpacing.l)
    }

    private var emptyState: some View {
        VStack(spacing: CineSpacing.l) {
            Spacer()

            ZStack {
                Circle()
                    .fill(CineColors.backgroundElevated)
                    .frame(width: 100, height: 100)

                Image(systemName: "bookmark.slash")
                    .font(.system(size: 40))
                    .foregroundStyle(CineColors.textTertiary)
            }

            VStack(spacing: CineSpacing.xs) {
                Text(viewModel.allItems.isEmpty ? "Your Watchlist is Empty" : "No Movies Match Filter")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(CineColors.textPrimary)

                Text(viewModel.allItems.isEmpty ? "Keep track of movies you want to watch. Add them from the Home or Search screens." : "Try switching your filter above.")
                    .font(.system(size: 14))
                    .foregroundStyle(CineColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, CineSpacing.xl)
            }

            if viewModel.allItems.isEmpty {
                PrimaryCineButton(title: "Explore Movies", icon: "sparkles") {
                    onExploreTapped?()
                }
                .padding(.top, CineSpacing.s)
            }

            Spacer()
        }
    }
}
