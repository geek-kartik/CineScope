//
//  Credits.swift
//  CineScope
//

import Foundation

nonisolated public struct CastMember: Codable, Identifiable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let originalName: String?
    public let character: String?
    public let profilePath: String?
    public let order: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case originalName = "original_name"
        case character
        case profilePath = "profile_path"
        case order
    }

    public init(
        id: Int,
        name: String,
        originalName: String? = nil,
        character: String? = nil,
        profilePath: String? = nil,
        order: Int? = nil
    ) {
        self.id = id
        self.name = name
        self.originalName = originalName
        self.character = character
        self.profilePath = profilePath
        self.order = order
    }

    public func profileURL(size: String = "w185") -> URL? {
        guard let profilePath = profilePath, !profilePath.isEmpty else { return nil }
        let cleanPath = profilePath.hasPrefix("/") ? profilePath : "/\(profilePath)"
        return URL(string: "https://image.tmdb.org/t/p/\(size)\(cleanPath)")
    }
}

nonisolated public struct CrewMember: Codable, Identifiable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let originalName: String?
    public let job: String?
    public let department: String?
    public let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case originalName = "original_name"
        case job
        case department
        case profilePath = "profile_path"
    }

    public init(
        id: Int,
        name: String,
        originalName: String? = nil,
        job: String? = nil,
        department: String? = nil,
        profilePath: String? = nil
    ) {
        self.id = id
        self.name = name
        self.originalName = originalName
        self.job = job
        self.department = department
        self.profilePath = profilePath
    }
}

nonisolated public struct Credits: Codable, Sendable {
    public let id: Int?
    public let cast: [CastMember]
    public let crew: [CrewMember]

    public init(id: Int? = nil, cast: [CastMember] = [], crew: [CrewMember] = []) {
        self.id = id
        self.cast = cast
        self.crew = crew
    }

    public var director: CrewMember? {
        crew.first { $0.job?.caseInsensitiveCompare("Director") == .orderedSame }
    }

    public var writers: [CrewMember] {
        crew.filter {
            guard let job = $0.job?.lowercased() else { return false }
            return job.contains("writer") || job.contains("screenplay")
        }
    }
}
