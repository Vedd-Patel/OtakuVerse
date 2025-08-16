//
//  ContentView.swift
//  OtakuVerse
//
//  Created by VED PATEL on 16/08/25.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var favoritesManager = FavoritesManager()
    @StateObject private var themeManager = ThemeManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Chat Tab
            ChatView()
                .environmentObject(chatViewModel)
                .environmentObject(favoritesManager)
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }
                .tag(0)
            
            // Favorites Tab
            FavoritesView()
                .environmentObject(favoritesManager)
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites")
                }
                .tag(1)
            
            // Recent Tab
            RecentSearchesView()
                .environmentObject(chatViewModel)
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("Recent")
                }
                .tag(2)
            
            // Random Tab
            RandomAnimeView()
                .environmentObject(favoritesManager)
                .tabItem {
                    Image(systemName: "dice.fill")
                    Text("Discover")
                }
                .tag(3)
            
            // Settings Tab
            SettingsView()
                .environmentObject(themeManager)
                .tabItem {
                    Image(systemName: "gear.fill")
                    Text("Settings")
                }
                .tag(4)
        }
        .environmentObject(themeManager)
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        .accentColor(.blue)
    }
}
