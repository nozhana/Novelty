//
//  Database+.swift
//  Novelty
//
//  Created by Nozhan A. on 7/6/25.
//

import SwiftUI

extension View {
    func database(_ database: DatabaseManager) -> some View {
        self
            .modelContainer(database.container)
            .environmentObject(database)
    }
}

extension Scene {
    func database(_ database: DatabaseManager) -> some Scene {
        self
            .modelContainer(database.container)
            .environmentObject(database)
    }
}
