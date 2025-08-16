//
//  OtakuVerseApp.swift
//  OtakuVerse
//
//  Created by VED PATEL on 16/08/25.
//

import SwiftUI

@main
struct AnimeChatApp: App {
    @StateObject var favoritesManager = FavoritesManager()
    @StateObject var chatViewModel = ChatViewModel()
    @StateObject var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(favoritesManager)
                .environmentObject(chatViewModel)
                .environmentObject(themeManager)
        }
    }
}
