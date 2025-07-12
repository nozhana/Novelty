//
//  NoveltyApp.swift
//  Novelty
//
//  Created by Nozhan A. on 7/6/25.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct NoveltyApp: App {
    @ObservedObject private var router = Router.shared
    @ObservedObject private var alertManager = AlertManager.shared
    
    init() {
        // try? Tips.resetDatastore()
        try? Tips.configure([.datastoreLocation(.applicationDefault), .displayFrequency(.immediate)])
    }
    
    var body: some Scene {
        WindowGroup {
            StoryFoldersView()
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
