//
//  View+.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import SwiftUI

extension View {
    func asButton(role: ButtonRole? = nil, action: @escaping () -> Void) -> Button<Self> {
        Button(role: role, action: action) { self }
    }
}
