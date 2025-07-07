//
//  StoryWidget.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import SwiftData
import SwiftUI
import WidgetKit

struct StoryWidget: Widget {
    let kind = "com.nozhana.Novelty.NoveltyWidgets.StoryWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: StoryConfigurationIntent.self, provider: StoryProvider()) { entry in
            StoryWidgetView(entry: entry)
                .modelContainer(DatabaseManager.shared.container)
                .widgetURL(URL(string: "novelty:\(entry.story?.id.uuidString ?? "")"))
        }
    }
}

#Preview("Story", as: .systemSmall, widget: {
    StoryWidget()
}, timeline: {
    StoryEntry.placeholder
    StoryEntry.preview
})
