//
//  OnboardingView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/12/25.
//

import SwiftUI

struct OnboardingView: View {
    var onOnboarded: () -> Void
    
    @State private var tree: Tree<String>?
    
    @State private var stopCycle = false
    
    private func cycleTree() {
        withAnimation(.bouncy(duration: 1)) {
            if tree?.value.isEmpty ?? true {
                tree = Tree("Once upon a time,")
                return
            }
            if tree!.children.isEmpty {
                tree!.children.append(.init("There was a..."))
                return
            }
            switch tree!.children[0].children.count {
            case 0: tree!.children[0].children.append(.init("...man."))
            case 1: tree!.children[0].children.append(.init("...woman."))
            case 2:
                tree!.children[0].children.append(.init("...confused person."))
                stopCycle = true
            default: break
            }
        } completion: {
            if !stopCycle {
                cycleTree()
            }
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            if let tree {
                TreeView(tree, id: \.self, verticalSpacing: 44) { content in
                    Text(content)
                        .contentTransition(.numericText())
                        .font(.callout.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(.blue.gradient, in: .rect(cornerRadius: 10))
                }
                Spacer()
            }
            Text("Make Interactive Stories.")
                .font(.system(.title2, design: .serif, weight: .heavy))
                .minimumScaleFactor(0.6)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .scaleEffect(tree == nil ? 1.2 : 1, anchor: .bottom)
                .offset(y: tree == nil ? -64 : 0)
            Button("Continue", systemImage: "arrow.right") {
                withAnimation(.smooth) {
                    onOnboarded()
                }
            }
            .font(.system(.headline, weight: .bold))
            .animation(.easeOut(duration: 1.2).delay(1.5)) { content in
                content
                    .opacity(stopCycle ? 1 : 0)
            }
        }
        .safeAreaPadding(.vertical, 20)
        .task {
            try? await Task.sleep(for: .seconds(2))
            cycleTree()
        }
    }
}

#Preview {
    OnboardingView {}
}
