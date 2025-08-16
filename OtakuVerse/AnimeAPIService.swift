//
//  AnimeAPIService.swift
//  AnimeChat
//
//  Created on 2025
//

import Foundation

class AnimeAPIService: ObservableObject {
    static let shared = AnimeAPIService()
    
    private let baseURL = "https://api.jikan.moe/v4"
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Search Functions
    
    func searchAnime(query: String) async throws -> [AnimeData] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/anime?q=\(encodedQuery)&limit=10"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 429 {
                throw APIError.rateLimited
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            let result = try JSONDecoder().decode(JikanAnimeResponse.self, from: data)
            return result.data ?? []
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        }
    }
    
    func searchCharacters(query: String) async throws -> [CharacterData] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/characters?q=\(encodedQuery)&limit=5"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 429 {
                throw APIError.rateLimited
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            let result = try JSONDecoder().decode(JikanCharacterResponse.self, from: data)
            return result.data ?? []
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        }
    }
    
    func getAnimeDetails(id: Int) async throws -> AnimeData? {
        let urlString = "\(baseURL)/anime/\(id)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 429 {
                throw APIError.rateLimited
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            let result = try JSONDecoder().decode(JikanSingleAnimeResponse.self, from: data)
            return result.data
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        }
    }
    
    func getTopAnime() async throws -> [AnimeData] {
        let urlString = "\(baseURL)/top/anime?limit=10"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 429 {
                throw APIError.rateLimited
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            let result = try JSONDecoder().decode(JikanAnimeResponse.self, from: data)
            return result.data ?? []
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        }
    }
    
    func getRandomAnime() async throws -> AnimeData? {
        let urlString = "\(baseURL)/random/anime"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 429 {
                throw APIError.rateLimited
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            let result = try JSONDecoder().decode(JikanSingleAnimeResponse.self, from: data)
            return result.data
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        }
    }
    
    func searchAnimeByGenre(genre: String) async throws -> [AnimeData] {
        let genreMap = [
            "action": "1",
            "adventure": "2",
            "comedy": "4",
            "drama": "8",
            "fantasy": "10",
            "horror": "14",
            "mystery": "7",
            "romance": "22",
            "sci-fi": "24",
            "thriller": "41"
        ]
        
        guard let genreId = genreMap[genre.lowercased()] else {
            return try await searchAnime(query: genre)
        }
        
        let urlString = "\(baseURL)/anime?genres=\(genreId)&limit=10"
        
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 429 {
                throw APIError.rateLimited
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        do {
            let result = try JSONDecoder().decode(JikanAnimeResponse.self, from: data)
            return result.data ?? []
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        }
    }
}

// MARK: - API Errors
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
    case rateLimited
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .decodingError:
            return "Failed to decode response"
        case .rateLimited:
            return "Rate limit exceeded. Please try again later."
        case .noData:
            return "No data found"
        }
    }
}