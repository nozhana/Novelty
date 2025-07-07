//
//  StoriesListView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import SwiftData
import SwiftUI

struct StoriesListView: View {
    @EnvironmentObject private var database: DatabaseManager
    
    @State private var path = [Story]()
    
    @Query(sort: [.init(\Story.created, order: .reverse)], animation: .smooth) private var stories: [Story]
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(stories) { story in
                    NavigationLink(value: story) {
                        LabeledContent(story.title ?? "Untitled Story") {
                            Text(story.nodes.count %* "Page")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { offsets in
                    let storiesToDelete = offsets.reduce(into: [Story]()) { $0.append(stories[$1]) }
                    database.deleteStories(storiesToDelete)
                }
            }
            .navigationDestination(for: Story.self) { story in
                StoryView(story: story)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New Story", systemImage: "pencil.tip.crop.circle.badge.plus.fill") {
                        let story = database.createStory()
                        path = [story]
                    }
                }
            }
            .navigationTitle("All Stories")
        }
    }
}

#Preview {
    StoriesListView()
        .database(.preview)
}
