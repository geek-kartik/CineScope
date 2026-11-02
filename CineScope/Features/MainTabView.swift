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

    @State private var router = AppRouter()

    private var userMovieRepository: UserMovieRepositoryProtocol {
        UserMovieRepository(context: modelContext)
    }

    public init() {}

    public var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            HomeView(userMovieRepository: userMovieRepository)
                .tabItem {
                    Label("Discover", systemImage: "house.fill")
                }
                .tag(AppTab.discover)

            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(AppTab.search)

            WatchlistView(
                userMovieRepository: userMovieRepository,
                onExploreTapped: {
                    router.selectedTab = .discover
                }
            )
            .tabItem {
                Label("Watchlist", systemImage: "bookmark.fill")
            }
            .badge(watchlistItems.count > 0 ? watchlistItems.count : 0)
            .tag(AppTab.watchlist)

            LibraryView(
                userMovieRepository: userMovieRepository,
                onExploreTapped: {
                    router.selectedTab = .discover
                }
            )
            .tabItem {
                Label("Library", systemImage: "film.stack.fill")
            }
            .tag(AppTab.library)

            SettingsView(userMovieRepository: userMovieRepository)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(AppTab.settings)
        }
        .tint(CineColors.crimson)
        .environment(router)
        .onOpenURL { url in
            router.handle(url)
        }
    }
}
