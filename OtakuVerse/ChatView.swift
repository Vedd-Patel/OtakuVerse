//
//  ChatView.swift
//  AnimeChat
//
//  Created on 2025
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var viewModel: ChatViewModel
    @EnvironmentObject var favoritesManager: FavoritesManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var messageText = ""
    @State private var showingTypingIndicator = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Messages List
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(viewModel.messages) { message in
                                MessageBubbleView(message: message)
                                    .id(message.id)
                            }
                            
                            if showingTypingIndicator {
                                TypingIndicatorView()
                                    .id("typing")
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                        }
                    }
                    .onChange(of: showingTypingIndicator) { isTyping in
                        if isTyping {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo("typing", anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input Area
                HStack {
                    TextField("Ask about anime...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            sendMessage()
                        }
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
            }
            .navigationTitle("AnimeChat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        themeManager.toggleTheme()
                    }) {
                        Image(systemName: themeManager.isDarkMode ? "sun.max" : "moon")
                    }
                }
            }
        }
        .onAppear {
            if viewModel.messages.isEmpty {
                viewModel.addWelcomeMessage()
            }
        }
    }
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        messageText = ""
        showingTypingIndicator = true
        
        Task {
            await viewModel.processUserMessage(text)
            await MainActor.run {
                showingTypingIndicator = false
            }
        }
    }
}

struct MessageBubbleView: View {
    let message: ChatMessage
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer(minLength: 60)
                
                VStack(alignment: .trailing) {
                    Text(message.text)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .clipShape(MessageShape(isUser: true))
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading) {
                    if let animeData = message.animeData {
                        AnimeCardView(anime: animeData)
                            .environmentObject(favoritesManager)
                    } else {
                        Text(message.text)
                            .padding()
                            .background(Color(UIColor.systemGray5))
                            .foregroundColor(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .clipShape(MessageShape(isUser: false))
                    }
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 8)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct MessageShape: Shape {
    let isUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [
            .topLeft,
            .topRight,
            isUser ? .bottomLeft : .bottomRight
        ], cornerRadii: CGSize(width: 18, height: 18))
        
        return Path(path.cgPath)
    }
}

struct TypingIndicatorView: View {
    @State private var animating = false
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                        .scaleEffect(animating ? 1.2 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: animating
                        )
                }
            }
            .padding()
            .background(Color(UIColor.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            
            Spacer(minLength: 60)
        }
        .padding(.horizontal, 8)
        .onAppear {
            animating = true
        }
    }
}