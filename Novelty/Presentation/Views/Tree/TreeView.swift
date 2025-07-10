//
//  TreeView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/7/25.
//

import SwiftUI

struct TreeView<T, ID, Content>: View where Content: View, ID: Hashable {
    var trees: [Tree<T>]
    var id: KeyPath<T, ID>
    var horizontalSpacing: CGFloat = 12
    var verticalSpacing: CGFloat = 12
    var lineStrokeStyle = StrokeStyle(lineWidth: 1)
    var lineShapeStyle: any ShapeStyle = .primary
    var curvedConnector = false
    @ViewBuilder var content: (T) -> Content
    
    init(_ trees: [Tree<T>], id: KeyPath<T, ID>, horizontalSpacing: CGFloat = 12, verticalSpacing: CGFloat = 12, lineStrokeStyle: StrokeStyle = StrokeStyle(lineWidth: 1), lineShapeStyle: any ShapeStyle = .primary, curvedConnector: Bool = false, content: @escaping (T) -> Content) {
        self.trees = trees
        self.id = id
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.lineStrokeStyle = lineStrokeStyle
        self.curvedConnector = curvedConnector
        self.content = content
    }
    
    private var treeKeypath: KeyPath<Tree<T>, ID> {
        let kp = \Tree<T>.value
        return kp.appending(path: id)
    }
    
    private typealias AnchorKey = PreferenceDictionary<ID, Anchor<CGPoint>>
    
