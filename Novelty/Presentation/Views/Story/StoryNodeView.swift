//
//  StoryNodeView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/6/25.
//

import SwiftUI

struct StoryNodeView: View {
    var node: StoryNode
    var editable: Bool = true
    var onSelected: (StoryNode) -> Void
    
    @EnvironmentObject private var database: DatabaseManager
    @Environment(\.pageStyle) private var pageStyle
    
    @State private var editButtonPopupLocation: CGPoint?
    @State private var isEditing = false
    
    @FocusState private var focusItem: FocusItem?
    
    private let quickLinkTip = QuickLinkTip()
    private let editStoryTip = EditStoryTip()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Group {
                        if isEditing {
                            VStack(alignment: .leading, spacing: 4) {
                                TextField("Untitled Page", text: Binding { node.title ?? "" } set: { node.title = $0 })
                                    .multilineTextAlignment(pageStyle.pageTitleTextAlignment)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusItem = .linkTitle
                                    }
                                    .focused($focusItem, equals: .title)
                                    .textFieldStyle(.plain)
                                
                                TextField("Untitled Page", text: Binding { node.linkTitle ?? node.title ?? "" } set: { node.linkTitle = $0 })
                                    .multilineTextAlignment(pageStyle.pageTitleTextAlignment)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusItem = .content
                                    }
                                    .focused($focusItem, equals: .linkTitle)
                                    .textFieldStyle(.plain)
                                    .safeAreaInset(edge: .leading, spacing: 8) {
                                        Image(systemName: "link")
                                    }
                                    .font(.system(.subheadline, weight: .bold))
                                    .foregroundStyle(node.linkTitle == nil ? .secondary : .primary)
                            }
                        } else {
                            Text((node.title?.isEmpty ?? true) ? "Untitled Page" : node.title!)
                        }
                    }
                    .contentTransition(.numericText())
                    .font(pageStyle.pageTitleFont)
                    .foregroundStyle(pageStyle.foregroundStyle)
                    .visualEffect { content, proxy in
                        let minY = proxy.frame(in: .scrollView).minY
                        let scale = 1.interpolated(towards: 1.8, amount: (minY / 300).clamped(to: 0...1))
                        return content
                            .scaleEffect(scale, anchor: pageStyle.pageTitleScaleAnchor)
                    }
                    .frame(maxWidth: .infinity, alignment: pageStyle.pageTitleAlignment)
                }
                .padding(.bottom, 8)
                
                Group {
                    if isEditing {
                        @Bindable var bindableNode = node
                        TextEditor(text: $bindableNode.content)
                            .textEditorStyle(.plain)
                            .focused($focusItem, equals: .content)
                            .padding(.horizontal, -6)
                            .padding(.vertical, -10)
                            .containerRelativeFrame(.vertical, count: 5, span: 3, spacing: 32)
                    } else {
                        if let markdown = try? node.markdown {
                            Text(markdown)
                        } else {
                            Text(node.content)
                        }
                    }
                }
                .contentTransition(.interpolate)
                .font(pageStyle.bodyFont)
                .foregroundStyle(pageStyle.foregroundStyle)
                .popoverTip(editStoryTip)
                .tipImageSize(.init(width: 24, height: 24))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                
                if isEditing {
                    FlowLayout(spacing: 16) {
                        ForEach(node.children) { child in
                            Label(child.title ?? "Untitled", systemImage: "link")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.primary)
                                .safeAreaInset(edge: .trailing) {
                                    Button {
                                        withAnimation(.bouncy) {
                                            database.deleteStoryNode(child)
                                        }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .imageScale(.small)
                                            .foregroundStyle(.red)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Capsule().stroke(.separator))
                                .background(in: .capsule)
                        }
                        Menu("Link", systemImage: "link.badge.plus") {
                            Button("New Page", systemImage: "document.badge.plus.fill") {
                                database.createStoryNode(in: node)
                            }
                            Divider()
                            ForEach(node.story?.nodes ?? []) { candidate in
                                if !node.children.contains(candidate) {
                                    Button(candidate.title ?? "Untitled") {
                                        node.children.append(candidate)
                                        database.saveChanges()
                                    }
                                }
                            }
                        } primaryAction: {
                            database.createStoryNode(in: node)
                        }
                        .font(.system(size: 13, weight: .medium))
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .popoverTip(quickLinkTip)
                        .tipImageSize(.init(width: 24, height: 24))
                    }
                } else {
                    FlowLayout(spacing: 16) {
                        ForEach(node.children) { child in
                            Button(child.linkTitle ?? child.title ?? "Untitled") {
                                onSelected(child)
                            }
                            .font(pageStyle.bodyFont)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: UIScreen.main.bounds.width - 32, alignment: .leading)
                        }
                    }
                }
            }
        }
        .contentMargins(20, for: .scrollContent)
        .background(pageStyle.backgroundStyle)
        .onTapGesture {
            focusItem = nil
        }
        .onTapGesture(count: 2) { point in
            guard editable, !isEditing else { return }
            withAnimation(.bouncy) {
                editButtonPopupLocation = point
            } completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.snappy) {
                        self.editButtonPopupLocation = nil
                    }
                }
            }
        }
        .overlay {
            if let editButtonPopupLocation {
                Image(systemName: "pencil")
                    .imageScale(.large)
                    .padding(12)
                    .background(Circle().stroke(.secondary))
                    .background(in: .circle)
                    .position(editButtonPopupLocation)
                    .onTapGesture {
                        withAnimation(.snappy) {
                            isEditing = true
                            self.editButtonPopupLocation = nil
                        }
                    }
                    .transition(.offset(y: 64).combined(with: .opacity))
            }
        }
        .toolbar {
            if isEditing {
                Button("Done", systemImage: "checkmark") {
                    withAnimation(.snappy) {
                        isEditing = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .font(.system(size: 15, weight: .medium))
            }
        }
    }
}

extension StoryNodeView {
    enum FocusItem {
        case title, linkTitle, content
    }
}

#Preview {
    NavigationStack {
        StoryNodeView(node: .mock1) { node in
            print("\(node) selected")
        }
    }
}
