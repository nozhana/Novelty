//
//  StoryNode.swift
//  Novelty
//
//  Created by Nozhan A. on 7/6/25.
//

import Foundation
import SwiftData

@Model
final class StoryNode {
    var title: String?
    var linkTitle: String?
    var content: String
    var parentNode: StoryNode?
    
    @Relationship(deleteRule: .nullify, inverse: \StoryNode.parentNode)
    var children: [StoryNode]
    
    var story: Story?
    
    init(title: String? = nil, linkTitle: String? = nil, content: String = "", children: [StoryNode] = []) {
        self.title = title
        self.linkTitle = linkTitle
        self.content = content
        self.children = children
    }
}

extension StoryNode {
    var titleOrUntitled: String {
        (title?.isEmpty ?? true) ? "Untitled" : title!
    }
    
    var markdown: AttributedString {
        get throws {
            try .init(markdown: content, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))
        }
    }
}

#if DEBUG
extension StoryNode {
    static let mockRoot = StoryNode(title: "Beginnings", content: "The story begins **here**.", children: [mock1])
    static let mock1 = StoryNode(title: "Mock 1", linkTitle: "Go to Mock 1", content: "This is the first route.", children: [mock2, mock3])
    static let mock2 = StoryNode(title: "Mock 2", linkTitle: "Go to Mock 2", content: "From node 1 to 2.", children: [mock4])
    static let mock3 = StoryNode(title: "Mock 3", content: "From node 1 to 3.")
    static let mock4 = StoryNode(title: "Mock 4", content: "From node 2 to 4.")
    static let allMockNodes = [mockRoot, mock1, mock2, mock3, mock4]
}
#endif
