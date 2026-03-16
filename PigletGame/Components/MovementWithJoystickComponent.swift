//
//  MovementComponent.swift
//  FarmAttackExperiment
//
//  Created by Adriel de Souza on 16/03/26.
//


import SpriteKit
import GameplayKit

class MovementWithJoystickComponent: GKComponent {
    let joystick: JoystickNode
    var speed: CGFloat
    
    init(joystick: JoystickNode, speed: CGFloat = 190.0) {
        self.joystick = joystick
        self.speed = speed
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let posComponent = entity?.component(ofType: PositionComponent.self) else { return }
        let velocity = joystick.movement * speed * CGFloat(seconds)
        posComponent.move(delta: velocity)
    }
}



import SpriteKit
import GameplayKit

class MovementByDirectionComponent: GKComponent {
    let direction: CGPoint
    let speed: CGFloat
    let shouldRotateSprite: Bool

    init(direction: CGPoint, speed: CGFloat = 2.0, shouldRotateSprite: Bool = false) {
        self.direction = direction
        self.speed = speed
        self.shouldRotateSprite = shouldRotateSprite
        super.init()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func update(deltaTime seconds: TimeInterval) {
        guard let posComponent = entity?.component(ofType: PositionComponent.self) else { return }
        posComponent.move(delta: direction * speed)

        guard shouldRotateSprite else { return }
        guard let entity, let visual = VisualComponent.from(entity) else { return }
        visual.node.zRotation = atan2(direction.y, direction.x)
    }
}
