//
//  StoryDTO.swift
//  Novelty
//
//  Created by Nozhan A. on 7/10/25.
//

import Foundation
import CoreTransferable
import UniformTypeIdentifiers

struct StoryDTO: Codable, Identifiable {
    var id: UUID
    var title: String?
    var tagline: String?
    var author: String?
    var created: Date
    var updated: Date
    var rootNode: StoryNodeDTO
}

struct StoryNodeDTO: Codable {
    var title: String?
    var linkTitle: String?
    var content: String
    var children: [StoryNodeDTO]
}

extension StoryDTO {
    init(story: Story) {
        self.id = story.id
        self.title = story.title
        self.tagline = story.tagline
        self.author = story.author
        self.created = story.created
        self.updated = story.updated
        self.rootNode = StoryNodeDTO(node: story.rootNode)
    }
}

extension StoryNodeDTO {
    init(node: StoryNode) {
        self.title = node.title
        self.linkTitle = node.linkTitle
        self.content = node.content
        self.children = node.children.map(StoryNodeDTO.init)
    }
}

extension StoryNode {
    convenience init(dto: StoryNodeDTO) {
        self.init(title: dto.title, linkTitle: dto.linkTitle, content: dto.content, children: dto.children.map(StoryNode.init))
    }
}

extension Story {
    convenience init(dto: StoryDTO) {
        let rootNode = StoryNode(dto: dto.rootNode)
        let nodes = DFS(tree: Tree.from(rootNode, children: \.children)).map(\.value)
        self.init(id: dto.id, title: dto.title, tagline: dto.tagline, author: dto.author, rootNode: rootNode, nodes: nodes)
    }
}

extension StoryDTO: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .noveltyStoryBundle) { dto in
            try JSONEncoder().encode(dto).base64EncodedData()
        } importing: { data in
            let decodedData = Data(base64Encoded: data)!
            return try JSONDecoder().decode(Self.self, from: decodedData)
        }
        .suggestedFileName {
            ($0.title ?? "Untitled Story") + ".storybundle"
        }
    }
}

extension UTType {
    static let noveltyStoryBundle = UTType("com.nozhana.Novelty.storybundle")!
}

struct PasswordProtectedStoryDTO: Codable {
    var title: String?
    var storyBox: Encrypted<StoryDTO>
    
    init(storyDto: StoryDTO, password: String) throws {
        self.title = storyDto.title
        self.storyBox = try .init(storyDto, with: password)
    }
}

extension PasswordProtectedStoryDTO: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .noveltyStoryBundle) { dto in
            try JSONEncoder().encode(dto)
        } importing: { data in
            try JSONDecoder().decode(Self.self, from: data)
        }
        .suggestedFileName {
            ($0.title ?? "Untitled Story") + ".storybundle"
        }
    }
}
