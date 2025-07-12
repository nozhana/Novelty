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
    
    @AppStorage(DefaultsKey.isOnboarded, store: .group) private var isOnboarded = false
    @AppStorage(DefaultsKey.resetTips, store: .group) private var resetTips = false
    
    init() {
        if resetTips {
            try? Tips.resetDatastore()
            resetTips = false
        }
        try? Tips.configure([.datastoreLocation(.applicationDefault), .displayFrequency(.immediate)])
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isOnboarded {
                    StoryFoldersView()
                        .transition(.move(edge: .trailing))
                } else {
                    OnboardingView {
                        isOnboarded = true
                    }
                    .transition(.move(edge: .leading))
                }
            }
            .alertManager(alertManager)
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
