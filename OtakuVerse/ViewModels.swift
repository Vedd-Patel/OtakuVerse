//
//  ViewModels.swift
//  AnimeChat
//
//  Created on 2025
//

import Foundation
import SwiftUI

// MARK: - Chat View Model
@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var recentSearches: [RecentSearch] = []
    
    private let apiService = AnimeAPIService.shared
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadRecentSearches()
    }
    
    func addWelcomeMessage() {
        let welcomeMessage = ChatMessage(
            text: "Hello! I'm your anime assistant. Ask me about any anime, character, or get recommendations!\n\nTry saying:\n• \"Tell me about Naruto\"\n• \"Find anime with Luffy\"\n• \"Show me action anime\"\n• \"Random anime please\"",
            isUser: false
        )
        messages.append(welcomeMessage)
    }
    
    func processUserMessage(_ text: String) async {
        // Add user message
        let userMessage = ChatMessage(text: text, isUser: true)
        messages.append(userMessage)
        
        // Save to recent searches
        addToRecentSearches(text)
        
        // Process the message
        do {
            let intent = parseIntent(from: text)
            
            switch intent {
            case .animeSearch(let query):
                let results = try await apiService.searchAnime(query: query)
                await handleAnimeResults(results, query: query)
                
            case .characterSearch(let query):
                let results = try await apiService.searchCharacters(query: query)
                await handleCharacterResults(results, query: query)
                
            case .genreSearch(let genre):
                let results = try await apiService.searchAnimeByGenre(genre: genre)
                await handleAnimeResults(results, query: "anime in \(genre) genre")
                
            case .topAnime:
                let results = try await apiService.getTopAnime()
                await handleAnimeResults(results, query: "top anime")
                
            case .randomAnime:
                if let result = try await apiService.getRandomAnime() {
                    let response = ChatMessage(text: "Here's a random anime for you!", isUser: false, animeData: result)
                    messages.append(response)
                } else {
                    let errorMessage = ChatMessage(text: "Sorry, I couldn't get a random anime right now. Please try again.", isUser: false)
                    messages.append(errorMessage)
                }
                
            case .general(let query):
                let results = try await apiService.searchAnime(query: query)
                await handleAnimeResults(results, query: query)
            }
            
        } catch {
            let errorMessage = ChatMessage(
                text: "Sorry, I encountered an error: \(error.localizedDescription). Please try again.",
                isUser: false
            )
            messages.append(errorMessage)
        }
    }
    
    private func parseIntent(from text: String) -> SearchIntent {
        let lowercased = text.lowercased()
        
        // Random anime requests
        if lowercased.contains("random") || lowercased.contains("surprise") {
            return .randomAnime
        }
        
        // Top anime requests
        if lowercased.contains("top") || lowercased.contains("best") || lowercased.contains("highest rated") {
            return .topAnime
        }
        
        // Character search
        if lowercased.contains("character") || lowercased.contains("find anime with") || lowercased.contains("who is") {
            let query = extractQueryFromText(text, removing: ["character", "find anime with", "who is", "tell me about"])
            return .characterSearch(query)
        }
        
        // Genre search
        let genres = ["action", "adventure", "comedy", "drama", "fantasy", "horror", "mystery", "romance", "sci-fi", "thriller"]
        for genre in genres {
            if lowercased.contains(genre) {
                return .genreSearch(genre)
            }
        }
        
        // Anime search (default)
        let query = extractQueryFromText(text, removing: ["tell me about", "what is", "find", "show me", "search for"])
        if lowercased.contains("anime") || lowercased.contains("series") || lowercased.contains("show") {
            return .animeSearch(query)
        }
        
        return .general(query)
    }
    
    private func extractQueryFromText(_ text: String, removing phrases: [String]) -> String {
        var query = text
        for phrase in phrases {
            query = query.replacingOccurrences(of: phrase, with: "", options: .caseInsensitive)
        }
        return query.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func handleAnimeResults(_ results: [AnimeData], query: String) async {
        if results.isEmpty {
            let noResultsMessage = ChatMessage(
                text: "Sorry, I couldn't find any anime matching '\(query)'. Try a different search term!",
                isUser: false
            )
            messages.append(noResultsMessage)
        } else if results.count == 1 {
            let response = ChatMessage(
                text: "Here's what I found for '\(query)':",
                isUser: false,
                animeData: results.first
            )
            messages.append(response)
        } else {
            let response = ChatMessage(
                text: "I found \(results.count) anime matching '\(query)'. Here's the top result:",
                isUser: false,
                animeData: results.first
            )
            messages.append(response)
            
            // Add additional results
            for anime in results.prefix(3).dropFirst() {
                let additionalResponse = ChatMessage(text: "", isUser: false, animeData: anime)
                messages.append(additionalResponse)
            }
            
            if results.count > 3 {
                let moreResultsMessage = ChatMessage(
                    text: "And \(results.count - 3) more results! Try being more specific if you're looking for something particular.",
                    isUser: false
                )
                messages.append(moreResultsMessage)
            }
        }
    }
    
    private func handleCharacterResults(_ results: [CharacterData], query: String) async {
        if results.isEmpty {
            let noResultsMessage = ChatMessage(
                text: "Sorry, I couldn't find any characters matching '\(query)'. Try a different search term!",
                isUser: false
            )
            messages.append(noResultsMessage)
        } else {
            let character = results.first!
            let responseText = """
            I found the character '\(character.name)'!
            
            \(character.about ?? "No description available.")
            
            This character has \(character.favorites ?? 0) favorites on MyAnimeList.
            """
            
            let response = ChatMessage(text: responseText, isUser: false)
            messages.append(response)
        }
    }
    
    private func addToRecentSearches(_ query: String) {
        let search = RecentSearch(query: query)
        recentSearches.insert(search, at: 0)
        
        // Keep only the last 20 searches
        if recentSearches.count > 20 {
            recentSearches = Array(recentSearches.prefix(20))
        }
        
        saveRecentSearches()
    }
    
    private func loadRecentSearches() {
        if let data = userDefaults.data(forKey: "recentSearches"),
           let searches = try? JSONDecoder().decode([RecentSearch].self, from: data) {
            recentSearches = searches
        }
    }
    
    private func saveRecentSearches() {
        if let data = try? JSONEncoder().encode(recentSearches) {
            userDefaults.set(data, forKey: "recentSearches")
        }
    }
    
    func clearRecentSearches() {
        recentSearches.removeAll()
        userDefaults.removeObject(forKey: "recentSearches")
    }
    
    func repeatSearch(_ query: String) {
        Task {
            await processUserMessage(query)
        }
    }
}

