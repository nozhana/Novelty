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
    @EnvironmentObject private var router: Router
    
    @Query(sort: [.init(\Story.created, order: .reverse)], animation: .smooth) private var stories: [Story]
    
    var body: some View {
        NavigationStack(path: $router.stories) {
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
#if DEBUG
                if !database.storyExists(.mockStory) {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu("Developer Settings", systemImage: "hammer.fill") {
                            Button("Add mock stories", systemImage: "document.badge.plus") {
                                database.save(Story.mockStory)
                                database.save(Story.permissionToSwap)
                            }
                        }
                    }
                }
#endif
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("New Story", systemImage: "pencil.tip.crop.circle.badge.plus.fill") {
                        let story = database.createStory()
                        router.stories.append(story)
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
