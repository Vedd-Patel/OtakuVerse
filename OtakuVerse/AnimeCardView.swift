//
//  AnimeCardView.swift
//  AnimeChat
//
//  Created on 2025
//

import SwiftUI

struct AnimeCardView: View {
    let anime: AnimeData
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with image and title
            HStack(spacing: 12) {
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
                .frame(width: 80, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(anime.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    if let englishTitle = anime.titleEnglish, englishTitle != anime.title {
                        Text(englishTitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
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
                        
                        if let type = anime.type {
                            Text(type)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .clipShape(Capsule())
                        }
                    }
                    
                    if let episodes = anime.episodes {
                        Text("\(episodes) episodes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            
            // Synopsis
            if let synopsis = anime.synopsis {
                Text(synopsis)
                    .font(.body)
                    .lineLimit(showingDetails ? nil : 3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Genres
            if let genres = anime.genres, !genres.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(genres.prefix(5)) { genre in
                            Text(genre.name)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.primary)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
            
            // Action buttons
            HStack(spacing: 16) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        favoritesManager.toggleFavorite(anime)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: favoritesManager.isFavorite(anime) ? "heart.fill" : "heart")
                            .foregroundColor(favoritesManager.isFavorite(anime) ? .red : .gray)
                        Text(favoritesManager.isFavorite(anime) ? "Favorited" : "Favorite")
                            .font(.caption)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingDetails.toggle()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: showingDetails ? "chevron.up" : "chevron.down")
                        Text(showingDetails ? "Less Info" : "More Info")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(action: shareAnime) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Additional details when expanded
            if showingDetails {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    
                    if let status = anime.status {
                        DetailRow(label: "Status", value: status)
                    }
                    
                    if let aired = anime.aired?.from {
                        DetailRow(label: "Aired", value: formatDate(aired))
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
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func shareAnime() {
        let text = """
        Check out this anime: \(anime.title)
        
        \(anime.synopsis ?? "")
        
        Rating: \(anime.score.map { String(format: "%.1f", $0) } ?? "N/A")/10
        """
        
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 60, alignment: .leading)
            
            Text(value)
                .font(.caption)
                .lineLimit(2)
            
            Spacer()
        }
    }
}

struct AnimeCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleAnime = AnimeData(
            malId: 1,
            images: AnimeImages(
                jpg: ImageUrls(
                    imageUrl: "https://cdn.myanimelist.net/images/anime/13/17405.jpg",
                    smallImageUrl: nil,
                    largeImageUrl: nil
                ),
                webp: nil
            ),
            title: "Cowboy Bebop",
            titleEnglish: "Cowboy Bebop",
            titleJapanese: "カウボーイビバップ",
            synopsis: "In the year 2071, humanity has colonized several of the planets and moons of the solar system leaving the now uninhabitable surface of planet Earth behind. The Inter Solar System Police attempts to keep peace in the galaxy, aided in part by outlaw bounty hunters, referred to as Cowboys.",
            type: "TV",
            episodes: 26,
            status: "Finished Airing",
            aired: nil,
            duration: "24 min per ep",
            rating: "R - 17+ (violence & profanity)",
            score: 8.75,
            scoredBy: 500000,
            popularity: 39,
            members: 1000000,
            favorites: 50000,
            genres: [
                Genre(malId: 1, type: "anime", name: "Action", url: ""),
                Genre(malId: 8, type: "anime", name: "Drama", url: "")
            ],
            studios: [
                Studio(malId: 14, type: "anime", name: "Sunrise", url: "")
            ],
            year: 1998,
            season: "Spring"
        )
        
        AnimeCardView(anime: sampleAnime)
            .environmentObject(FavoritesManager())
            .padding()
    }
}