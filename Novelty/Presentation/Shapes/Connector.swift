//
//  Connector.swift
//  Novelty
//
//  Created by Nozhan A. on 7/10/25.
//

import SwiftUI

struct Connector: Shape {
    var from: CGPoint
    var to: CGPoint
    var radius: CGFloat?
    
    var animatableData: AnimatablePair<CGPoint, CGPoint> {
        get { AnimatablePair(from, to) }
        set {
            from = newValue.first
            to = newValue.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let radius = min(abs(from.x - to.x), abs(from.y - to.y), self.radius ?? .infinity) / 4
            
            var t11 = CGPoint(x: from.x, y: (from.y + to.y) / 2)
            if from.y < to.y {
                t11.y -= radius
            } else {
                t11.y += radius
            }
            var t21 = CGPoint(x: to.x, y: (from.y + to.y) / 2)
            if from.x < to.x {
                t21.x -= radius
            } else {
                t21.x += radius
            }
            var t22 = CGPoint(x: to.x, y: (from.y + to.y) / 2)
            if from.y < to.y {
                t22.y += radius
            } else {
                t22.y -= radius
            }
            
            let c1: CGPoint
            let c2: CGPoint
            if from.x < to.x {
                c1 = t11.applying(.init(translationX: radius, y: 0))
                c2 = t22.applying(.init(translationX: -radius, y: 0))
            } else {
                c1 = t11.applying(.init(translationX: -radius, y: 0))
                c2 = t22.applying(.init(translationX: radius, y: 0))
            }
            
            path.move(to: from)
            path.addLine(to: t11)
            let s1: Angle = from.x < to.x ? .degrees(180) : .zero
            let s2: Angle = from.y < to.y ? .degrees(-90) : .degrees(90)
            let delta1: Angle = (from.x < to.x && from.y < to.y) || (from.x > to.x && from.y > to.y) ? .degrees(-90) : .degrees(90)
            path.addRelativeArc(center: c1, radius: radius, startAngle: s1, delta: delta1)
            path.addLine(to: t21)
            path.addRelativeArc(center: c2, radius: radius, startAngle: s2, delta: -delta1)
            path.addLine(to: to)
        }
    }
}

#Preview {
    Connector(from: .init(x: 50, y: 300), to: .init(x: 300, y: 50))
        .stroke()
}
