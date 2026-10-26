//
//  MainTabView.swift
//  CineScope
//

import SwiftUI
import SwiftData

public struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<SavedMovieItem> { $0.isWatchlist })
    private var watchlistItems: [SavedMovieItem]

    @State private var selectedTab: Int = 0

    private var userMovieRepository: UserMovieRepositoryProtocol {
        UserMovieRepository(context: modelContext)
    }

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(userMovieRepository: userMovieRepository)
                .tabItem {
                    Label("Discover", systemImage: "house.fill")
                }
                .tag(0)

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)

            WatchlistView(
                userMovieRepository: userMovieRepository,
                onExploreTapped: {
                    selectedTab = 0
                }
            )
            .tabItem {
                Label("Watchlist", systemImage: "bookmark.fill")
            }
            .badge(watchlistItems.count > 0 ? watchlistItems.count : 0)
            .tag(2)

            LibraryView(
                userMovieRepository: userMovieRepository,
                onExploreTapped: {
                    selectedTab = 0
                }
            )
            .tabItem {
                Label("Library", systemImage: "film.stack.fill")
            }
            .tag(3)

            SettingsView(userMovieRepository: userMovieRepository)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(CineColors.crimson)
    }
}
