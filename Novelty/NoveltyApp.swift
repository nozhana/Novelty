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
            StoriesListView()
                .alertManager(alertManager)
                .onOpenURL { url in
                    router.process(url)
                }
        }
        .database(.shared)
        .environmentObject(router)
    }
}
