//
//  ShooterComponent.swift
//  FarmAttackExperiment
//
//  Created by Adriel de Souza on 16/03/26.
//


import SpriteKit
import GameplayKit

class ShooterComponent: GKComponent {
    let joystick: JoystickNode
    let summonProjectile: ((CGPoint, CGPoint) -> Void)?
    
    private var crossbowNode: SKSpriteNode?
    private var gunOffsetRadius: CGFloat = 24

    init(joystick: JoystickNode, summonProjectile: ((CGPoint, CGPoint) -> Void)?) {
        self.joystick = joystick
        self.summonProjectile = summonProjectile
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func update(deltaTime seconds: TimeInterval) {
        updateCrossbow()
        
        if joystick.movement.norm > 0.4 {
            guard let posComponent = entity?.component(ofType: PositionComponent.self) else { return }
            summonProjectile?(posComponent.position + (joystick.movement * gunOffsetRadius), joystick.movement)
        }
    }
    
    private func updateCrossbow() {
        let norm = joystick.movement.norm
        
        if norm > 0.2 {
            if crossbowNode == nil {
                setupCrossbow()
            }
            
            guard let crossbow = crossbowNode else { return }
            crossbow.isHidden = false
            
            // Calculate angle from joystick movement
            let angle = atan2(joystick.movement.y, joystick.movement.x)
            
            // Position it around the player center (relative to visual.node which is at player pos)
            let offsetX = cos(angle) * gunOffsetRadius
            let offsetY = sin(angle) * gunOffsetRadius
            crossbow.position = CGPoint(x: offsetX, y: offsetY)
            
            // Rotate it
            crossbow.zRotation = angle

            // Flip if on the left side to keep it upright
            if joystick.movement.x < 0 {
                crossbow.yScale = -1
            } else {
                crossbow.yScale = 1
            }
            
        } else {
            crossbowNode?.isHidden = true
        }
    }
    
    private func setupCrossbow() {
        let crossbow = SKSpriteNode(texture:  SKTexture(imageNamed: "Crossbow"))
        crossbow.texture?.filteringMode = .nearest
        crossbow.size = CGSize(width: 24, height: 24)
        crossbow.zPosition = 2

        // Add as a child of the visual node
        if let entity = self.entity, let visual = VisualComponent.from(entity) {
            visual.node.addChild(crossbow)
            self.crossbowNode = crossbow
        }
    }
}
