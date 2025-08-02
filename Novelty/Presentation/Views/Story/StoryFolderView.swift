//
//  StoryFolderView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct StoryFolderView: View {
    var folder: StoryFolder
    
    @Query private var stories: [Story]
    
    @EnvironmentObject private var database: DatabaseManager
    @EnvironmentObject private var router: Router
    
    @State private var isDropping = false
    
    @State private var invalidator = 0
    
    init(folder: StoryFolder) {
        self.folder = folder
        let folderID = folder.id
        self._stories = .init(filter: #Predicate { $0.folder?.id == folderID }, sort: [.init(\.updated, order: .reverse)], animation: .smooth)
    }
    
    var body: some View {
        @Bindable var bindable = folder
        List {
            Group {
                if stories.isEmpty {
                    ContentUnavailableView("No stories", systemImage: "books.vertical", description: Text("Add a new story by tapping the \(Image(systemName: "pencil.tip.crop.circle.badge.plus.fill")) button."))
                        .foregroundStyle(.secondary)
                        .frame(minHeight: UIScreen.main.bounds.height * 0.6)
                        .listRowBackground(Color.clear)
                        .listRowInsets(.init())
                } else {
                    ForEach(stories) { story in
                        NavigationLink(value: story) {
                            LabeledContent {
                                Text("^[\(story.nodes.count) Page](inflect: true)")
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
                        .onDrag {
                            NSItemProvider(object: story.id.uuidString as NSString)
                        }
                    }
                    .onDelete { offsets in
                        let storiesToDelete = offsets.reduce(into: [Story]()) { $0.append(stories[$1]) }
                        database.deleteStories(storiesToDelete)
                    }
                }
            }
            .onDrop(of: [.text], isTargeted: $isDropping) { providers in
                for provider in providers {
                    guard provider.hasItemConformingToTypeIdentifier(UTType.text.identifier) else { continue }
                    provider.loadItem(forTypeIdentifier: UTType.text.identifier) { item, error in
                        if let error {
                            print("Failed to import story: \(error)")
                            return
                        }
                        
                        DispatchQueue.main.async {
                            guard let data = item as? Data,
                                  let uuidString = String(data: data, encoding: .utf8),
                                  let uuid = UUID(uuidString: uuidString),
                                  let story = database.fetchFirst(Story.self, predicate: #Predicate { $0.id == uuid }) else { return }
                            let previousFolder = story.folder
                            database.transaction("Move Story", for: story.id) {
                                story.folder = folder
                            } rollback: {
                                story.folder = previousFolder
                            }
                        }
                    }
                }
                invalidator += 1
                
                return true
            }
            .invalidatable(trigger: invalidator)
        }
        .toolbar {
            Button("New Story", systemImage: "pencil.tip.crop.circle.badge.plus.fill") {
                let story = database.createStory(in: folder)
                router.navigationPath.append(story)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Binding($bindable.title), default: "Untitled Folder", editable: true)
    }
}
