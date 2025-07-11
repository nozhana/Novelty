//
//  RadialLayout.swift
//  Novelty
//
//  Created by Nozhan A. on 7/11/25.
//

import SwiftUI

struct RadialLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let radius = bounds.width / 3
        let angle = Angle.degrees(360 / Double(subviews.count)).radians
        
        for (index, subview) in subviews.enumerated() {
            var point = CGPoint(x: 0, y: -radius).applying(CGAffineTransform(rotationAngle: CGFloat(angle) * CGFloat(index)))
            
            point.x += bounds.midX
            point.y += bounds.midY
            
            subview.place(at: point, anchor: .center, proposal: .unspecified)
        }
    }
}
