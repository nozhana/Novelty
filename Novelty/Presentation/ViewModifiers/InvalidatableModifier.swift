//
//  InvalidatableModifier.swift
//  Novelty
//
//  Created by Nozhan A. on 7/11/25.
//

import SwiftUI

struct InvalidatableModifier<T>: ViewModifier where T: Equatable {
    var trigger: T
    
    @State private var invalidated = false
    
    func body(content: Content) -> some View {
        content
            .invalidatableContent()
            .redacted(reason: invalidated ? .invalidated : [])
            .onChange(of: trigger) {
                invalidated = true
                invalidated = false
            }
    }
}

extension View {
    func invalidatable<T>(trigger: T) -> some View where T: Equatable {
        modifier(InvalidatableModifier(trigger: trigger))
    }
}
