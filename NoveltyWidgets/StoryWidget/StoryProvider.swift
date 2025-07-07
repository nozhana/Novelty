//
//  StoryProvider.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import WidgetKit

struct StoryProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> StoryEntry {
        context.isPreview ? .preview : .placeholder
    }
    
    func snapshot(for configuration: StoryConfigurationIntent, in context: Context) async -> StoryEntry {
        let database = DatabaseManager.shared
        
        if context.isPreview {
            return .preview
        } else if let defaultEntityId = await StoryQuery().defaultResult()?.id,
                  let story = await database.fetchFirst(Story.self, predicate: #Predicate { $0.id == defaultEntityId }) {
            return .init(date: .now, story: story)
        } else {
            return .placeholder
        }
    }
    
    func timeline(for configuration: StoryConfigurationIntent, in context: Context) async -> Timeline<StoryEntry> {
        let database = DatabaseManager.shared
        var story: Story?
        if let id = configuration.story?.id {
            story = await database.fetchFirst(predicate: #Predicate { $0.id == id })
        }
        var entries = [StoryEntry]()
        let currentDate = Date.now
        for hourOffset in stride(from: 0, to: 24, by: 4) {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = StoryEntry(date: entryDate, story: story)
            entries.append(entry)
        }
        return Timeline(entries: entries, policy: .after(currentDate.advanced(by: 24 * 3600)))
    }
}
