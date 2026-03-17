import SpriteKit
import GameplayKit

class PlayerEntity: GKEntity {

    static let radius: CGFloat = 18
    static let speed:  CGFloat = 190

    let health = HealthComponent()
    lazy var shield = ShieldComponent(ownerRadius: PlayerEntity.radius)

    init(position: CGPoint, leftJoystick: JoystickNode, rightJoystick: JoystickNode, summonProjectileAction: @escaping (CGPoint, CGPoint) -> Void) {
        super.init()
        
        let posComp = PositionComponent(position: position)
        addComponent(posComp)
        
        let animComp = SpriteAnimationComponent(
            default: "Player/Standby",
            walkingSprites:
                Array(0...14).map{return "Player/Walking/\($0)"},
            timePerFrame: 0.05
        )

        // Link back to entity for collisions
        animComp.node.name = "player"
        animComp.node.entity = self
        
        addComponent(animComp)
        addComponent(MovementWithJoystickComponent(joystick: leftJoystick, speed: PlayerEntity.speed))
        addComponent(ShooterComponent(joystick: rightJoystick, summonProjectile: summonProjectileAction))
        addComponent(health)
        addComponent(shield)
        
        shield.attach(to: animComp.node)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    func flashDamage(onComplete: @escaping () -> Void) {
        if let node = VisualComponent.from(self)?.node {
            let flash = SKAction.repeat(SKAction.sequence([
                SKAction.colorize(with: .red, colorBlendFactor: 0.9, duration: 0.08),
                SKAction.colorize(with: .clear, colorBlendFactor: 0, duration: 0.08)
            ]), count: 7)
            node.run(flash, completion: onComplete)
        } else {
            onComplete()
        }
    }

    func flashColor(_ color: SKColor) {
        if let node = VisualComponent.from(self)?.node {
            let flash = SKAction.sequence([
                SKAction.colorize(with: color, colorBlendFactor: 1, duration: 0.1),
                SKAction.colorize(with: .clear, colorBlendFactor: 0, duration: 0.15)
            ])
            node.run(flash)
        }
    }
}
