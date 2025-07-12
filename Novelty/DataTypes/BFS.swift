//
//  BFS.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import Foundation

/// Breadth-First-Traversal sequence representation for a ``Tree``.
///
/// ## Example usage:
/// ```swift
/// let tree = Tree(1) {
///     Tree(2) {
///         Tree(3)
///         Tree(4)
///     }
///     Tree(5) {
///         Tree(6) {
///             Tree(7)
///             Tree(8)
///         }
///         Tree(9)
///     }
/// }
///
/// print(BFS(tree: tree))
/// // 1, 2, 5, 3, 4, 6, 9, 7, 8
/// ```
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
