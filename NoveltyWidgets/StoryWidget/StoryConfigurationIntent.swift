//
//  StoryConfigurationIntent.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import AppIntents

struct StoryConfigurationIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Story"
    static let description: IntentDescription? = "Choose a story to display on this widget."
    
    @Parameter(title: "Story")
    var story: StoryEntity?
}