// MARK: - Favorites Manager
@MainActor
class FavoritesManager: ObservableObject {
    @Published var favorites: [AnimeData] = []
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadFavorites()
    }
    
    func toggleFavorite(_ anime: AnimeData) {
        if isFavorite(anime) {
            removeFavorite(anime)
        } else {
            addFavorite(anime)
        }
    }
    
    func addFavorite(_ anime: AnimeData) {
        if !isFavorite(anime) {
            favorites.append(anime)
            saveFavorites()
        }
    }
    
    func removeFavorite(_ anime: AnimeData) {
        favorites.removeAll { $0.malId == anime.malId }
        saveFavorites()
    }
    
    func isFavorite(_ anime: AnimeData) -> Bool {
        favorites.contains { $0.malId == anime.malId }
    }
    
    func clearAllFavorites() {
        favorites.removeAll()
        saveFavorites()
    }
    
    private func loadFavorites() {
        if let data = userDefaults.data(forKey: "animeFavorites"),
           let savedFavorites = try? JSONDecoder().decode([AnimeData].self, from: data) {
            favorites = savedFavorites
        }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favorites) {
            userDefaults.set(data, forKey: "animeFavorites")
        }
    }
}

// MARK: - Theme Manager
@MainActor
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            userDefaults.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        self.isDarkMode = userDefaults.object(forKey: "isDarkMode") as? Bool ?? false
    }
    
    func toggleTheme() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDarkMode.toggle()
        }
    }
}

// MARK: - Random Anime View Model
@MainActor
class RandomAnimeViewModel: ObservableObject {
    @Published var currentAnime: AnimeData?
    @Published var isLoading = false
    @Published var error: String?
    
    private let apiService = AnimeAPIService.shared
    
    func getRandomAnime() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let anime = try await apiService.getRandomAnime()
                await MainActor.run {
                    self.currentAnime = anime
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Search Intent Enum
enum SearchIntent {
    case animeSearch(String)
    case characterSearch(String)
    case genreSearch(String)
    case topAnime
    case randomAnime
    case general(String)
}