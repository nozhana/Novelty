//
//  Set+.swift
//  Novelty
//
//  Created by Nozhan A. on 7/11/25.
//

import Foundation

extension Set {
    mutating func removeAll(where predicate: @escaping (Element) -> Bool) {
        for element in self {
            if predicate(element) {
                remove(element)
            }
        }
    }
}
