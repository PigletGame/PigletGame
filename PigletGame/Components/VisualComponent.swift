//
//  RenderComponent.swift
//  FarmAttackExperiment
//
//  Created by Adriel de Souza on 16/03/26.
//

import SpriteKit
import GameplayKit

class VisualComponent: GKComponent {
    let node: SKNode

    init(node: SKNode) {
        self.node = node
        super.init()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func update(deltaTime seconds: TimeInterval) {
        if let posComponent = entity?.component(ofType: PositionComponent.self) {
            node.position = posComponent.position
        }
    }

    func flash(color: SKColor, duration: TimeInterval = 0.1, completion: (() -> Void)? = nil) {
        let flashAction = SKAction.sequence([
            SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: duration * 0.4),
            SKAction.colorize(with: .clear, colorBlendFactor: 0, duration: duration * 0.6)
        ])
        
        // Apply to the node itself if it's a sprite, or its first sprite child
        let target = (node as? SKSpriteNode) ?? node.children.compactMap({ $0 as? SKSpriteNode }).first
        
        if let sprite = target {
            sprite.run(flashAction) {
                completion?()
            }
        } else {
            completion?()
        }
    }

    static func from(_ entity: GKEntity) -> VisualComponent? {
        for component in entity.components {
            if let visual = component as? VisualComponent {
                return visual
            }
        }
        return nil
    }
}
