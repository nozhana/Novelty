//
//  PageStyle.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import SwiftUI

enum PageStyle: String, Identifiable, CaseIterable {
    case plain, easy, newspaper, typewriter
    
    var id: String { rawValue }
}

extension PageStyle {
    var menuTitle: String {
        switch self {
        case .plain:
            "Plain"
        case .easy:
            "Easy"
        case .newspaper:
            "Newspaper"
        case .typewriter:
            "Typewriter"
        }
    }
    
    var menuSystemImage: String {
        switch self {
        case .plain:
            "document"
        case .easy:
            "document.fill"
        case .newspaper:
            "newspaper"
        case .typewriter:
            "keyboard"
        }
    }
    
    var pageTitleFont: Font {
        switch self {
        case .plain:
                .system(.title, design: .serif, weight: .heavy)
        case .easy:
                .system(.title, design: .default, weight: .heavy)
        case .newspaper:
                .system(.title, design: .serif, weight: .black)
        case .typewriter:
                .system(.title, design: .monospaced, weight: .heavy)
        }
    }
    
    var pageTitleAlignment: Alignment {
        switch self {
        case .newspaper: .leading
        default: .center
        }
    }
    
    var pageTitleTextAlignment: TextAlignment {
        switch pageTitleAlignment {
        case .trailing: .trailing
        case .center: .center
        default: .leading
        }
    }
    
    var pageTitleScaleAnchor: UnitPoint {
        switch pageTitleAlignment {
        case .trailing: .bottomTrailing
        case .center: .bottom
        default: .bottomLeading
        }
    }
    
    var bodyFont: Font {
        switch self {
        case .plain:
                .system(size: 17)
        case .easy:
                .system(size: 19)
        case .newspaper:
                .system(size: 18, weight: .medium, design: .serif)
        case .typewriter:
                .system(size: 17, design: .monospaced)
        }
    }
    
    var foregroundStyle: some ShapeStyle {
        let anyStyle: any ShapeStyle = switch self {
        case .plain:
                .primary
        case .easy:
                .primary.opacity(0.9)
        case .newspaper:
                .primary
        case .typewriter:
                .primary
        }
        return AnyShapeStyle(anyStyle)
    }
    
    var backgroundStyle: some ShapeStyle {
        let anyStyle: any ShapeStyle = switch self {
        case .plain:
                .background
        case .easy:
                .background.secondary
        case .newspaper:
                .background.secondary
        case .typewriter:
                .background
        }
        return AnyShapeStyle(anyStyle)
    }
}

extension EnvironmentValues {
    @Entry var pageStyle = PageStyle.plain
}
