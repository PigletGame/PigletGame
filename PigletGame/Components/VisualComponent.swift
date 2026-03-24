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
        let target = (node as? SKSpriteNode) ?? node.children.compactMap({ $0 as? SKSpriteNode }).first
        guard let sprite = target else {
            completion?()
            return
        }

        let fadeInTime = duration * 0.3
        let fadeOutTime = duration * 0.7

        let flashIn = SKAction.customAction(withDuration: fadeInTime) { node, elapsedTime in
            if let sprite = node as? SKSpriteNode {
                let percent = elapsedTime / CGFloat(fadeInTime)
                sprite.color = color
                sprite.colorBlendFactor = percent
            }
        }

        let flashOut = SKAction.customAction(withDuration: fadeOutTime) { node, elapsedTime in
            if let sprite = node as? SKSpriteNode {
                let percent = 1.0 - (elapsedTime / CGFloat(fadeOutTime))
                sprite.color = color
                sprite.colorBlendFactor = percent
            }
        }

        let reset = SKAction.run {
            sprite.colorBlendFactor = 0
        }

        sprite.run(SKAction.sequence([flashIn, flashOut, reset])) {
            completion?()
        }
    }

    func blink(colors: [SKColor], duration: TimeInterval, completion: (() -> Void)? = nil) {
        let target = (node as? SKSpriteNode) ?? node.children.compactMap({ $0 as? SKSpriteNode }).first
        guard let sprite = target else {
            completion?()
            return
        }

        let cycleDuration: TimeInterval = 0.15
        let numberOfCycles = Int(duration / cycleDuration)
        
        var actions: [SKAction] = []
        
        for _ in 0..<numberOfCycles {
            for color in colors {
                let step = SKAction.run {
                    sprite.color = color
                    sprite.colorBlendFactor = 1.0
                }
                let wait = SKAction.wait(forDuration: cycleDuration / TimeInterval(colors.count))
                actions.append(step)
                actions.append(wait)
            }
        }
        
        let reset = SKAction.run {
            sprite.colorBlendFactor = 0
        }
        
        sprite.run(SKAction.sequence([
            SKAction.sequence(actions),
            reset
        ])) {
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
