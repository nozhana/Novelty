//
//  StoryEntry.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import WidgetKit

struct StoryEntry: TimelineEntry {
    var date: Date = .now
    var isPreview: Bool = false
    var story: Story?
}

extension StoryEntry {
    static let placeholder = StoryEntry()
    static let preview = {
        var entry = StoryEntry(isPreview: true)
        entry.story = .permissionToSwap
        return entry
    }()
}
