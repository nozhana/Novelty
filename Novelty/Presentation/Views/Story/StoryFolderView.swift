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
                        .draggable(StoryDTO(story: story))
                    }
                    .onDelete { offsets in
                        let storiesToDelete = offsets.reduce(into: [Story]()) { $0.append(stories[$1]) }
                        database.deleteStories(storiesToDelete)
                    }
                }
            }
            .onDrop(of: [.noveltyStoryBundle], isTargeted: $isDropping) { providers in
                guard let provider = providers.first(where: { $0.hasRepresentationConforming(toTypeIdentifier: UTType.noveltyStoryBundle.identifier) }) else { return false }
                provider.loadItem(forTypeIdentifier: UTType.noveltyStoryBundle.identifier) { item, error in
                    if let error {
                        print("Failed to import story: \(error)")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        if let url = item as? URL,
                           url.startAccessingSecurityScopedResource(),
                           let data = try? Data(contentsOf: url),
                           let base64DecodedData = Data(base64Encoded: data),
                           let decodedID = (try? JSONDecoder().decode(StoryDTO.self, from: base64DecodedData))?.id,
                           let story = database.fetchFirst(Story.self, predicate: #Predicate { $0.id == decodedID }) {
                            story.folder = folder
                            database.saveChanges()
                        } else if let data = item as? Data,
                                  let base64DecodedData = Data(base64Encoded: data),
                                  let decodedID = (try? JSONDecoder().decode(StoryDTO.self, from: base64DecodedData))?.id,
                                  let story = database.fetchFirst(Story.self, predicate: #Predicate { $0.id == decodedID }) {
                            story.folder = folder
                            database.saveChanges()
                            invalidator += 1
                        }
                    }
                }
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
        .navigationTitle(Binding($bindable.title), default: "Untitled Folder", editable: true)
    }
}
