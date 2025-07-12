//
//  DatabaseManager.swift
//  Novelty
//
//  Created by Nozhan A. on 7/6/25.
//

import Foundation
import SwiftData

/// A configurable database manager for `SwiftData` containers.
///
/// - Note: Uses a singleton pattern. See ``shared``.
/// - Warning: Use the ``preview`` instance for previews.
///
/// Inject the `DatabaseManager` into a ``SwiftUI/Scene`` using the helper function ``SwiftUI/Scene/database(_:)``,
/// or into a ``SwiftUICore/View`` using ``SwiftUICore/View/database(_:)``.
///
/// ## Injecting in scenes
///
/// ```swift
/// var body: some Scene {
///     WindowGroup {
///         MainView()
///     }
///     .database(.shared)
/// }
/// ```
///
/// ## Injecting in views
///
/// ```swift
/// var body: some View {
///     MainView()
///         .database(.shared)
/// }
/// ```
///
/// ## Injecting in previews
///
/// ```swift
/// #Preview {
///     SomeView()
///         .database(.preview)
/// }
/// ```
final class DatabaseManager: ObservableObject {
    let container: ModelContainer
    let undoManager: StoriesUndoManager
    
    @MainActor
    private init(isStoredInMemoryOnly: Bool = false, groupContainer: ModelConfiguration.GroupContainer = .identifier(Constants.groupIdentifier)) {
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
            self.undoManager = StoriesUndoManager()
            undoManager.setup(database: self)
            // DispatchQueue.main.async {
            //     container.mainContext.undoManager = undoManager
            // }
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    /// The singleton instance of ``DatabaseManager``.
    @MainActor
    static let shared = DatabaseManager()
    
#if DEBUG
    /// The preview singleton instance of ``DatabaseManager``.
    ///
    /// - Note: This instance doesn't persist data to the disk, and contains the mock entities initially.
    @MainActor
    static let preview = {
        let manager = DatabaseManager(isStoredInMemoryOnly: true)
        manager.save(StoryNode.allMockNodes)
        manager.save(Story.mockStory)
        manager.undoManager.addManager(for: Story.mockStory.id)
        manager.save(StoryFolder.mockFolders)
        return manager
    }()
#endif
    
    /// Define and perform an undoable transaction on the database.
    /// - Parameters:
    ///   - actionName: The name of the action to show on the undo label.
    ///   - storyId: The ID of the story this action pertains to.
    ///   - block: The action to be performed.
    ///   - rollback: The rollback function for the action—*i.e. the function that resets the database state to where it was before performing the action.*
    @MainActor
    func transaction(_ actionName: String? = nil, for storyId: UUID, perform block: @escaping () -> Void, rollback: @MainActor @Sendable @escaping () -> Void) {
        undoManager.transaction(actionName, for: storyId, perform: block, rollback: rollback)
    }
    
    @MainActor
    func registerUndo(_ actionName: String? = nil, for storyId: UUID, rollback: @MainActor @Sendable @escaping () -> Void) {
        undoManager.registerUndo(actionName, for: storyId, rollback: rollback)
    }
    
    @MainActor
    func undo(for storyId: UUID) {
        undoManager.undo(for: storyId)
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
    }
    
    @MainActor
    func save<M>(_ models: M...) where M: PersistentModel {
        save(models)
    }
    
    @MainActor
    func delete<M>(_ models: [M]) where M: PersistentModel {
        models.forEach(container.mainContext.delete)
        saveChanges()
    }
    
    @MainActor
    func delete<M>(_ models: M...) where M: PersistentModel {
        delete(models)
    }
    
    @MainActor
    func delete<M>(model modelType: M.Type, where predicate: Predicate<M>? = nil, includeSubclasses: Bool = true) where M: PersistentModel {
        try? container.mainContext.delete(model: modelType, where: predicate, includeSubclasses: includeSubclasses)
        saveChanges()
    }
    
    @MainActor
    func saveChanges() {
        try? container.mainContext.save()
    }
}

extension DatabaseManager {
    @MainActor
    func getOrCreateInboxFolder() -> StoryFolder {
        let inboxID = StoryFolder.inboxID
        if let inbox = fetchFirst(StoryFolder.self, predicate: #Predicate { $0.id == inboxID }) {
            return inbox
        }
        let inbox = StoryFolder(id: inboxID, title: "Inbox", layoutPriority: -1)
        save(inbox)
        return inbox
    }
    
    @MainActor
    func storyExists(_ story: Story) -> Bool {
        let storyId = story.id
        let descriptor = FetchDescriptor(predicate: #Predicate<Story> { $0.id == storyId })
        return (try? container.mainContext.fetchCount(descriptor)) ?? 0 > 0
    }
    
    @discardableResult
    @MainActor
    func createStory(title: String? = nil, tagline: String? = nil, author: String? = nil, in folder: StoryFolder? = nil) -> Story {
        let rootNode = StoryNode()
        let story = Story(title: title, tagline: tagline, author: author, rootNode: rootNode, nodes: [rootNode])
        undoManager.addManager(for: story.id)
        folder?.stories.append(story)
        save(story)
        if let folder {
            save(folder)
        }
        return story
    }
    
    @MainActor
    func deleteStories(_ stories: [Story]) {
        stories.flatMap(\.nodes).forEach(container.mainContext.delete)
        stories.map(\.id).forEach(undoManager.removeManager)
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
