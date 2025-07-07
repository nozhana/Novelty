//
//  DatabaseManager.swift
//  Novelty
//
//  Created by Nozhan A. on 7/6/25.
//

import Foundation
import SwiftData

final class DatabaseManager: ObservableObject {
    let container: ModelContainer
    let undoManager: UndoManager
    
    private init(isStoredInMemoryOnly: Bool = false, groupContainer: ModelConfiguration.GroupContainer = .none) {
        let schema = Schema([
            Story.self,
            StoryNode.self,
        ])
        let configuration = ModelConfiguration("com.nozhana.Novelty.ModelConfiguration",
                                               schema: schema,
                                               isStoredInMemoryOnly: isStoredInMemoryOnly, groupContainer: groupContainer)
        do {
            let container = try ModelContainer(for: schema, configurations: configuration)
            self.container = container
            let undoManager = UndoManager()
            self.undoManager = undoManager
            DispatchQueue.main.async {
                container.mainContext.undoManager = undoManager
            }
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    static let shared = DatabaseManager()
    
#if DEBUG
    @MainActor
    static let preview = {
        let manager = DatabaseManager(isStoredInMemoryOnly: true)
        manager.save(StoryNode.allMockNodes)
        manager.save(Story.mockStory)
        return manager
    }()
#endif
    
    @MainActor
    func transaction(_ actionName: String? = nil, perform block: @escaping (DatabaseManager) -> Void, rollback: @MainActor @Sendable @escaping (DatabaseManager) -> Void) {
        block(self)
        if let actionName {
            undoManager.setActionName(actionName)
        }
        saveChanges()
        undoManager.registerUndo(withTarget: self) { db in
            DispatchQueue.main.async {
                rollback(db)
                db.saveChanges()
            }
        }
    }
    
    @MainActor
    func undo() {
        guard undoManager.canUndo else { return }
        undoManager.undo()
    }
    
    @MainActor
    func redo() {
        guard undoManager.canRedo else { return }
        undoManager.redo()
    }
    
    @MainActor
    func get<M>(id: PersistentIdentifier) -> M? where M: PersistentModel {
        let descriptor = FetchDescriptor(predicate: #Predicate<M> { $0.id == id })
        return try? container.mainContext.fetch(descriptor).first
    }
    
    @MainActor
    func get<M>(ids: [PersistentIdentifier], sortBy sortDescriptors: [SortDescriptor<M>] = []) -> [M] where M: PersistentModel {
        fetch(predicate: #Predicate { ids.contains($0.id) })
    }
    
    @MainActor
    func fetchFirst<M>(_ model: M.Type = M.self, predicate: Predicate<M>? = nil, sortBy sortDescriptors: [SortDescriptor<M>] = [], fetchOffset: Int? = nil) -> M? where M: PersistentModel {
        fetch(predicate: predicate, sortBy: sortDescriptors, fetchLimit: 1, fetchOffset: fetchOffset).first
    }
    
    @MainActor
    func fetch<M>(_ model: M.Type = M.self, predicate: Predicate<M>? = nil, sortBy sortDescriptors: [SortDescriptor<M>] = [], fetchLimit: Int? = nil, fetchOffset: Int? = nil) -> [M] where M: PersistentModel {
        var descriptor = FetchDescriptor(predicate: predicate, sortBy: sortDescriptors)
        descriptor.fetchLimit = fetchLimit
        descriptor.fetchOffset = fetchOffset
        guard let result = try? container.mainContext.fetch(descriptor) else { return [] }
        return result
    }
    
    @MainActor
    func save<M>(_ models: [M]) where M: PersistentModel {
        models.forEach(container.mainContext.insert)
        saveChanges()
        undoManager.registerUndo(withTarget: self) { database in
            DispatchQueue.main.async {
                database.delete(models)
            }
        }
    }
    
    @MainActor
    func save<M>(_ models: M...) where M: PersistentModel {
        save(models)
    }
    
    @MainActor
    func delete<M>(_ models: [M]) where M: PersistentModel {
        models.forEach(container.mainContext.delete)
        saveChanges()
        undoManager.registerUndo(withTarget: self) { database in
            DispatchQueue.main.async {
                database.save(models)
            }
        }
    }
    
    @MainActor
    func delete<M>(_ models: M...) where M: PersistentModel {
        delete(models)
    }
    
    @MainActor
    func delete<M>(model modelType: M.Type, where predicate: Predicate<M>? = nil, includeSubclasses: Bool = true) where M: PersistentModel {
        let modelsToDelete = fetch(predicate: predicate)
        try? container.mainContext.delete(model: modelType, where: predicate, includeSubclasses: includeSubclasses)
        saveChanges()
        undoManager.registerUndo(withTarget: self) { database in
            DispatchQueue.main.async {
                database.save(modelsToDelete)
            }
        }
    }
    
    @MainActor
    func saveChanges() {
        try? container.mainContext.save()
    }
}

extension DatabaseManager {
    @MainActor
    func storyExists(_ story: Story) -> Bool {
        let storyId = story.id
        let descriptor = FetchDescriptor(predicate: #Predicate<Story> { $0.id == storyId })
        return (try? container.mainContext.fetchCount(descriptor)) ?? 0 > 0
    }
    
    @discardableResult
    @MainActor
    func createStory(title: String? = nil, tagline: String? = nil, author: String? = nil) -> Story {
        let rootNode = StoryNode()
        let story = Story(title: title, tagline: tagline, author: author, rootNode: rootNode, nodes: [rootNode])
        save(story)
        return story
    }
    
    @MainActor
    func deleteStories(_ stories: [Story]) {
        stories.flatMap(\.nodes).forEach(container.mainContext.delete)
        delete(stories)
    }
    
    @discardableResult
    @MainActor
    func createStoryNode(title: String? = nil, linkTitle: String? = nil, content: String = "", in parentNode: StoryNode) -> StoryNode {
        let node = StoryNode(title: title, linkTitle: linkTitle, content: content)
        parentNode.children.append(node)
        parentNode.story?.nodes.append(node)
        save(parentNode, node)
        return node
    }
    
    @MainActor
    func deleteStoryNode(_ node: StoryNode) {
        node.parentNode?.children.removeAll(of: node)
        node.story?.nodes.removeAll(of: node)
        delete(node)
    }
}
