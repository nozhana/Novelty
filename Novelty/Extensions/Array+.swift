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
}
