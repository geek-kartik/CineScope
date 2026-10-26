//
//  MockData.swift
//  CineScopeTests
//

import Foundation
@testable import CineScope

public enum MockData {
    public static let sampleMovieJSON = """
    {
        "id": 550,
        "title": "Fight Club",
        "original_title": "Fight Club",
        "overview": "A ticking-time-bomb insomniac and a slippery soap salesman channel primal male aggression into a shocking new form of therapy.",
        "poster_path": "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
        "backdrop_path": "/hZkgoQYus5vegHoetLkCJzb17zJ.jpg",
        "release_date": "1999-10-15",
        "vote_average": 8.433,
        "vote_count": 26000,
        "popularity": 61.416,
        "genre_ids": [18, 53],
        "adult": false
    }
    """

    public static let samplePageResultJSON = """
    {
        "page": 1,
        "results": [
            {
                "id": 550,
                "title": "Fight Club",
                "overview": "A ticking-time-bomb insomniac...",
                "poster_path": "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
                "backdrop_path": "/hZkgoQYus5vegHoetLkCJzb17zJ.jpg",
                "release_date": "1999-10-15",
                "vote_average": 8.4,
                "vote_count": 26000,
                "genre_ids": [18, 53]
            },
            {
                "id": 680,
                "title": "Pulp Fiction",
                "overview": "A burger-loving hit man...",
                "poster_path": "/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg",
                "backdrop_path": "/suaEOtk1N1sgg2MTM7oZd2cfVp3.jpg",
                "release_date": "1994-09-10",
                "vote_average": 8.5,
                "vote_count": 27000,
                "genre_ids": [53, 80]
            }
        ],
        "total_pages": 5,
        "total_results": 10
    }
    """

    public static let sampleDetailJSON = """
    {
        "id": 550,
        "title": "Fight Club",
        "original_title": "Fight Club",
        "tagline": "Mischief. Mayhem. Soap.",
        "overview": "A ticking-time-bomb insomniac and a slippery soap salesman...",
        "poster_path": "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
        "backdrop_path": "/hZkgoQYus5vegHoetLkCJzb17zJ.jpg",
        "release_date": "1999-10-15",
        "runtime": 139,
        "vote_average": 8.4,
        "vote_count": 26000,
        "status": "Released",
        "budget": 63000000,
        "revenue": 100853753,
        "original_language": "en",
        "genres": [
            {"id": 18, "name": "Drama"},
            {"id": 53, "name": "Thriller"}
        ],
        "production_companies": [
            {"id": 508, "name": "Regency Enterprises", "origin_country": "US"}
        ],
        "credits": {
            "cast": [
                {
                    "id": 819,
                    "name": "Edward Norton",
                    "character": "The Narrator",
                    "profile_path": "/5XBzD5WuTyVQZeS4VI25LnijdII.jpg",
                    "order": 0
                },
                {
                    "id": 287,
                    "name": "Brad Pitt",
                    "character": "Tyler Durden",
                    "profile_path": "/cckcYc2v0yh1tc9QjRelptsqpHW.jpg",
                    "order": 1
                }
            ],
            "crew": [
                {
                    "id": 7467,
                    "name": "David Fincher",
                    "job": "Director",
                    "department": "Directing"
                }
            ]
        },
        "videos": {
            "results": [
                {
                    "id": "5c92c31c0e0a267cd516834f",
                    "key": "O1bDmxUgkAM",
                    "name": "Official 10th Anniversary Trailer",
                    "site": "YouTube",
                    "type": "Trailer",
                    "official": true
                }
            ]
        }
    }
    """

    public static let sampleMovie = Movie(
        id: 550,
        title: "Fight Club",
        overview: "A ticking-time-bomb insomniac...",
        posterPath: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg",
        backdropPath: "/hZkgoQYus5vegHoetLkCJzb17zJ.jpg",
        releaseDate: "1999-10-15",
        voteAverage: 8.4,
        voteCount: 26000,
        genreIds: [18, 53]
    )

    public static let sampleMovie2 = Movie(
        id: 680,
        title: "Pulp Fiction",
        overview: "A burger-loving hit man...",
        posterPath: "/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg",
        backdropPath: "/suaEOtk1N1sgg2MTM7oZd2cfVp3.jpg",
        releaseDate: "1994-09-10",
        voteAverage: 8.5,
        voteCount: 27000,
        genreIds: [53, 80]
    )
}
