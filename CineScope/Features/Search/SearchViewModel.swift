//
//  SearchViewModel.swift
//  CineScope
//

import Foundation
import Observation

@Observable
@MainActor
public final class SearchViewModel {
    public var query: String = "" {
        didSet {
            handleQueryChange()
        }
    }

    public var selectedGenre: Genre? = nil {
        didSet {
            handleGenreChange()
        }
    }

    public var searchResults: [Movie] = []
    public var trendingSuggestions: [Movie] = []
    public var recentSearches: [String] = []

    public var isLoading: Bool = false
    public var isLoadingMore: Bool = false
    public var errorMessage: String? = nil

    private var currentPage: Int = 1
    private var totalPages: Int = 1
    private var searchTask: Task<Void, Never>?
    private let debouncer = Debouncer(delay: 0.35)
    private let movieRepository: MovieRepositoryProtocol
    private let recentSearchesKey = "cinescope_recent_searches"

    public init(movieRepository: MovieRepositoryProtocol = MovieRepository.shared) {
        self.movieRepository = movieRepository
        loadRecentSearches()
    }

    public func loadSuggestions() async {
        guard trendingSuggestions.isEmpty else { return }
        do {
            let result = try await movieRepository.getPopular(page: 1)
            trendingSuggestions = Array(result.results.prefix(8))
        } catch {
            // Optional suggestions fallback gracefully
        }
    }

    public func handleQueryChange() {
        cancelActiveSearch()

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            if let genre = selectedGenre {
                loadGenreMovies(genreId: genre.id)
            } else {
                searchResults = []
                isLoading = false
            }
            return
        }

        isLoading = true
        errorMessage = nil
        debouncer.debounce { [weak self] in
            guard let self else { return }
            await self.scheduleSearch(query: trimmed)
        }
    }

    public func handleGenreChange() {
        if let genre = selectedGenre {
            loadGenreMovies(genreId: genre.id)
        } else if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            handleQueryChange()
        } else {
            cancelActiveSearch()
            searchResults = []
            isLoading = false
        }
    }

    public func cancelActiveSearch() {
        debouncer.cancel()
        searchTask?.cancel()
        searchTask = nil
        isLoading = false
        isLoadingMore = false
    }

    public func shouldLoadMore(after movie: Movie) -> Bool {
        guard !isLoading, !isLoadingMore, currentPage < totalPages else { return false }
        guard let index = searchResults.firstIndex(where: { $0.id == movie.id }) else {
            return false
        }
        return index >= max(0, searchResults.count - 4)
    }

    public func loadMore() {
        guard !isLoading && !isLoadingMore && currentPage < totalPages else { return }

        let nextPage = currentPage + 1
        let genre = selectedGenre
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)

        if genre == nil && trimmed.isEmpty {
            return
        }

        isLoadingMore = true
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }

            do {
                let result: PageResult<Movie>
                if let genre, trimmed.isEmpty {
                    result = try await self.movieRepository.getMoviesByGenre(genreId: genre.id, page: nextPage)
                } else {
                    result = try await self.movieRepository.searchMovies(query: trimmed, page: nextPage)
                }

                guard !Task.isCancelled else { return }
                let existingIDs = Set(self.searchResults.map(\.id))
                let newResults = result.results.filter { !existingIDs.contains($0.id) }
                self.searchResults.append(contentsOf: newResults)
                self.currentPage = result.page
                self.totalPages = result.totalPages
                self.isLoadingMore = false
            } catch let apiError as APIError {
                self.isLoadingMore = false
                guard !Task.isCancelled, apiError != .cancelled else { return }
                self.errorMessage = apiError.localizedDescription
            } catch {
                self.isLoadingMore = false
                guard !Task.isCancelled else { return }
                self.errorMessage = error.localizedDescription
            }
        }
    }

    public func selectRecentSearch(_ term: String) {
        query = term
    }

    public func removeRecentSearch(_ term: String) {
        recentSearches.removeAll { $0.caseInsensitiveCompare(term) == .orderedSame }
        saveRecentSearches()
    }

    public func clearAllRecentSearches() {
        recentSearches.removeAll()
        saveRecentSearches()
    }

    // MARK: - Private

    private func scheduleSearch(query: String) async {
        searchTask?.cancel()
        let task = Task { [weak self] in
            guard let self else { return }
            await self.performSearch(query: query, page: 1)
        }
        searchTask = task
        await task.value
    }

    private func performSearch(query: String, page: Int) async {
        do {
            let result = try await movieRepository.searchMovies(query: query, page: page)
            guard !Task.isCancelled else { return }
            self.searchResults = result.results
            self.currentPage = result.page
            self.totalPages = result.totalPages
            self.isLoading = false
            self.addRecentSearch(query)
        } catch let apiErr as APIError {
            guard !Task.isCancelled, apiErr != .cancelled else { return }
            self.isLoading = false
            self.errorMessage = apiErr.localizedDescription
        } catch {
            guard !Task.isCancelled else { return }
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }

    private func loadGenreMovies(genreId: Int) {
        cancelActiveSearch()
        isLoading = true
        errorMessage = nil
        searchTask = Task { [weak self] in
            guard let self else { return }

            do {
                let result = try await self.movieRepository.getMoviesByGenre(genreId: genreId, page: 1)
                guard !Task.isCancelled else { return }
                self.searchResults = result.results
                self.currentPage = result.page
                self.totalPages = result.totalPages
                self.isLoading = false
            } catch let apiErr as APIError {
                guard !Task.isCancelled, apiErr != .cancelled else { return }
                self.isLoading = false
                self.errorMessage = apiErr.localizedDescription
            } catch {
                guard !Task.isCancelled else { return }
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func addRecentSearch(_ term: String) {
        let clean = term.trimmingCharacters(in: .whitespacesAndNewlines)
        guard clean.count >= 2 else { return }
        var list = recentSearches.filter { $0.caseInsensitiveCompare(clean) != .orderedSame }
        list.insert(clean, at: 0)
        recentSearches = Array(list.prefix(10))
        saveRecentSearches()
    }

    private func loadRecentSearches() {
        if let stored = UserDefaults.standard.stringArray(forKey: recentSearchesKey) {
            recentSearches = stored
        }
    }

    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }
}
