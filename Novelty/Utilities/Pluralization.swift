//
//  Pluralization.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import Foundation

extension String {
    func plural(count: Int) -> String {
        let localized: String.LocalizationValue = "^[\(count) \(self)](inflect: true)"
        return String(AttributedString(localized: localized).characters)
    }
}

extension Int {
    func counting(_ word: String) -> String {
        word.plural(count: self)
    }
}

infix operator %* : AdditionPrecedence
func %* (lhs: Int, rhs: String) -> String {
    lhs.counting(rhs)
}
