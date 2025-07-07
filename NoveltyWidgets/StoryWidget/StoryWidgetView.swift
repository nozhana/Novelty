//
//  StoryWidgetView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import SwiftUI

struct StoryWidgetView: View {
    var entry: StoryEntry
    
    @AppStorage(DefaultsKey.pageStyle, store: .group) private var pageStyle = PageStyle.plain
    
    @Environment(\.widgetFamily) private var widgetFamily
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(entry.story?.title ?? "Untitled Story")
                .font(pageStyle.pageTitleFont.width(.compressed))
                .minimumScaleFactor(0.5)
            
            if let tagline = entry.story?.tagline {
                Text(tagline)
                    .font(pageStyle.bodyFont)
                    .minimumScaleFactor(0.5)
            }
            
            if widgetFamily != .systemSmall {
                Spacer()
                
                Label("Continue Reading", systemImage: "book")
                    .font(pageStyle.bodyFont.bold())
                    .minimumScaleFactor(0.5)
                    .scaleEffect(0.7, anchor: .trailing)
                    .foregroundStyle(Color.accentColor.gradient)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .containerBackground(for: .widget) {
            let content = entry.story?.currentNode?.content ?? entry.story?.rootNode.content
            if let content {
                Text(content)
                    .font(pageStyle.bodyFont)
                    .foregroundStyle(pageStyle.foregroundStyle)
                    .scaleEffect(1.5)
                    .blur(radius: 8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(pageStyle.backgroundStyle)
            } else {
                LinearGradient(colors: [.teal, .cyan], startPoint: .bottomLeading, endPoint: .topTrailing)
            }
        }
    }
}
