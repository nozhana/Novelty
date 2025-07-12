//
//  StoryFolder.swift
//  Novelty
//
//  Created by Nozhan A. on 7/12/25.
//

import SwiftUI
import SwiftData

@Model
final class StoryFolder {
    var id: UUID
    var title: String
    var layoutPriority: Int
    
    @Relationship(deleteRule: .cascade, inverse: \Story.folder)
    var stories: [Story]
    
    init(id: UUID = UUID(), title: String = "", layoutPriority: Int = 0, stories: [Story] = []) {
        self.id = id
        self.title = title
        self.layoutPriority = layoutPriority
        self.stories = stories
    }
}

extension StoryFolder {
    static let inboxID = UUID(uuidString: "82291046-4385-4ceb-afd4-3c1d6953b4a3")!
    
    @MainActor
    static var inbox: StoryFolder {
        DatabaseManager.shared.getOrCreateInboxFolder()
    }
    
    static let mockFolders = [
        StoryFolder(title: "Business", layoutPriority: 0),
        StoryFolder(title: "Fun", layoutPriority: 1, stories: [.mockStory]),
    ]
}
