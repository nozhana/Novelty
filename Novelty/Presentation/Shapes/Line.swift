//
//  Line.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import SwiftUI

struct Line: Shape {
    var from: CGPoint
    var to: CGPoint
    
    var animatableData: AnimatablePair<CGPoint, CGPoint> {
        get { AnimatablePair(from, to) }
        set {
            from = newValue.first
            to = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: self.from)
            path.addLine(to: self.to)
        }
    }
}
