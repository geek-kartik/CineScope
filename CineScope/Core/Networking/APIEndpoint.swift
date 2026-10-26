//
//  APIEndpoint.swift
//  CineScope
//

import Foundation

public enum APIEndpoint: Sendable {
    case trending(timeWindow: String = "day", page: Int = 1)
    case popular(page: Int = 1)
    case nowPlaying(page: Int = 1)
    case upcoming(page: Int = 1)
    case topRated(page: Int = 1)
    case movieDetails(id: Int)
    case credits(movieId: Int)
    case videos(movieId: Int)
    case recommendations(movieId: Int, page: Int = 1)
    case similar(movieId: Int, page: Int = 1)
    case search(query: String, page: Int = 1)
    case discoverByGenre(genreId: Int, sortBy: String = "popularity.desc", page: Int = 1)
    case genres
    case validateCredentials

    public var path: String {
        switch self {
        case .trending(let timeWindow, _):
            return "/trending/movie/\(timeWindow)"
        case .popular:
            return "/movie/popular"
        case .nowPlaying:
            return "/movie/now_playing"
        case .upcoming:
            return "/movie/upcoming"
        case .topRated:
            return "/movie/top_rated"
        case .movieDetails(let id):
            return "/movie/\(id)"
        case .credits(let movieId):
            return "/movie/\(movieId)/credits"
        case .videos(let movieId):
            return "/movie/\(movieId)/videos"
        case .recommendations(let movieId, _):
            return "/movie/\(movieId)/recommendations"
        case .similar(let movieId, _):
            return "/movie/\(movieId)/similar"
        case .search:
            return "/search/movie"
        case .discoverByGenre:
            return "/discover/movie"
        case .genres:
            return "/genre/movie/list"
        case .validateCredentials:
            return "/configuration"
        }
    }

    public var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "language", value: "en-US")
        ]

        switch self {
        case .trending(_, let page):
            if page > 1 { items.append(URLQueryItem(name: "page", value: "\(page)")) }
        case .popular(let page), .nowPlaying(let page), .upcoming(let page), .topRated(let page):
            items.append(URLQueryItem(name: "page", value: "\(page)"))
        case .movieDetails:
            items.append(URLQueryItem(name: "append_to_response", value: "credits,videos,recommendations,similar"))
        case .credits, .videos, .genres, .validateCredentials:
            break
        case .recommendations(_, let page), .similar(_, let page):
            items.append(URLQueryItem(name: "page", value: "\(page)"))
        case .search(let query, let page):
            items.append(URLQueryItem(name: "query", value: query))
            items.append(URLQueryItem(name: "page", value: "\(page)"))
            items.append(URLQueryItem(name: "include_adult", value: "false"))
        case .discoverByGenre(let genreId, let sortBy, let page):
            items.append(URLQueryItem(name: "with_genres", value: "\(genreId)"))
            items.append(URLQueryItem(name: "sort_by", value: sortBy))
            items.append(URLQueryItem(name: "page", value: "\(page)"))
            items.append(URLQueryItem(name: "include_adult", value: "false"))
        }

        return items
    }

    public var method: HTTPMethod {
        .get
    }

    public func urlRequest(baseURL: String = APIConfig.baseURLString, credential: String?) throws -> URLRequest {
        guard var components = URLComponents(string: baseURL + path) else {
            throw APIError.invalidURL
        }

        var allQueryItems = queryItems

        let isBearer: Bool
        if let cred = credential {
            isBearer = cred.count > 40 || cred.hasPrefix("eyJ")
            if !isBearer {
                allQueryItems.append(URLQueryItem(name: "api_key", value: cred))
            }
        } else {
            isBearer = false
        }

        components.queryItems = allQueryItems

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 15.0
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let cred = credential, isBearer {
            request.setValue("Bearer \(cred)", forHTTPHeaderField: "Authorization")
        }

        return request
    }
}
