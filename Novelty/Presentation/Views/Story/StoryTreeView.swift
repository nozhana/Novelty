//
//  StoryTreeView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import SwiftUI

struct StoryTreeView: View {
    var story: Story
    var onSelected: ((StoryNode) -> Void)?
    
    @ViewBuilder
    func nodeView(_ node: StoryNode) -> some View {
        Text((node.title?.isEmpty ?? true) ? "Untitled" : node.title!)
            .font(.system(size: 15, weight: .medium))
            .safeAreaInset(edge: .bottom, spacing: .zero) {
                if node == story.currentNode {
                    Text("You are here")
                        .font(.caption.weight(.heavy))
                        .fontWidth(.condensed)
                        .foregroundStyle(Color.red.gradient)
                        .padding(.top, 4)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 10).stroke(node == story.currentNode ? Color.red.gradient : Color.accentColor.gradient))
            .background(.background.secondary, in: .rect(cornerRadius: 10))
            .asButton {
                onSelected?(node)
            }
    }
    
    var body: some View {
        ScrollView([.vertical, .horizontal]) {
            VStack(spacing: .zero) {
                Text("Start")
                    .textCase(.uppercase)
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(.pink.gradient, in: .capsule)
                    .background(alignment: .bottom) {
                        Rectangle()
                            .fill(.pink.gradient)
                            .frame(width: 1, height: 25)
                            .fixedSize()
                            .frame(width: 1, height: 1, alignment: .top)
                    }
                    .padding(.bottom, 24)
                
                let tree = Tree.from(story.rootNode, children: \.children)
                TreeView(tree, horizontalSpacing: 18, verticalSpacing: 24, lineShapeStyle: Color.accentColor.gradient) { node in
                    nodeView(node)
                }
                let orphans = story.nodes.filter { $0.parentNode == nil && $0 != story.rootNode }
                if !orphans.isEmpty {
                    VStack(spacing: 24) {
                        Text("Orphans")
                            .font(.system(.caption, weight: .bold))
                        HStack(spacing: 18) {
                            ForEach(orphans) { node in
                                nodeView(node)
                            }
                        }
                    }
                    .padding(.top, 36)
                }
            }
        }
        .contentMargins(20, for: .scrollContent)
    }
}

#Preview {
    StoryTreeView(story: .mockStory)
}
