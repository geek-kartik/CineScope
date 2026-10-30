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
        GridItem(.flexible(), spacing: CineSpacing.m),
        GridItem(.flexible(), spacing: CineSpacing.m)
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
                ProgressView()
                    .tint(CineColors.crimson)
                    .frame(maxWidth: .infinity, minHeight: 240)
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
                                rank: collectionType == .topRated ? (index + 1) : nil,
                                width: (UIScreen.main.bounds.width - 48) / 2,
                                height: ((UIScreen.main.bounds.width - 48) / 2) * 1.5
                            )
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            Task {
                                await viewModel.loadMoreIfNeeded(at: index)
                            }
                        }
                    }
                }
                .padding(CineSpacing.l)

                if viewModel.isLoadingMore {
                    ProgressView()
                        .tint(CineColors.crimson)
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    retryFooter(message: errorMessage)
                }
            }
        }
        .background(CineColors.backgroundPrimary.ignoresSafeArea())
        .navigationTitle(collectionType.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadInitialIfNeeded()
        }
    }

    private func errorState(message: String) -> some View {
        VStack(spacing: CineSpacing.m) {
            Image(systemName: "wifi.exclamationmark")
                .font(.largeTitle)
                .foregroundStyle(CineColors.textSecondary)
            Text(message)
                .font(CineTypography.body)
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
                .font(CineTypography.caption)
                .foregroundStyle(CineColors.textSecondary)
            Button("Try Again") {
                Task {
                    await viewModel.retry()
                }
            }
            .font(CineTypography.caption)
            .tint(CineColors.crimson)
        }
        .padding()
    }
}
