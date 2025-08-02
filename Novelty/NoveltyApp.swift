//
//  NoveltyApp.swift
//  Novelty
//
//  Created by Nozhan A. on 7/6/25.
//

import SwiftUI
import TipKit

@main
struct NoveltyApp: App {
    @ObservedObject private var router = Router.shared
    @ObservedObject private var alertManager = AlertManager.shared
    @ObservedObject private var localizer = Localizer.shared
    
    @AppStorage(DefaultsKey.isOnboarded, store: .group) private var isOnboarded = false
    @AppStorage(DefaultsKey.resetTips, store: .group) private var resetTips = false
    
    @State private var showSettingLanguageView = false
    
    init() {
        if resetTips {
            try? Tips.resetDatastore()
            resetTips = false
        }
        try? Tips.configure([.datastoreLocation(.applicationDefault), .displayFrequency(.immediate)])
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSettingLanguageView {
                    ProgressView("Setting Language")
                        .font(.title2.bold())
                        .transition(.move(edge: .leading).combined(with: .opacity).combined(with: .offset(x: -64)))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.smooth) {
                                    showSettingLanguageView = false
                                }
                            }
                        }
                        .zIndex(2)
                } else if isOnboarded {
                    StoryFoldersView()
                        .transition(.move(edge: .trailing).combined(with: .offset(x: 64)))
                        .zIndex(0)
                } else {
                    OnboardingView {
                        withAnimation(.smooth) {
                            isOnboarded = true
                        }
                    }
                    .transition(.move(edge: .leading).combined(with: .offset(x: -64)))
                    .zIndex(1)
                }
            }
            .animation(.smooth, value: isOnboarded != showSettingLanguageView)
            .alertManager(alertManager)
            .localized(localizer)
            .onChange(of: localizer.language) {
                showSettingLanguageView = true
            }
            .onOpenURL { url in
                router.process(url)
            }
            .onAppear {
                // Soft migration
                let database = DatabaseManager.shared
                let orphanStories = database.fetch(Story.self, predicate: #Predicate { $0.folder == nil })
                for story in orphanStories {
                    story.folder = .inbox
                }
                database.saveChanges()
            }
        }
        .database(.shared)
        .environmentObject(router)
    }
}
