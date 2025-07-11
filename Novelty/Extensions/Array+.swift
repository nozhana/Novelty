//
//  Array+.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import Foundation

extension Array {
    mutating func removeAll(of element: Element) where Element: Equatable {
        removeAll(where: { $0 == element })
    }
    
    func removingAll(of element: Element) -> [Element] where Element: Equatable {
        var result = self
        result.removeAll(of: element)
        return result
    }
    
    subscript(safe index: Int) -> Element? {
        if indices.contains(index) {
            return self[index]
        } else {
            return nil
        }
    }
}
