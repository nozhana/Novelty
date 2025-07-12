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

extension View {
    @ViewBuilder
    func navigationTitle(_ binding: Binding<String?>, default defaultValue: String, editable: Bool) -> some View {
        if editable {
            navigationTitle(Binding { (binding.wrappedValue?.isEmpty ?? true) ? defaultValue : binding.wrappedValue! } set: { binding.wrappedValue = $0 })
        } else {
            navigationTitle((binding.wrappedValue?.isEmpty ?? true) ? defaultValue : binding.wrappedValue!)
        }
    }
}
