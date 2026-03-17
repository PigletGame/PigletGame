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

    init(joystick: JoystickNode, summonProjectile: ((CGPoint, CGPoint) -> Void)?) {
        self.joystick = joystick
        self.summonProjectile = summonProjectile
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let posComponent = entity?.component(ofType: PositionComponent.self) else { return }
        if joystick.movement.norm > 0.4 {
            summonProjectile?(posComponent.position, joystick.movement)
        }
    }
}
