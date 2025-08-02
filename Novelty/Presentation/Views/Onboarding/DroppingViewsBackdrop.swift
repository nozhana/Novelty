//
//  DroppingBoxesView.swift
//  Novelty
//
//  Created by Nozhan A. on 7/16/25.
//

import Combine
import SpriteKit
import SwiftUI

struct DroppingViewsBackdropView<Content: View>: View {
    var trigger: AnyPublisher<Void, Never>
    @ViewBuilder var content: () -> Content
    
    @Environment(\.colorScheme) private var colorScheme
    
    var scene: SKScene {
        let scene = DroppingViewsBackdropScene(trigger: trigger) {
            content()
                .colorScheme(colorScheme)
        }
        scene.size = UIScreen.main.bounds.size
        scene.scaleMode = .fill
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

#Preview {
    let trigger = PassthroughSubject<Void, Never>()
    DroppingViewsBackdropView(trigger: trigger.eraseToAnyPublisher()) {
        Text("Suck Dick")
            .font(.system(.title2, design: .serif, weight: .black))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.linearGradient(colors: [.orange, .yellow], startPoint: .bottomLeading, endPoint: .topTrailing), in: .rect(cornerRadius: 10))
    }
}

private final class DroppingViewsBackdropScene<Content: View>: SKScene {
    var trigger: AnyPublisher<Void, Never>
    var nodeContent: () -> Content
    
    private let motionManager = MotionManager.shared
    
    private var cancellables = Set<AnyCancellable>()
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(trigger: AnyPublisher<Void, Never>, @ViewBuilder nodeContent: @escaping () -> Content) {
        self.trigger = trigger
        self.nodeContent = nodeContent
        super.init(size: .zero)
        setupBindings()
    }
    
    private func setupBindings() {
        trigger
            .sink { [weak self] in
                self?.triggerDrop()
            }
            .store(in: &cancellables)
        
        motionManager.$deviceMotion
            .receive(on: RunLoop.main)
            .compactMap(\.self)
            .sink { [weak self] motion in
                self?.physicsWorld.gravity = .init(dx: 8 * motion.gravity.x, dy: 8 * motion.gravity.y)
            }
            .store(in: &cancellables)
    }
    
    private func triggerDrop() {
        removeAllChildren()
        let renderer = ImageRenderer(content: nodeContent())
        let image = renderer.cgImage!
        for i in 0..<10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) / 4) { [weak self] in
                guard let self else { return }
                let texture = SKTexture(cgImage: image)
                texture.filteringMode = .linear
                let node = SKSpriteNode(texture: texture)
                node.position = .init(x: frame.width / 2, y: frame.height - node.size.height)
                node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                node.physicsBody?.restitution = 0.6
                node.physicsBody?.linearDamping = 0
                node.physicsBody?.velocity = .init(dx: .random(in: -300...300), dy: 0)
                node.physicsBody?.affectedByGravity = true
                addChild(node)
            }
        }
        setupBindings()
        motionManager.startDeviceMotionUpdates()
    }
    
    override func didMove(to view: SKView) {
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        backgroundColor = .clear
        view.allowsTransparency = true
    }
    
    override func willMove(from view: SKView) {
        motionManager.stopDeviceMotionUpdates()
    }
}
