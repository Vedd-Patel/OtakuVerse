//
//  FavoritesView.swift
//  AnimeChat
//
//  Created on 2025
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var showingClearAlert = false
    
    var body: some View {
        NavigationView {
            Group {
                if favoritesManager.favorites.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No Favorites Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("Add anime to your favorites by tapping the heart icon in chat or discover tab")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(favoritesManager.favorites) { anime in
                                FavoriteAnimeCard(anime: anime)
                                    .environmentObject(favoritesManager)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Favorites")
            .toolbar {
                if !favoritesManager.favorites.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear All") {
                            showingClearAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .alert("Clear All Favorites", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    withAnimation(.easeInOut) {
                        favoritesManager.clearAllFavorites()
                    }
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
}

struct FavoriteAnimeCard: View {
    let anime: AnimeData
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Image
            AsyncImage(url: URL(string: anime.images.jpg.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Title
            Text(anime.title)
                .font(.headline)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Rating and type
            HStack {
                if let score = anime.score {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(String(format: "%.1f", score))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        favoritesManager.removeFavorite(anime)
                    }
                }) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }
            }
            
            // Type and episodes
            HStack {
                if let type = anime.type {
                    Text(type)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }
                
                if let episodes = anime.episodes {
                    Text("\(episodes) ep")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .onTapGesture {
            showingDetails = true
        }
        .sheet(isPresented: $showingDetails) {
            AnimeDetailSheet(anime: anime)
                .environmentObject(favoritesManager)
        }
    }
}

struct AnimeDetailSheet: View {
    let anime: AnimeData
    @EnvironmentObject var favoritesManager: FavoritesManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Hero section with image and basic info
                    HStack(spacing: 16) {
                        AsyncImage(url: URL(string: anime.images.jpg.largeImageUrl ?? anime.images.jpg.imageUrl ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                )
                        }
                        .frame(width: 120, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(anime.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            if let englishTitle = anime.titleEnglish, englishTitle != anime.title {
                                Text(englishTitle)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let score = anime.score {
                                HStack(spacing: 4) {
                                    ForEach(0..<5) { star in
                                        Image(systemName: star < Int(score/2) ? "star.fill" : "star")
                                            .foregroundColor(.yellow)
                                    }
                                    Text(String(format: "%.1f", score))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                            }
                            
                            HStack {
                                if let type = anime.type {
                                    Text(type)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .clipShape(Capsule())
                                }
                                
                                if let episodes = anime.episodes {
                                    Text("\(episodes) episodes")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    
                    // Synopsis
                    if let synopsis = anime.synopsis {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Synopsis")
                                .font(.headline)
                            
                            Text(synopsis)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    // Genres
                    if let genres = anime.genres, !genres.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Genres")
                                .font(.headline)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(genres) { genre in
                                    Text(genre.name)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.gray.opacity(0.2))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    
                    // Additional Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Details")
                            .font(.headline)
                        
                        if let status = anime.status {
                            DetailRow(label: "Status", value: status)
                        }
                        
                        if let duration = anime.duration {
                            DetailRow(label: "Duration", value: duration)
                        }
                        
                        if let rating = anime.rating {
                            DetailRow(label: "Rating", value: rating)
                        }
                        
                        if let studios = anime.studios, !studios.isEmpty {
                            DetailRow(label: "Studio", value: studios.map { $0.name }.joined(separator: ", "))
                        }
                        
                        if let members = anime.members {
                            DetailRow(label: "Members", value: NumberFormatter.localizedString(from: NSNumber(value: members), number: .decimal))
                        }
                        
                        if let favorites = anime.favorites {
                            DetailRow(label: "Favorites", value: NumberFormatter.localizedString(from: NSNumber(value: favorites), number: .decimal))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Anime Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            favoritesManager.toggleFavorite(anime)
                        }
                    }) {
                        Image(systemName: favoritesManager.isFavorite(anime) ? "heart.fill" : "heart")
                            .foregroundColor(favoritesManager.isFavorite(anime) ? .red : .gray)
                    }
                }
            }
        }
    }
}
