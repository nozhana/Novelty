//
//  StoriesUndoManager.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import Foundation

final class StoriesUndoManager: BatchUndoManager {
    private(set) var managers: [UUID : UndoManager] = [:]
    
    private var database: DatabaseManager!
    
    @MainActor
    func setup(database: DatabaseManager = .shared) {
        self.database = database
        let storyIds = database.fetch(Story.self).map(\.id)
        self.managers = Dictionary(uniqueKeysWithValues: storyIds.map { ($0, UndoManager()) })
    }
    
    func addManager(for storyId: UUID) {
        managers[storyId] = UndoManager()
    }
    
    func removeManager(for storyId: UUID) {
        managers.removeValue(forKey: storyId)
    }
    
    @MainActor
    func transaction(_ actionName: String? = nil, for storyId: UUID, perform block: @escaping () -> Void, rollback: @MainActor @Sendable @escaping () -> Void) {
        guard let manager = managers[storyId] else { return }
        block()
        if let actionName {
            manager.setActionName(actionName)
        }
        database.saveChanges()
        manager.registerUndo(withTarget: self) { undoManager in
            DispatchQueue.main.async {
                rollback()
                undoManager.database.saveChanges()
            }
        }
    }
    
    func undoMenuItemTitle(for storyId: UUID) -> String {
        guard let manager = managers[storyId] else { return "Undo" }
        return manager.undoMenuItemTitle
    }
    
    func undo(for storyId: UUID) {
        guard let manager = managers[storyId],
              manager.canUndo else { return }
        manager.undo()
    }
    
    func canUndo(for storyId: UUID) -> Bool {
        guard let manager = managers[storyId] else { return false }
        return manager.canUndo
    }
}
