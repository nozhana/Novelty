//
//  Tree.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import Foundation

struct Tree<T> {
    var value: T
    var children: [Tree<T>] = []
    
    init(_ value: T, children: [Tree<T>] = []) {
        self.value = value
        self.children = children
    }
    
    init(_ value: T, children: Tree<T>...) {
        self.init(value, children: children)
    }
    
    init(_ value: T, @TreeBuilder<T> children: @escaping () -> [Tree<T>]) {
        self.init(value, children: children())
    }
}

extension Tree {
    static func from(_ value: T, children: KeyPath<T, [T]>) -> Self {
        Tree(value, children: value[keyPath: children].map { child in
            from(child, children: children)
        })
    }
    
    static func from(_ value: T, children childrenGenerator: @escaping (T) -> [T]) -> Self {
        Tree(value, children: childrenGenerator(value).map { child in
            from(child, children: childrenGenerator)
        })
    }
    
    static func from(_ value: T, children childrenGenerator: @escaping (T) throws -> [T]) rethrows -> Self {
        Tree(value, children: try childrenGenerator(value).map { child in
            try from(child, children: childrenGenerator)
        })
    }
    
    static func from(_ value: T, children childrenGenerator: @escaping (T) async -> [T]) async -> Self {
        var children = [Tree<T>]()
        for child in await childrenGenerator(value) {
            let tree = await from(child, children: childrenGenerator)
            children.append(tree)
        }
        return Tree(value, children: children)
    }
    
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
    func child(_ child: T, childBuilder: @escaping (Self) -> Self) -> Self {
        Tree(value, children: children + [childBuilder(Tree(child))])
    }
    
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
