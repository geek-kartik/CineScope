//
//  AppRouteView.swift
//  CineScope
//

import SwiftUI
import SwiftData

public struct AppRouteView: View {
    public let route: AppRoute

    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext

    public init(route: AppRoute) {
        self.route = route
    }

    public var body: some View {
        switch route {
        case .movie(let id, let movie):
            MovieDetailsView(
                movieId: id,
                initialMovie: movie,
                userMovieRepository: UserMovieRepository(context: modelContext)
            ) { selectedMovie in
                router.push(.movie(id: selectedMovie.id, movie: selectedMovie))
            }

        case .collection(let type):
            MovieCollectionGridView(collectionType: type) { selectedMovie in
                router.push(.movie(id: selectedMovie.id, movie: selectedMovie))
            }
        }
    }
}
