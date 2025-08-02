//
//  RotationTransition.swift
//  Novelty
//
//  Created by Nozhan A. on 7/16/25.
//

import SwiftUI

struct RotationTransition: Transition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .opacity((1 - phase.value).clamped(to: 0...1))
            .rotation3DEffect(.radians(.pi * phase.value), axis: (0, 1, 0))
    }
}

extension AnyTransition {
    static let rotation = AnyTransition(RotationTransition())
}

extension Transition where Self == RotationTransition {
    static var rotation: RotationTransition { .init() }
}
