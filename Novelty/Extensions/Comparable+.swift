//
//  Comparable+.swift
//  Novelty
//
//  Created by Nozhan A. on 7/6/25.
//

import Foundation

extension Comparable {
    func clamped(to range: PartialRangeFrom<Self>) -> Self {
        max(self, range.lowerBound)
    }
    
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
    
    func clamped(to range: Range<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
    
    func clamped(to range: PartialRangeThrough<Self>) -> Self {
        min(self, range.upperBound)
    }
    
    func clamped(to range: PartialRangeUpTo<Self>) -> Self {
        min(self, range.upperBound)
    }
}
