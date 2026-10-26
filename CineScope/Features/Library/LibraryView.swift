//
//  LibraryView.swift
//  CineScope
//

import SwiftUI

public struct LibraryView: View {
    @State private var viewModel: LibraryViewModel
    @State private var selectedMovie: Movie? = nil
    public var onExploreTapped: (() -> Void)? = nil

    public init(
        userMovieRepository: UserMovieRepositoryProtocol,
        onExploreTapped: (() -> Void)? = nil
    ) {
        _viewModel = State(initialValue: LibraryViewModel(repository: userMovieRepository))
        self.onExploreTapped = onExploreTapped
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                CineColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: CineSpacing.xl) {
                        // Statistics Header
                        LibraryStatsHeader(stats: viewModel.stats)
                            .padding(.top, CineSpacing.s)

                        // Segment Picker
                        Picker("Category", selection: $viewModel.selectedSegment) {
                            ForEach(LibrarySegment.allCases) { seg in
                                Text(seg.rawValue).tag(seg)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, CineSpacing.l)

                        // Items list or empty state
                        if viewModel.currentItems.isEmpty {
                            emptyState
                        } else {
                            LazyVStack(spacing: CineSpacing.m) {
                                ForEach(viewModel.currentItems, id: \.id) { item in
                                    Button {
                                        selectedMovie = item.toMovie()
                                    } label: {
                                        LibraryMovieCard(item: item)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            viewModel.removeMovie(item)
                                        } label: {
                                            Label("Remove", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, CineSpacing.l)
                        }

                        Spacer(minLength: CineSpacing.xxl)
                    }
                }
            }
            .navigationTitle("My Library")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedMovie) { movie in
                MovieDetailsView(movieId: movie.id, initialMovie: movie)
            }
            .onAppear {
                viewModel.loadLibrary()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: CineSpacing.l) {
            ZStack {
                Circle()
                    .fill(CineColors.backgroundElevated)
                    .frame(width: 80, height: 80)

                Image(systemName: iconForCurrentSegment)
                    .font(.system(size: 32))
                    .foregroundStyle(CineColors.textTertiary)
            }
            .padding(.top, CineSpacing.xl)

            VStack(spacing: CineSpacing.xs) {
                Text(titleForCurrentSegment)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(CineColors.textPrimary)

                Text(subtitleForCurrentSegment)
                    .font(.system(size: 14))
                    .foregroundStyle(CineColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, CineSpacing.xl)
            }

            PrimaryCineButton(title: "Discover Movies", icon: "sparkles") {
                onExploreTapped?()
            }
            .padding(.top, CineSpacing.s)
        }
    }

    private var iconForCurrentSegment: String {
        switch viewModel.selectedSegment {
        case .watched: return "checkmark.circle"
        case .favorites: return "heart.slash"
        case .reviews: return "square.and.pencil"
        }
    }

    private var titleForCurrentSegment: String {
        switch viewModel.selectedSegment {
        case .watched: return "No Watched Movies Yet"
        case .favorites: return "No Favorites Added"
        case .reviews: return "No Personal Reviews Yet"
        }
    }

    private var subtitleForCurrentSegment: String {
        switch viewModel.selectedSegment {
        case .watched: return "Mark movies as watched from any movie detail page to track your viewing history."
        case .favorites: return "Tap the heart icon on any movie to save it to your personal favorites."
        case .reviews: return "Log your personal star ratings and notes on any movie page."
        }
    }
}
