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
    
    @State private var dropState = DropState.idle
    
    @State private var showSettings = false
    
    @State private var showNearbyUsers = false
    
    var body: some View {
        NavigationStack(path: $router.stories) {
            List {
                ForEach(stories) { story in
                    NavigationLink(value: story) {
                        LabeledContent {
                            Text(story.nodes.count %* "Page")
                                .foregroundStyle(.secondary)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(story.title ?? "Untitled Story")
                                    .font(.headline)
                                if let tagline = story.tagline {
                                    Text(tagline)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                if let author = story.author {
                                    Text(author)
                                        .font(.caption.bold())
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                    }
                }
                .onDelete { offsets in
                    let storiesToDelete = offsets.reduce(into: [Story]()) { $0.append(stories[$1]) }
                    database.deleteStories(storiesToDelete)
                }
            }
            .safeAreaInset(edge: .bottom) {
                DropTargetView(dropState: $dropState)
                    .onDrop(of: [.noveltyStoryBundle], delegate: StoryBundleDropDelegate(dropState: $dropState))
                    .padding(16)
                    .frame(height: 240)
            }
            .navigationDestination(for: Story.self) { story in
                StoryView(story: story)
            }
            .fullScreenCover(isPresented: $showNearbyUsers) {
                NearbyView()
                    .environmentObject(NearbyConnectionManager.default())
            }
            .fullScreenCover(isPresented: $showSettings) {
                SettingsView()
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Nearby", systemImage: "wifi") {
                        showNearbyUsers = true
                    }
                    Button("Settings", systemImage: "gearshape.fill") {
                        showSettings = true
                    }
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
