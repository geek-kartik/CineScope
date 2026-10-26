//
//  CineScopeApp.swift
//  CineScope
//

import SwiftUI
import SwiftData

@main
struct CineScopeApp: App {
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SavedMovieItem.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        configureCinematicAppearance()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }

    private func configureCinematicAppearance() {
        // Tab bar appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(CineColors.backgroundPrimary)
        tabAppearance.shadowColor = UIColor(CineColors.surfaceBorder)

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        // Navigation bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(CineColors.backgroundPrimary)
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(CineColors.textPrimary)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(CineColors.textPrimary)
        ]
        navAppearance.shadowColor = UIColor(CineColors.surfaceBorder)

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }
}
