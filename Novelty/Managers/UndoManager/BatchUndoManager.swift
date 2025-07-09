//
//  BatchUndoManager.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import Foundation

protocol BatchUndoManager {
    associatedtype Key: Hashable
    var managers: [Key: UndoManager] { get }
}
