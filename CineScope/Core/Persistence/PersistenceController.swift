//
//  PersistenceController.swift
//  CineScope
//

import Foundation
import SwiftData

@MainActor
public final class PersistenceController {
    public static let shared = PersistenceController()

    public let container: ModelContainer

    public init(inMemory: Bool = false) {
        let schema = Schema([
            SavedMovieItem.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)

        do {
            self.container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
        }
    }

    public static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.mainContext

        let sample = SavedMovieItem(
            id: 550,
            title: "Fight Club",
            overview: "An insomniac office worker and a devil-may-care soap maker form an underground fight club that evolves into much more.",
            posterPath: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
            backdropPath: "/hZkgoQYus5vegHoetLkCJzb17zJ.jpg",
            releaseDate: "1999-10-15",
            voteAverage: 8.4,
            voteCount: 26000,
            runtime: 139,
            genresCSV: "Drama, Thriller",
            isWatchlist: true,
            isFavorite: true,
            isWatched: false
        )
        context.insert(sample)
        return controller
    }()
}
