//
//  TreeView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import SwiftUI

struct TreeView<T, ID, Content>: View where Content: View, ID: Hashable {
    var tree: Tree<T>
    var id: KeyPath<T, ID>
    var horizontalSpacing: CGFloat = 12
    var verticalSpacing: CGFloat = 12
    var lineStrokeStyle = StrokeStyle(lineWidth: 1)
    var lineShapeStyle: any ShapeStyle = .primary
    @ViewBuilder var content: (T) -> Content
    
    private var treeKeypath: KeyPath<Tree<T>, ID> {
        let kp = \Tree<T>.value
        return kp.appending(path: id)
    }
    
    private typealias AnchorKey = PreferenceDictionary<ID, Anchor<CGPoint>>
    
    var body: some View {
        VStack(spacing: verticalSpacing) {
            content(tree.value)
                .anchorPreference(key: AnchorKey.self, value: .center) { anchor in
                    [tree[keyPath: treeKeypath]: anchor]
                }
            HStack(alignment: .top, spacing: horizontalSpacing) {
                ForEach(tree.children, id: treeKeypath) { child in
                    TreeView(tree: child, id: id, horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing, lineStrokeStyle: lineStrokeStyle, lineShapeStyle: lineShapeStyle, content: content)
                }
            }
        }
        .backgroundPreferenceValue(AnchorKey.self) { value in
            GeometryReader { proxy in
                ForEach(tree.children, id: treeKeypath) { child in
                    Line(from: proxy[value[tree[keyPath: treeKeypath]]!],
                         to: proxy[value[child[keyPath: treeKeypath]]!])
                    .stroke(AnyShapeStyle(lineShapeStyle), style: lineStrokeStyle)
                }
            }
        }
    }
}

private struct PreferenceDictionary<Key, Value>: PreferenceKey where Key: Hashable {
    static var defaultValue: [Key: Value] { [:] }
    
    static func reduce(value: inout [Key : Value], nextValue: () -> [Key : Value]) {
        value.merge(nextValue()) { $1 }
    }
}

extension TreeView {
    init(tree: Tree<T>, horizontalSpacing: CGFloat = 12, verticalSpacing: CGFloat = 12, lineStrokeStyle: StrokeStyle = .init(lineWidth: 1), lineShapeStyle: any ShapeStyle = .primary, @ViewBuilder content: @escaping (T) -> Content) where T: Identifiable, T.ID == ID {
        self.init(tree: tree, id: \.id, horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing, lineStrokeStyle: lineStrokeStyle, lineShapeStyle: lineShapeStyle, content: content)
    }
}

#Preview {
    let tree = Tree(1) {
        Tree(2) {
            Tree(3)
            Tree(4)
        }
        Tree(5) {
            Tree(6)
        }
        Tree(7)
        Tree(8) {
            Tree(9)
            Tree(10)
        }
    }
    
    TreeView(tree: tree, id: \.self) { integer in
        Text(integer, format: .number)
            .font(.headline.bold())
            .padding(10)
            .background(Circle().stroke())
            .background(in: .circle)
    }
}
