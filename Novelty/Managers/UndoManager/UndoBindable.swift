//
//  UndoBindable.swift
//  Novelty
//
//  Created by Nozhan A. on 7/8/25.
//

import SwiftUI

@dynamicMemberLookup
@propertyWrapper
struct UndoBindable<Value>: DynamicProperty {
    init(wrappedValue: Value, target: AnyObject, manager: UndoManager = .init(), actionName: String? = nil) {
        self.wrappedValue = wrappedValue
        self.undoManager = manager
        self.undoTarget = target
        self.actionName = actionName
    }
    
    var wrappedValue: Value
    var undoManager: UndoManager
    var undoTarget: AnyObject
    var actionName: String?
    
    var projectedValue: UndoBindable<Value> {
        self
    }
    
    subscript<T>(dynamicMember keyPath: ReferenceWritableKeyPath<Value, T>) -> Binding<T> {
        Binding {
            wrappedValue[keyPath: keyPath]
        } set: {
            let previousValue = wrappedValue[keyPath: keyPath]
            wrappedValue[keyPath: keyPath] = $0
            if let actionName {
                undoManager.setActionName(actionName)
            }
            undoManager.registerUndo(withTarget: undoTarget) { _ in
                wrappedValue[keyPath: keyPath] = previousValue
            }
        }
    }
}
