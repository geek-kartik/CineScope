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
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            debouncer.cancel()
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
            await self?.performSearch(query: trimmed, page: 1)
        }
    }

    public func handleGenreChange() {
        if let genre = selectedGenre {
            loadGenreMovies(genreId: genre.id)
        } else if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            handleQueryChange()
        } else {
            searchResults = []
        }
    }

    public func loadMore() {
        guard !isLoading && !isLoadingMore && currentPage < totalPages else { return }
        isLoadingMore = true
        let nextPage = currentPage + 1

        Task {
            do {
                if let genre = selectedGenre, query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    let result = try await movieRepository.getMoviesByGenre(genreId: genre.id, page: nextPage)
                    self.searchResults.append(contentsOf: result.results)
                    self.currentPage = result.page
                    self.totalPages = result.totalPages
                } else {
                    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else {
                        isLoadingMore = false
                        return
                    }
                    let result = try await movieRepository.searchMovies(query: trimmed, page: nextPage)
                    self.searchResults.append(contentsOf: result.results)
                    self.currentPage = result.page
                    self.totalPages = result.totalPages
                }
                self.isLoadingMore = false
            } catch {
                self.isLoadingMore = false
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

    private func performSearch(query: String, page: Int) async {
        do {
            let result = try await movieRepository.searchMovies(query: query, page: page)
            self.searchResults = result.results
            self.currentPage = result.page
            self.totalPages = result.totalPages
            self.isLoading = false
            self.addRecentSearch(query)
        } catch let apiErr as APIError {
            self.isLoading = false
            if case .cancelled = apiErr { return }
            self.errorMessage = apiErr.localizedDescription
        } catch {
            self.isLoading = false
            self.errorMessage = error.localizedDescription
        }
    }

    private func loadGenreMovies(genreId: Int) {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let result = try await movieRepository.getMoviesByGenre(genreId: genreId, page: 1)
                self.searchResults = result.results
                self.currentPage = result.page
                self.totalPages = result.totalPages
                self.isLoading = false
            } catch {
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
