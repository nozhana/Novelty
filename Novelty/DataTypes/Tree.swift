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
            Tree.from(child, children: children)
        })
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
