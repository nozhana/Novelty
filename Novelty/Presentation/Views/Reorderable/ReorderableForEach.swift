//
//  ReorderableForEach.swift
//  Novelty
//
//  Created by Nozhan A. on 7/13/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ReorderableForEach<Data, ID, Content, Preview>: View where Data: RandomAccessCollection, ID: Hashable, Content: View, Preview: View {
    var data: Data
    var id: KeyPath<Data.Element, ID>
    @Binding var active: ID?
    var onMove: (_ from: IndexSet, _ to: Int) -> Void
    @ViewBuilder var content: (Data.Element) -> Content
    @ViewBuilder var preview: (Data.Element) -> Preview
    
    @State private var isRelocating = false
    
    var body: some View {
        ForEach(data, id: id) { element in
            if Preview.self is EmptyView.Type {
                droppableContent(for: element)
                    .onDrag {
                        dragData(for: element)
                    }
            } else {
                droppableContent(for: element)
                    .onDrag {
                        dragData(for: element)
                    } preview: {
                        preview(element)
                    }
            }
        }
    }
    
    private func droppableContent(for element: Data.Element) -> some View {
        content(element)
            .opacity(active == element[keyPath: id] && isRelocating ? 0.2 : 1)
            .onDrop(of: [.text],
                    delegate: ReorderableDragRelocateDelegate(data: data.map { $0[keyPath: id] },
                                                              element: element[keyPath: id],
                                                              active: $active,
                                                              isRelocating: $isRelocating,
                                                              onMove: onMove))
    }
    
    private func dragData(for element: Data.Element) -> NSItemProvider {
        active = element[keyPath: id]
        return NSItemProvider(object: "\(element[keyPath: id])" as NSString)
    }
}

struct ReorderableDragRelocateDelegate<Data>: DropDelegate where Data: RandomAccessCollection, Data.Element: Equatable, Data.Index == Int {
    var data: Data
    var element: Data.Element
    
    @Binding var active: Data.Element?
    @Binding var isRelocating: Bool
    
    var onMove: (IndexSet, Int) -> Void
    
    func dropEntered(info: DropInfo) {
        guard element != active, let current = active else { return }
        guard let from = data.firstIndex(of: current) else { return }
        guard let to = data.firstIndex(of: element) else { return }
        isRelocating = true
        if data[to] != current {
            onMove(IndexSet(integer: from), to > from ? to + 1 : to)
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        .init(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        isRelocating = false
        active = nil
        return true
    }
}

private struct DropOutsideDelegate: DropDelegate {
    var isDropping: Binding<Bool>?
    var dropOperation: DropOperation = .cancel
    var onDropped: () -> Void
    
    func dropEntered(info: DropInfo) {
        isDropping?.wrappedValue = true
    }
    
    func dropExited(info: DropInfo) {
        isDropping?.wrappedValue = false
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        .init(operation: dropOperation)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        isDropping?.wrappedValue = false
        onDropped()
        return true
    }
}

extension View {
    func dropOutsideContainer(forTypes utTypes: [UTType] = [.text, .data], isDropping: Binding<Bool>? = nil, dropOperation: DropOperation = .cancel, onDropped: @escaping () -> Void = {}) -> some View {
        onDrop(of: utTypes, delegate: DropOutsideDelegate(isDropping: isDropping, dropOperation: dropOperation, onDropped: onDropped))
    }
}
