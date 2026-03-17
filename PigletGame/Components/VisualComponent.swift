//
//  RenderComponent.swift
//  FarmAttackExperiment
//
//  Created by Adriel de Souza on 16/03/26.
//

import SpriteKit
import GameplayKit

class VisualComponent: GKComponent {
    let node: SKSpriteNode

    init(node: SKSpriteNode) {
        self.node = node
        super.init()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func update(deltaTime seconds: TimeInterval) {
        if let posComponent = entity?.component(ofType: PositionComponent.self) {
            node.position = posComponent.position
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
