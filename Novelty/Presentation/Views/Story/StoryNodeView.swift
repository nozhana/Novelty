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
    @EnvironmentObject private var alerter: AlertManager
    @Environment(\.pageStyle) private var pageStyle
    @Environment(\.layoutDirection) private var layoutDirection
    
    @State private var editButtonPopupLocation: CGPoint?
    @State private var isEditing = false
    @State private var previousContent: String?
    
    @FocusState private var focusItem: FocusItem?
    
    private let quickLinkTip = QuickLinkTip()
    private let editStoryTip = EditStoryTip()
    
    init(node: StoryNode, editable: Bool = true, onSelected: @escaping (StoryNode) -> Void) {
        self.node = node
        self.editable = editable
        self.onSelected = onSelected
        if editable, node.title == nil || node.content.isEmpty {
            _isEditing = .init(initialValue: true)
        }
    }
    
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
                                        focusItem = .content
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
                        @Bindable var bindable = node
                        TextEditor(text: $bindable.content)
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
                            Label(child.titleOrUntitled, systemImage: "link")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.primary)
                                .safeAreaInset(edge: .trailing) {
                                    Button {
                                        withAnimation(.bouncy) {
                                            node.children.removeAll(of: child)
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
                            ForEach(node.story?.nodes.filter { $0 != node && !node.children.contains($0) && node.story?.rootNode != $0 } ?? []) { candidate in
                                Button(candidate.title ?? "Untitled Page") {
                                    if let parentNode = candidate.parentNode {
                                        alerter.present(title: "Page already referenced", message: "This page is already referenced by another page:\n \(parentNode.title ?? "Untitled Page")\n\nIf you link to this page from here, the other reference will be removed.", actions: [
                                            .cancel {},
                                            .destructive("Remove reference and link") {
                                                candidate.parentNode = node
                                                database.saveChanges()
                                            }
                                        ])
                                    } else {
                                        candidate.parentNode = node
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
                            Button(child.linkTitle ?? child.titleOrUntitled) {
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
                    .position(layoutDirection == .rightToLeft
                              ? CGPoint(x: UIScreen.main.bounds.width - editButtonPopupLocation.x,
                                        y: editButtonPopupLocation.y)
                              : editButtonPopupLocation)
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
#if targetEnvironment(macCatalyst)
            Toggle("Edit", systemImage: "pencil", isOn: $isEditing.animation(.smooth))
#endif
            if isEditing {
                Button("Done", systemImage: "checkmark") {
                    if let previousContent, let story = node.story {
                        database.registerUndo("Update page content", for: story.id) {
                            node.content = previousContent
                        }
                        self.previousContent = nil
                    }
                    withAnimation(.snappy) {
                        isEditing = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .font(.system(size: 15, weight: .medium))
                .onAppear {
                    previousContent = node.content
                }
            }
        }
        .onChange(of: isEditing, initial: true) { _, newValue in
            if newValue {
                if node.title == nil || node.title?.isEmpty == true {
                    focusItem = .title
                } else {
                    focusItem = .content
                }
            }
        }
        .onChange(of: node) { _, newValue in
            if editable, newValue.title == nil || newValue.content.isEmpty {
                isEditing = true
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
