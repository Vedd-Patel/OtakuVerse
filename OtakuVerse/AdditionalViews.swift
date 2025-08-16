//
//  RecentSearchesView.swift
//  AnimeChat
//
//  Created on 2025
//

import SwiftUI

struct RecentSearchesView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var showingClearAlert = false
    
    var body: some View {
        NavigationView {
            Group {
                if chatViewModel.recentSearches.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No Recent Searches")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text("Your search history will appear here after you start chatting about anime")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(chatViewModel.recentSearches) { search in
                            RecentSearchRow(search: search)
                                .environmentObject(chatViewModel)
                        }
                        .onDelete(perform: deleteSearches)
                    }
                }
            }
            .navigationTitle("Recent Searches")
            .toolbar {
                if !chatViewModel.recentSearches.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear All") {
                            showingClearAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .alert("Clear All Recent Searches", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    chatViewModel.clearRecentSearches()
                }
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
    
    private func deleteSearches(offsets: IndexSet) {
        chatViewModel.recentSearches.remove(atOffsets: offsets)
    }
}

struct RecentSearchRow: View {
    let search: RecentSearch
    @EnvironmentObject var chatViewModel: ChatViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(search.query)
                    .font(.body)
                    .lineLimit(2)
                
                Text(formatDate(search.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                chatViewModel.repeatSearch(search.query)
            }) {
                Image(systemName: "arrow.up.left.circle")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

//
//  RandomAnimeView.swift
//  AnimeChat
//
//  Created on 2025
//

struct RandomAnimeView: View {
    @StateObject private var viewModel = RandomAnimeViewModel()
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("Finding a surprise anime for you...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.error {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundColor(.red.opacity(0.7))
                        
                        Text("Error")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(error)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Try Again") {
                            viewModel.getRandomAnime()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let anime = viewModel.currentAnime {
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("🎲 Random Discovery")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            AnimeCardView(anime: anime)
                                .environmentObject(favoritesManager)
                        }
                        .padding()
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "dice.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue.opacity(0.7))
                        
                        Text("Discover Random Anime")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Get surprised with a random anime from the vast world of Japanese animation")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Get Random Anime") {
                            viewModel.getRandomAnime()
                        }
                        .buttonStyle(.borderedProminent)
                        .font(.headline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("Discover")
            .toolbar {
                if viewModel.currentAnime != nil && !viewModel.isLoading {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("New Random") {
                            viewModel.getRandomAnime()
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .onAppear {
            if viewModel.currentAnime == nil {
                viewModel.getRandomAnime()
            }
        }
    }
}

//
//  SettingsView.swift
//  AnimeChat
//
//  Created on 2025
//

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var showingClearDataAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Appearance") {
                    HStack {
                        Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(themeManager.isDarkMode ? .blue : .orange)
                            .frame(width: 24)
                        
                        Text("Dark Mode")
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { themeManager.isDarkMode },
                            set: { _ in themeManager.toggleTheme() }
                        ))
                    }
                }
                
                Section("Data") {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading) {
                            Text("Favorites")
                            Text("\(favoritesManager.favorites.count) anime saved")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    Button(action: {
                        showingClearDataAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            Text("Clear All Data")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section("About") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading) {
                            Text("AnimeChat")
                            Text("Version 1.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading) {
                            Text("Powered by Jikan API")
                            Text("Unofficial MyAnimeList API")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .frame(width: 24)
                        
                        Text("Rate This App")
                            .foregroundColor(.blue)
                        
                        Spacer()
                    }
                    .onTapGesture {
                        // Handle app rating
                        if let url = URL(string: "itms-apps://itunes.apple.com/app/id123456789") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                
                Section("Support") {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Contact Support")
                            .foregroundColor(.blue)
                        
                        Spacer()
                    }
                    .onTapGesture {
                        // Handle contact support
                        if let url = URL(string: "mailto:support@animechat.app") {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Help & FAQ")
                            .foregroundColor(.blue)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .alert("Clear All Data", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                favoritesManager.clearAllFavorites()
                // Could also clear recent searches here if needed
            }
        } message: {
            Text("This will remove all your favorites and data. This action cannot be undone.")
        }
    }
}