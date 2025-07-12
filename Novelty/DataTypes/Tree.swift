//
//  Tree.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import Foundation

/// A generic struct representing a tree data structure.
///
/// - Note: This structure contains itself recursively.
struct Tree<T> {
    /// The wrapped value of the tree node.
    var value: T
    /// The descendents of this tree node.
    var children: [Tree<T>] = []
    
    /// Initialize a tree with a wrapped value and a list of descendent trees.
    /// - Parameters:
    ///   - value: The wrapped value.
    ///   - children: The descendent trees.
    ///
    /// ## Example usage
    /// ```swift
    /// let tree = Tree("Parent", children: [
    ///     Tree("Child 1"),
    ///     Tree("Child 2", children: [
    ///         Tree("Child of child 2")
    ///     ]
    /// ])
    /// ```
    init(_ value: T, children: [Tree<T>] = []) {
        self.value = value
        self.children = children
    }
    
    /// Initialize a tree with a wrapped value and a variadic sequence of descendent trees.
    /// - Parameters:
    ///   - value: The wrapped value.
    ///   - children: The descendent trees.
    ///
    /// ## Example usage:
    /// ```swift
    /// let tree = Tree(
    ///     "Parent",
    ///     children: Tree(
    ///         "Child 1"
    ///     ),
    ///     Tree(
    ///         "Child 2",
    ///         children: Tree(
    ///             "Child of child 2"
    ///         )
    ///     )
    /// )
    /// ```
    init(_ value: T, children: Tree<T>...) {
        self.init(value, children: children)
    }
    
    /// Initialize a tree with a wrapped value and a tree builder function.
    /// - Parameters:
    ///   - value: The wrapped value.
    ///   - children: The tree builder function that generates the descendent trees.
    ///
    /// ## Example usage:
    /// ```swift
    /// let tree = Tree("Parent") {
    ///     Tree("Child 1")
    ///     Tree("Child 2") {
    ///         Tree("Child of child 2")
    ///     }
    /// }
    /// ```
    init(_ value: T, @TreeBuilder<T> children: @escaping () -> [Tree<T>]) {
        self.init(value, children: children())
    }
}

extension Tree {
    /// Convenience initializer to build a tree recusrively from a certain type using a keypath.
    /// - Parameters:
    ///   - value: The root instance.
    ///   - children: The keypath from the value type that results in the descendent nodes.
    /// - Returns: A ``Tree`` of root type `T`.
    static func from(_ value: T, children: KeyPath<T, [T]>) -> Self {
        Tree(value, children: value[keyPath: children].map { child in
            from(child, children: children)
        })
    }
    
    /// Convenience initializer to build a tree recursively from a certain type using a builder function.
    /// - Parameters:
    ///   - value: The root instance.
    ///   - childrenGenerator: The builder function used to generate the descendents for each node.
    /// - Returns: A ``Tree`` of root type `T`.
    static func from(_ value: T, children childrenGenerator: @escaping (T) -> [T]) -> Self {
        Tree(value, children: childrenGenerator(value).map { child in
            from(child, children: childrenGenerator)
        })
    }
    
    /// Convenience initializer to build a tree recursively from a certain type using a throwing builder function.
    /// - Parameters:
    ///   - value: The root instance.
    ///   - childrenGenerator: The throwing builder function used to generate the descendents for each node.
    /// - Returns: A ``Tree`` of root type `T`.
    static func from(_ value: T, children childrenGenerator: @escaping (T) throws -> [T]) rethrows -> Self {
        Tree(value, children: try childrenGenerator(value).map { child in
            try from(child, children: childrenGenerator)
        })
    }
    
    /// Convenience initializer to build a tree recursively from a certain type using an asynchronous builder function.
    /// - Parameters:
    ///   - value: The root instance.
    ///   - childrenGenerator: The asynchronous builder function used to generate the descendents for each node.
    /// - Returns: A ``Tree`` of root type `T`.
    static func from(_ value: T, children childrenGenerator: @escaping (T) async -> [T]) async -> Self {
        var children = [Tree<T>]()
        for child in await childrenGenerator(value) {
            let tree = await from(child, children: childrenGenerator)
            children.append(tree)
        }
        return Tree(value, children: children)
    }
    
    /// Convenience initializer to build a tree recursively from a certain type using an asynchronous throwing builder function.
    /// - Parameters:
    ///   - value: The root instance.
    ///   - childrenGenerator: The asynchronous throwing builder function used to generate the descendents for each node.
    /// - Returns: A ``Tree`` of root type `T`.
    static func from(_ value: T, children childrenGenerator: @escaping (T) async throws -> [T]) async rethrows -> Self {
        var children = [Tree<T>]()
        for child in try await childrenGenerator(value) {
            let tree = try await from(child, children: childrenGenerator)
            children.append(tree)
        }
        return Tree(value, children: children)
    }
}

extension Tree {
    /// Cascading function used to configure and add a child to the current tree.
    /// - Parameters:
    ///   - child: The child value to be appended.
    ///   - childBuilder: Configures the created child.
    /// - Returns: The modified self.
    func child(_ child: T, childBuilder: @escaping (Self) -> Self) -> Self {
        Tree(value, children: children + [childBuilder(Tree(child))])
    }
    
    /// Cascading function used to add a child to the current tree.
    /// - Parameter child: The child value to be appended.
    /// - Returns: The modified self.
    func child(_ child: T) -> Self {
        Tree(value, children: children + [Tree(child)])
    }
}

extension Tree: Decodable where T: Decodable {}
extension Tree: Encodable where T: Encodable {}

typealias TreeDictionaryLiteral<T> = (T, [Tree<T>])

extension Tree: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: TreeDictionaryLiteral<T>...) {
        let element = elements.first!
        self.init(element.0, children: element.1)
    }
}

extension Tree: ExpressibleByIntegerLiteral where T == Int {
    init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension Tree: ExpressibleByFloatLiteral where T == Float {
    init(floatLiteral value: Float) {
        self.init(value)
    }
}

extension Tree: ExpressibleByUnicodeScalarLiteral where T == String {}
extension Tree: ExpressibleByExtendedGraphemeClusterLiteral where T == String {}
extension Tree: ExpressibleByStringLiteral where T == String {
    init(stringLiteral value: String) {
        self.init(value)
    }
}

extension Tree: ExpressibleByBooleanLiteral where T == Bool {
    init(booleanLiteral value: Bool) {
        self.init(value)
    }
}

/// A result builder that generates an array of ``Tree`` structures.
///
/// - Note: See ``TreeView``.
@resultBuilder
struct TreeBuilder<T> {
    static func buildBlock(_ components: Tree<T>...) -> [Tree<T>] {
        components
    }
    
    static func buildEither(first component: [Tree<T>]) -> [Tree<T>] {
        component
    }
    
    static func buildEither(second component: [Tree<T>]) -> [Tree<T>] {
        component
    }
    
    static func buildArray(_ components: [[Tree<T>]]) -> [Tree<T>] {
        components.flatMap(\.self)
    }
    
    static func buildOptional(_ component: [Tree<T>]?) -> [Tree<T>] {
        component ?? []
    }
}
