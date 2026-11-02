//
//  MovieCollectionGridView.swift
//  CineScope
//

import SwiftUI

public struct MovieCollectionGridView: View {
    public let collectionType: CollectionType
    public let onMovieSelected: (Movie) -> Void

    @State private var viewModel: MovieCollectionViewModel

    private let columns = [
        GridItem(.adaptive(minimum: 140, maximum: 220), spacing: CineSpacing.m)
    ]

    public init(
        collectionType: CollectionType,
        repository: MovieRepositoryProtocol = MovieRepository.shared,
        prefetchThreshold: Int = 4,
        onMovieSelected: @escaping (Movie) -> Void
    ) {
        self.collectionType = collectionType
        self.onMovieSelected = onMovieSelected
        _viewModel = State(initialValue: MovieCollectionViewModel(
            collectionType: collectionType,
            repository: repository,
            prefetchThreshold: prefetchThreshold
        ))
    }

    public var body: some View {
        ScrollView {
            if viewModel.isLoading && viewModel.movies.isEmpty {
                loadingState
            } else if let errorMessage = viewModel.errorMessage, viewModel.movies.isEmpty {
                errorState(message: errorMessage)
            } else {
                LazyVGrid(columns: columns, spacing: CineSpacing.l) {
                    ForEach(Array(viewModel.movies.enumerated()), id: \.element.id) { index, movie in
                        Button {
                            onMovieSelected(movie)
                        } label: {
                            MovieCardView(
                                movie: movie,
                                rank: collectionType == .topRated ? (index + 1) : nil
                            )
                        }
                        .buttonStyle(.plain)
                        .task {
                            await viewModel.loadMoreIfNeeded(at: index)
                        }
                    }
                }
                .padding(CineSpacing.l)

                if viewModel.isLoadingMore {
                    ProgressView()
                        .tint(CineColors.crimson)
                        .padding(.bottom, CineSpacing.l)
                } else if let errorMessage = viewModel.errorMessage {
                    retryFooter(message: errorMessage)
                } else if !viewModel.hasMorePages && !viewModel.movies.isEmpty {
                    endOfListFooter
                }
            }
        }
        .background(CineColors.backgroundPrimary.ignoresSafeArea())
        .navigationTitle(collectionType.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await viewModel.refresh()
        }
        .task {
            await viewModel.loadInitialIfNeeded()
        }
    }

    private var loadingState: some View {
        LazyVGrid(columns: columns, spacing: CineSpacing.l) {
            ForEach(0..<6, id: \.self) { _ in
                RoundedRectangle(cornerRadius: CineRadius.m)
                    .fill(CineColors.backgroundElevated)
                    .aspectRatio(2.0 / 3.0, contentMode: .fit)
                    .shimmering()
            }
        }
        .padding(CineSpacing.l)
        .accessibilityLabel("Loading movies")
    }

    private func errorState(message: String) -> some View {
        VStack(spacing: CineSpacing.m) {
            Image(systemName: "wifi.exclamationmark")
                .font(.largeTitle)
                .foregroundStyle(CineColors.textSecondary)
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(CineColors.textSecondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                Task {
                    await viewModel.retry()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(CineColors.crimson)
        }
        .padding(CineSpacing.xl)
        .frame(maxWidth: .infinity)
    }

    private func retryFooter(message: String) -> some View {
        VStack(spacing: CineSpacing.s) {
            Text(message)
                .font(.system(size: 12))
                .foregroundStyle(CineColors.textSecondary)
            Button("Try Again") {
                Task {
                    await viewModel.retry()
                }
            }
            .font(.system(size: 13, weight: .semibold))
            .tint(CineColors.crimson)
        }
        .padding(.bottom, CineSpacing.l)
    }

    private var endOfListFooter: some View {
        Text("You've reached the end")
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(CineColors.textTertiary)
            .padding(.bottom, CineSpacing.l)
    }
}
