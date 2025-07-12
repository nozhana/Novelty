//
//  DFS.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import Foundation

/// Depth-First-Traversal sequence representation for a ``Tree``.
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
/// print(DFS(tree: tree))
/// // 1, 2, 3, 4, 5, 6, 7, 8, 9
/// ```
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

extension DFS: CustomStringConvertible {
    var description: String {
        map { "\($0.value)" }.joined(separator: ", ")
    }
}
