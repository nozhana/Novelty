//
//  Story.swift
//  Novelty
//
//  Created by Nozhan A. on 7/6/25.
//

import Foundation
import SwiftData

@Model
final class Story {
    var title: String?
    var tagline: String?
    var author: String?
    var created = Date.now
    var updated = Date.now
    
    @Relationship(deleteRule: .nullify, inverse: \StoryNode.story)
    var nodes: [StoryNode]
    
    var rootNode: StoryNode
    var currentNode: StoryNode?
    
    init(title: String? = nil, tagline: String? = nil, author: String? = nil, rootNode: StoryNode, currentNode: StoryNode? = nil, nodes: [StoryNode] = []) {
        self.title = title
        self.tagline = tagline
        self.author = author
        self.rootNode = rootNode
        self.currentNode = currentNode
        self.nodes = nodes
    }
}

#if DEBUG
extension Story {
    static let mockStory = {
        let story = Story(title: "Story Title", tagline: "Story Tagline", author: "John Doe", rootNode: .mockRoot, nodes: StoryNode.allMockNodes)
        return story
    }()
}
#endif
