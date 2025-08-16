//
//  Models.swift
//  AnimeChat
//
//  Created on 2025
//

import Foundation

// MARK: - Chat Models
struct ChatMessage: Identifiable, Codable {
    var id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
    var animeData: AnimeData?
    
    init(text: String, isUser: Bool, animeData: AnimeData? = nil) {
        self.text = text
        self.isUser = isUser
        self.timestamp = Date()
        self.animeData = animeData
    }
}

// MARK: - Jikan API Models
struct JikanAnimeResponse: Codable {
    let data: [AnimeData]?
    let pagination: Pagination?
}

struct JikanSingleAnimeResponse: Codable {
    let data: AnimeData?
}

struct JikanCharacterResponse: Codable {
    let data: [CharacterData]?
    let pagination: Pagination?
}

struct AnimeData: Identifiable, Codable, Hashable {
    let malId: Int
    let images: AnimeImages
    let title: String
    let titleEnglish: String?
    let titleJapanese: String?
    let synopsis: String?
    let type: String?
    let episodes: Int?
    let status: String?
    let aired: AiredDates?
    let duration: String?
    let rating: String?
    let score: Double?
    let scoredBy: Int?
    let popularity: Int?
    let members: Int?
    let favorites: Int?
    let genres: [Genre]?
    let studios: [Studio]?
    let year: Int?
    let season: String?
    
    var id: Int { malId }
    
    enum CodingKeys: String, CodingKey {
        case malId = "mal_id"
        case images, title, synopsis, type, episodes, status, aired, duration, rating, score, popularity, members, favorites, genres, studios, year, season
        case titleEnglish = "title_english"
        case titleJapanese = "title_japanese"
        case scoredBy = "scored_by"
    }
    
    // Custom hash and equality for Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(malId)
    }
    
    static func == (lhs: AnimeData, rhs: AnimeData) -> Bool {
        lhs.malId == rhs.malId
    }
}

struct AnimeImages: Codable {
    let jpg: ImageUrls
    let webp: ImageUrls?
}

struct ImageUrls: Codable {
    let imageUrl: String?
    let smallImageUrl: String?
    let largeImageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case imageUrl = "image_url"
        case smallImageUrl = "small_image_url"
        case largeImageUrl = "large_image_url"
    }
}

struct AiredDates: Codable {
    let from: String?
    let to: String?
    let prop: DateProp?
}

struct DateProp: Codable {
    let from: DateInfo?
    let to: DateInfo?
}

struct DateInfo: Codable {
    let day: Int?
    let month: Int?
    let year: Int?
}

struct Genre: Codable, Identifiable {
    let malId: Int
    let type: String
    let name: String
    let url: String
    
    var id: Int { malId }
    
    enum CodingKeys: String, CodingKey {
        case malId = "mal_id"
        case type, name, url
    }
}

struct Studio: Codable, Identifiable {
    let malId: Int
    let type: String
    let name: String
    let url: String
    
    var id: Int { malId }
    
    enum CodingKeys: String, CodingKey {
        case malId = "mal_id"
        case type, name, url
    }
}

struct CharacterData: Codable, Identifiable {
    let malId: Int
    let images: CharacterImages
    let name: String
    let nameKanji: String?
    let nicknames: [String]?
    let about: String?
    let favorites: Int?
    
    var id: Int { malId }
    
    enum CodingKeys: String, CodingKey {
        case malId = "mal_id"
        case images, name, nicknames, about, favorites
        case nameKanji = "name_kanji"
    }
}

struct CharacterImages: Codable {
    let jpg: CharacterImageUrls
    let webp: CharacterImageUrls?
}

struct CharacterImageUrls: Codable {
    let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case imageUrl = "image_url"
    }
}

struct Pagination: Codable {
    let lastVisiblePage: Int?
    let hasNextPage: Bool?
    let currentPage: Int?
    let items: PaginationItems?
    
    enum CodingKeys: String, CodingKey {
        case lastVisiblePage = "last_visible_page"
        case hasNextPage = "has_next_page"
        case currentPage = "current_page"
        case items
    }
}

struct PaginationItems: Codable {
    let count: Int?
    let total: Int?
    let perPage: Int?
    
    enum CodingKeys: String, CodingKey {
        case count, total
        case perPage = "per_page"
    }
}

// MARK: - Recent Search Model
struct RecentSearch: Identifiable, Codable {
    var id = UUID()
    let query: String
    let timestamp: Date
    
    init(query: String) {
        self.query = query
        self.timestamp = Date()
    }
}
