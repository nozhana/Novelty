//
//  VerticalLabelStyle.swift
//  Novelty
//
//  Created by Nozhan A. on 7/11/25.
//

import SwiftUI

struct VerticalLabelStyle: LabelStyle {
    var alignment: HorizontalAlignment = .center
    var spacing: CGFloat = 10
    
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: alignment, spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}

extension LabelStyle where Self == VerticalLabelStyle {
    static var vertical: VerticalLabelStyle { .init() }
    
    static func vertical(alignment: HorizontalAlignment = .center, spacing: CGFloat = 10) -> VerticalLabelStyle {
        .init(alignment: alignment, spacing: spacing)
    }
}
