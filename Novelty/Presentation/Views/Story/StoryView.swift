//
//  StoryView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/6/25.
//

import SwiftUI

struct StoryView: View {
    var story: Story
    var editable: Bool = true
    
    @EnvironmentObject private var database: DatabaseManager
    
    @State private var showInfo = false
    @State private var showTree = false
    @State private var fullscreen = false
    @State private var colorScheme: ColorScheme?
    
    @AppStorage(DefaultsKey.pageStyle, store: .group) private var pageStyle = PageStyle.plain
    
    var body: some View {
        let node = story.currentNode ?? story.rootNode
        @UndoBindable(target: database.undoManager, manager: database.undoManager.managers[story.id]!, actionName: "Rename Story") var bindable = story
        Group {
            if showInfo {
                List {
                    Section {
                        TextField("Title", text: Binding { story.title ?? "" } set: { story.title = $0 }, prompt: Text(story.title ?? "My Story"))
                            .safeAreaInset(edge: .top, alignment: .leading, spacing: 6) {
                                Text("Title")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        TextField("Tagline", text: Binding { story.tagline ?? "" } set: { story.tagline = $0 }, prompt: Text(story.tagline ?? "A beautiful story."))
                            .safeAreaInset(edge: .top, alignment: .leading, spacing: 6) {
                                Text("Tagline")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        TextField("Author", text: Binding { story.author ?? "" } set: { story.author = $0 }, prompt: Text(story.author ?? "John Doe"))
                            .safeAreaInset(edge: .top, alignment: .leading, spacing: 6) {
                                Text("Author")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                    } header: {
                        Label("Metadata", systemImage: "info.circle")
                    }
                }
            } else if showTree {
                let previousNode = story.currentNode
                StoryTreeView(story: story) { selectedNode in
                    database.transaction("Jump to page", for: story.id) {
                        withAnimation(.snappy) {
                            story.currentNode = selectedNode
                        }
                    } rollback: {
                        withAnimation(.snappy) {
                            story.currentNode = previousNode
                        }
                    }
                    withAnimation(.snappy) {
                        showTree = false
                    }
                }
            } else {
                StoryNodeView(node: node, editable: editable) { selectedNode in
                    let previousNode = story.currentNode
                    database.transaction("Go to page", for: story.id) {
                        withAnimation(.snappy) {
                            story.currentNode = selectedNode
                        }
                    } rollback: {
                        withAnimation(.snappy) {
                            story.currentNode = previousNode
                        }
                    }
                }
                .environment(\.pageStyle, pageStyle)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if fullscreen {
                Button {
                    withAnimation(.snappy) {
                        fullscreen = false
                    }
                } label: {
                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                        .padding(16)
                        .background(.ultraThinMaterial, in: .circle)
                }
                .transition(.scale(0, anchor: .bottomTrailing))
                .padding(24)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Toggle("Story Tree", systemImage: "arrow.branch", isOn: $showTree.animation(.interactiveSpring))
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                if showInfo {
                    Button("Done", systemImage: "checkmark") {
                        showInfo = false
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                } else {
                    Menu("Options", systemImage: "ellipsis") {
                        Section("Story") {
                            Button("New page", systemImage: "document.badge.plus") {
                                let newNode = database.createStoryNode(in: node)
                                database.transaction("Create new page", for: story.id) {
                                    story.currentNode = newNode
                                } rollback: {
                                    story.currentNode = newNode.parentNode ?? story.rootNode
                                    database.deleteStoryNode(newNode)
                                }
                            }
                            
                            Button(database.undoManager.undoMenuItemTitle(for: story.id), systemImage: "arrow.uturn.backward") {
                                withAnimation(.snappy) {
                                    database.undo(for: story.id)
                                }
                            }
                            .buttonRepeatBehavior(.enabled)
                            .disabled(!database.undoManager.canUndo(for: story.id))
                            if node != story.rootNode {
                                Button("Reset", systemImage: "arrow.clockwise") {
                                    let previousNode = story.currentNode
                                    database.transaction("Reset Story", for: story.id) {
                                        story.currentNode = story.rootNode
                                    } rollback: {
                                        story.currentNode = previousNode
                                    }
                                }
                            }
                            Button("Story Info", systemImage: "info.circle") {
                                showInfo = true
                            }
                        }
                        Picker("Page Style", selection: $pageStyle) {
                            ForEach(PageStyle.allCases) { style in
                                Label(style.menuTitle, systemImage: style.menuSystemImage)
                                    .tag(style)
                            }
                        }
                        .pickerStyle(.palette)
                        Section("Display") {
                            Toggle("Fullscreen", systemImage: "arrow.up.left.and.arrow.down.right", isOn: $fullscreen.animation(.snappy))
                            Toggle("Dark mode", systemImage: "circle.lefthalf.striped.horizontal", isOn: Binding { colorScheme == .dark } set: { colorScheme = $0 ? .dark : .light })
                        }
                        Section("Share") {
                            Button("Copy URL", systemImage: "link") {
                                UIPasteboard.general.url = URL(string: "novelty:\(story.id)")
                            }
                            ShareLink("Share URL", item: URL(string: "novelty:\(story.id)")!, message: Text("Novelty: \(story.title ?? "Untitled Story")"))
                            ShareLink("Share Story Bundle file", item: StoryDTO(story: story), message: Text("Novelty: \(story.title ?? "Untitled Story")"), preview: .init(story.title ?? "Untitled Story", image: Image(systemName: "book.pages")))
                        }
                        Section {
                            Button("Delete page", systemImage: "trash.fill", role: .destructive) {
                                guard let currentNode = story.currentNode, currentNode != story.rootNode else { return }
                                let parentNode = currentNode.parentNode
                                database.transaction("Delete page", for: story.id) {
                                    story.currentNode = parentNode
                                    database.deleteStoryNode(currentNode)
                                } rollback: {
                                    parentNode?.children.append(currentNode)
                                    database.save(currentNode)
                                    story.currentNode = currentNode
                                }
                            }
                            .foregroundStyle(.red)
                            .disabled(story.currentNode == nil || story.currentNode == story.rootNode)
                        } header: {
                            Label("Danger Zone", systemImage: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
        }
        .toolbarVisibility(fullscreen ? .hidden : .visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(editable ? .inline : .large)
        .navigationTitle($bindable.title, default: "Untitled Story", editable: editable)
        .preferredColorScheme(colorScheme)
    }
}

#Preview {
    NavigationStack {
        StoryView(story: .mockStory)
    }
    .database(.preview)
}

private extension View {
    @ViewBuilder
    func navigationTitle(_ binding: Binding<String?>, default defaultValue: String, editable: Bool) -> some View {
        if editable {
            navigationTitle(Binding { binding.wrappedValue ?? defaultValue } set: { binding.wrappedValue = $0 })
        } else {
            navigationTitle(binding.wrappedValue ?? defaultValue)
        }
    }
}
