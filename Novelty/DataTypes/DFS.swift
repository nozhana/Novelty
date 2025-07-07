//
//  DFS.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import Foundation

struct DFS<T>: Sequence {
    final class Iterator: IteratorProtocol {
        private var stack: [Tree<T>]
        
        init(root: Tree<T>) {
            self.stack = [root]
        }
        
        func next() -> Tree<T>? {
            guard let currentTree = stack.popLast() else { return nil }
            stack.append(contentsOf: currentTree.children.reversed())
            return currentTree
        }
    }
    
    var tree: Tree<T>
    
    func makeIterator() -> Iterator {
        .init(root: tree)
    }
}
