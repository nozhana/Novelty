//
//  StoryEntity.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import AppIntents

struct StoryEntity: AppEntity, Identifiable {
    var id: UUID
    var title: String?
    var tagline: String?
    
    var displayRepresentation: DisplayRepresentation {
        .init(title: .init(stringLiteral: title ?? "Untitled"), subtitle: tagline.map(LocalizedStringResource.init))
    }
    
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Story"
    
    static let defaultQuery = StoryQuery()
}

extension StoryEntity {
    init(story: Story) {
        self.id = story.id
        self.title = story.title
        self.tagline = story.tagline
    }
}

struct StoryQuery: EntityQuery {
    func suggestedEntities() async throws -> [StoryEntity] {
        let database = await DatabaseManager.shared
        let stories = await database.fetch(Story.self, sortBy: [.init(\.created, order: .reverse)])
        let entities = stories.map { StoryEntity(id: $0.id, title: $0.title, tagline: $0.tagline) }
        return entities
    }
    
    func defaultResult() async -> StoryEntity? {
        let database = await DatabaseManager.shared
        guard let story = await database.fetchFirst(Story.self, sortBy: [.init(\.created, order: .reverse)]) else {
            return nil
        }
        let entity = StoryEntity(id: story.id, title: story.title, tagline: story.tagline)
        return entity
    }
    
    func entities(for identifiers: [StoryEntity.ID]) async throws -> [StoryEntity] {
        let database = await DatabaseManager.shared
        let stories = await database.fetch(Story.self, predicate: #Predicate { identifiers.contains($0.id) }, sortBy: [.init(\.created, order: .reverse)])
        let entities = stories.map { StoryEntity(id: $0.id, title: $0.title, tagline: $0.tagline) }
        return entities
    }
}
