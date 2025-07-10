//
//  CGPoint+.swift
//  Novelty
//
//  Created by Nozhan A. on 7/10/25.
//

import SwiftUI

extension CGPoint: @retroactive AdditiveArithmetic {
    public static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

extension CGPoint: @retroactive VectorArithmetic {
    public mutating func scale(by rhs: Double) {
        self = CGPoint(x: x.scaled(by: rhs), y: y.scaled(by: rhs))
    }
    
    public var magnitudeSquared: Double {
        sqrt(x.magnitudeSquared + y.magnitudeSquared)
    }
}