    var body: some View {
        HStack(alignment: .top, spacing: 32) {
            ForEach(trees, id: treeKeypath) { tree in
                VStack(spacing: verticalSpacing) {
                    content(tree.value)
                        .anchorPreference(key: AnchorKey.self, value: .center) { anchor in
                            [tree[keyPath: treeKeypath]: anchor]
                        }
                    if !tree.children.isEmpty {
                        HStack(alignment: .top, spacing: horizontalSpacing) {
                            ForEach(tree.children, id: treeKeypath) { child in
                                TreeView(child, id: id, horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing, lineStrokeStyle: lineStrokeStyle, lineShapeStyle: lineShapeStyle, curvedConnector: curvedConnector, content: content)
                            }
                        }
                    }
                }
            }
        }
        .backgroundPreferenceValue(AnchorKey.self) { value in
            GeometryReader { proxy in
                ForEach(trees, id: treeKeypath) { tree in
                    ForEach(tree.children, id: treeKeypath) { child in
                        if curvedConnector {
                            Connector(from: proxy[value[tree[keyPath: treeKeypath]]!],
                                      to: proxy[value[child[keyPath: treeKeypath]]!],
                                      radius: 32)
                            .stroke(AnyShapeStyle(lineShapeStyle), style: lineStrokeStyle)
                        } else {
                            Line(from: proxy[value[tree[keyPath: treeKeypath]]!],
                                 to: proxy[value[child[keyPath: treeKeypath]]!])
                            .stroke(AnyShapeStyle(lineShapeStyle), style: lineStrokeStyle)
                        }
                    }
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
    init(id: KeyPath<T, ID>, horizontalSpacing: CGFloat = 12, verticalSpacing: CGFloat = 12, lineStrokeStyle: StrokeStyle = StrokeStyle(lineWidth: 1), lineShapeStyle: any ShapeStyle = .primary, curvedConnector: Bool = false, @TreeBuilder<T> treeBuilder: () -> [Tree<T>], @ViewBuilder content: @escaping (T) -> Content) {
        self.init(treeBuilder(), id: id, horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing, lineStrokeStyle: lineStrokeStyle, lineShapeStyle: lineShapeStyle, curvedConnector: curvedConnector, content: content)
    }
    
    init(_ trees: Tree<T>..., id: KeyPath<T, ID>, horizontalSpacing: CGFloat = 12, verticalSpacing: CGFloat = 12, lineStrokeStyle: StrokeStyle = StrokeStyle(lineWidth: 1), lineShapeStyle: any ShapeStyle = .primary, curvedConnector: Bool = false, content: @escaping (T) -> Content) {
        self.init(trees, id: id, horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing, lineStrokeStyle: lineStrokeStyle, lineShapeStyle: lineShapeStyle, curvedConnector: curvedConnector, content: content)
    }
    
    init(horizontalSpacing: CGFloat = 12, verticalSpacing: CGFloat = 12, lineStrokeStyle: StrokeStyle = StrokeStyle(lineWidth: 1), lineShapeStyle: any ShapeStyle = .primary, curvedConnector: Bool = false, @TreeBuilder<T> treeBuilder: () -> [Tree<T>], @ViewBuilder content: @escaping (T) -> Content) where T: Identifiable, T.ID == ID {
        self.init(treeBuilder(), id: \.id, horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing, lineStrokeStyle: lineStrokeStyle, lineShapeStyle: lineShapeStyle, curvedConnector: curvedConnector, content: content)
    }
    
    init(_ trees: [Tree<T>], horizontalSpacing: CGFloat = 12, verticalSpacing: CGFloat = 12, lineStrokeStyle: StrokeStyle = .init(lineWidth: 1), lineShapeStyle: any ShapeStyle = .primary, curvedConnector: Bool = false, @ViewBuilder content: @escaping (T) -> Content) where T: Identifiable, T.ID == ID {
        self.init(trees, id: \.id, horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing, lineStrokeStyle: lineStrokeStyle, lineShapeStyle: lineShapeStyle, curvedConnector: curvedConnector, content: content)
    }
    
    init(_ trees: Tree<T>..., horizontalSpacing: CGFloat = 12, verticalSpacing: CGFloat = 12, lineStrokeStyle: StrokeStyle = .init(lineWidth: 1), lineShapeStyle: any ShapeStyle = .primary, curvedConnector: Bool = false, @ViewBuilder content: @escaping (T) -> Content) where T: Identifiable, T.ID == ID {
        self.init(trees, horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing, lineStrokeStyle: lineStrokeStyle, lineShapeStyle: lineShapeStyle, curvedConnector: curvedConnector, content: content)
    }
}

#Preview {
    let tree = Tree(1) {
        Tree(2) {
            Tree(3)
            Tree(4) {
                Tree(5)
            }
        }
        Tree(6) {
            Tree(7)
        }
        Tree(8)
        Tree(9) {
            Tree(10) {
                Tree(11) {
                    Tree(12)
                    Tree(13)
                }
            }
            Tree(14) {
                Tree(15)
                Tree(16)
            }
        }
    }
    
    let bfs = BFS(tree: tree)
    let dfs = DFS(tree: tree)
    
    let treeJson = """
{"value":1,"children":[{"value":2,"children":[{"value":3,"children":[]},{"value":4,"children":[]}]},{"value":5,"children":[]},{"value":6,"children":[{"value":7,"children":[{"value":8,"children":[]},{"value":9,"children":[]}]}]}]}
"""
    let jsonTree = try! treeJson.decodeJson(into: Tree<Int>.self)
    
    ScrollView {
        VStack {
            PhaseAnimator(bfs.map(\.value)) { highlighted in
                TreeView(tree, id: \.self) { integer in
                    Text(integer, format: .number)
                        .font(.headline.bold())
                        .padding(10)
                        .background(Circle().stroke())
                        .background(integer == highlighted ? AnyShapeStyle(.yellow) : AnyShapeStyle(.background), in: .circle)
                }
            } animation: { _ in
                    .easeOut(duration: 0.6).delay(0.5)
            }
            
            PhaseAnimator(dfs.map(\.value)) { highlighted in
                TreeView(tree, id: \.self, curvedConnector: true) { integer in
                    Text(integer, format: .number)
                        .font(.headline.bold())
                        .padding(10)
                        .background(Circle().stroke())
                        .background(integer == highlighted ? AnyShapeStyle(.yellow) : AnyShapeStyle(.background), in: .circle)
                }
            } animation: { _ in
                    .easeOut(duration: 0.6).delay(0.5)
            }
            
            TreeView(id: \.self, lineShapeStyle: .pink.gradient, curvedConnector: true) {
                Tree(1) {
                    Tree(2)
                    Tree(3)
                }
                
                Tree(4) {
                    Tree(5)
                    Tree(6)
                    Tree(7) {
                        Tree(8)
                        Tree(9)
                    }
                }
            } content: { integer in
                Text(integer, format: .number)
                    .font(.callout.bold())
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.pink.gradient, in: .circle)
            }
            
            TreeView(jsonTree, id: \.self, lineShapeStyle: .teal.gradient) { integer in
                Text(integer, format: .number)
                    .font(.callout.bold())
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.teal.gradient, in: .circle)
            }
        }
    }
    .scrollIndicators(.hidden)
}
