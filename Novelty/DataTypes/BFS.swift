//
//  BFS.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import Foundation

struct BFS<T>: Sequence {
    final class Iterator: IteratorProtocol {
        private var queue: [Tree<T>]
        
        init(root: Tree<T>) {
            self.queue = [root]
        }
        
        func next() -> Tree<T>? {
            guard !queue.isEmpty else { return nil }
            let currentTree = queue.removeFirst()
            queue.append(contentsOf: currentTree.children)
            return currentTree
        }
    }
    
    var tree: Tree<T>
    
    func makeIterator() -> Iterator {
        .init(root: tree)
    }
}

extension BFS: CustomStringConvertible {
    var description: String {
        map { "\($0.value)" }.joined(separator: ", ")
    }
}
