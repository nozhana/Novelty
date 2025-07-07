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
                TreeView(tree: tree, horizontalSpacing: 18, verticalSpacing: 24, lineShapeStyle: Color.accentColor.gradient) { node in
                    Text(node.title ?? "Untitled")
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
            }
        }
        .contentMargins(20, for: .scrollContent)
    }
}

#Preview {
    StoryTreeView(story: .mockStory)
}
