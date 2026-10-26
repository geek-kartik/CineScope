//
//  MovieCollectionGridView.swift
//  CineScope
//

import SwiftUI

public enum CollectionType: String, Identifiable, CaseIterable {
    case trending = "Trending Today"
    case nowPlaying = "Now Playing"
    case topRated = "Top Rated All-Time"
    case popular = "Popular Worldwide"
    case upcoming = "Upcoming Releases"

    public var id: String { rawValue }
}

public struct MovieCollectionGridView: View {
    public let collectionType: CollectionType
    public let repository: MovieRepositoryProtocol
    public let onMovieSelected: (Movie) -> Void

    @State private var movies: [Movie] = []
    @State private var page: Int = 1
    @State private var totalPages: Int = 1
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    private let columns = [
        GridItem(.flexible(), spacing: CineSpacing.m),
        GridItem(.flexible(), spacing: CineSpacing.m)
    ]

    public init(
        collectionType: CollectionType,
        repository: MovieRepositoryProtocol = MovieRepository.shared,
        onMovieSelected: @escaping (Movie) -> Void
    ) {
        self.collectionType = collectionType
        self.repository = repository
        self.onMovieSelected = onMovieSelected
    }

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: CineSpacing.l) {
                ForEach(Array(movies.enumerated()), id: \.element.id) { index, movie in
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
                        if movie.id == movies.last?.id {
                            loadMore()
                        }
                    }
                }
            }
            .padding(CineSpacing.l)

            if isLoading {
                ProgressView()
                    .tint(CineColors.crimson)
                    .padding()
            }
        }
        .background(CineColors.backgroundPrimary.ignoresSafeArea())
        .navigationTitle(collectionType.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if movies.isEmpty {
                await loadInitial()
            }
        }
    }

    private func loadInitial() async {
        page = 1
        isLoading = true
        errorMessage = nil
        do {
            let result = try await fetchPage(1)
            movies = result.results
            totalPages = result.totalPages
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func loadMore() {
        guard !isLoading && page < totalPages else { return }
        isLoading = true
        page += 1
        Task {
            do {
                let result = try await fetchPage(page)
                movies.append(contentsOf: result.results)
                isLoading = false
            } catch {
                isLoading = false
            }
        }
    }

    private func fetchPage(_ p: Int) async throws -> PageResult<Movie> {
        switch collectionType {
        case .trending:
            return try await repository.getTrending(timeWindow: "day", page: p)
        case .nowPlaying:
            return try await repository.getNowPlaying(page: p)
        case .topRated:
            return try await repository.getTopRated(page: p)
        case .popular:
            return try await repository.getPopular(page: p)
        case .upcoming:
            return try await repository.getUpcoming(page: p)
        }
    }
}
