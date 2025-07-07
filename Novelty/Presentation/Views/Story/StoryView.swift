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
    
    @State private var showTree = false
    @State private var fullscreen = false
    
    @AppStorage(DefaultsKey.pageStyle) private var pageStyle = PageStyle.plain
    
    var body: some View {
        let node = story.currentNode ?? story.rootNode
        @Bindable var bindable = story
        Group {
            if showTree {
                let previousNode = story.currentNode
                StoryTreeView(story: story) { selectedNode in
                    database.transaction("Jump to page") { _ in
                        withAnimation(.snappy) {
                            story.currentNode = selectedNode
                        }
                    } rollback: { _ in
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
                    database.transaction("Go to page") { _ in
                        withAnimation(.snappy) {
                            story.currentNode = selectedNode
                        }
                    } rollback: { _ in
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
                Menu("Options", systemImage: "ellipsis") {
                    Section("Story") {
                        Button(database.undoManager.undoMenuItemTitle, systemImage: "arrow.uturn.backward") {
                            withAnimation(.snappy) {
                                database.undo()
                            }
                        }
                        .buttonRepeatBehavior(.enabled)
                        .disabled(!database.undoManager.canUndo)
                        if node != story.rootNode {
                            Button("Reset", systemImage: "arrow.clockwise") {
                                let previousNode = story.currentNode
                                database.transaction("Reset Story") { _ in
                                    story.currentNode = story.rootNode
                                } rollback: { _ in
                                    story.currentNode = previousNode
                                }
                            }
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
                    }
                }
            }
        }
        .toolbarVisibility(fullscreen ? .hidden : .visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(editable ? .inline : .large)
        .navigationTitle($bindable.title, editable: editable)
    }
}

#Preview {
    StoryView(story: .mockStory)
        .database(.preview)
}

private extension View {
    @ViewBuilder
    func navigationTitle(_ binding: Binding<String?>, editable: Bool) -> some View {
        if editable {
            navigationTitle(Binding { binding.wrappedValue ?? "Untitled Story" } set: { binding.wrappedValue = $0 })
        } else {
            navigationTitle(binding.wrappedValue ?? "Untitled Story")
        }
    }
}
