//
//  NoveltyApp.swift
//  Novelty
//
//  Created by Nozhan A. on 7/6/25.
//

import SwiftUI
import SwiftData

@main
struct NoveltyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .database(.shared)
    }
}
