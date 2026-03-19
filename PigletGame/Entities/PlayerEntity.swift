import SpriteKit
import GameplayKit

class PlayerEntity: GKEntity {

    static let radius: CGFloat = 18
    static let speed:  CGFloat = 190

    let health = HealthComponent()
    lazy var shield = ShieldComponent(ownerRadius: PlayerEntity.radius)
    var lastHitTime: TimeInterval = 0

    private var isPlayingStepsAudio = false

    init(position: CGPoint, leftJoystick: JoystickNode, rightJoystick: JoystickNode, summonProjectileAction: @escaping (CGPoint, CGPoint) -> Void) {
        super.init()
        
        let posComp = PositionComponent(position: position)
        addComponent(posComp)
        
        let animComp = SpriteAnimationComponent(
            default: "Player/Standby",
            walkingSprites:
                Array(0...13).map{return "Player/Walking/\($0)"},
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
        
        health.onDeath = { [weak self] in
            self?.updateStepsAudio(isWalking: false)
        }
        
        shield.attach(to: animComp.node)
       
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    func flashDamage(onComplete: @escaping () -> Void) {
        if let visual = VisualComponent.from(self) {
            let sequence = SKAction.repeat(SKAction.run { [weak visual] in
                visual?.flash(color: .red, duration: 0.15)
            }, count: 6)
            visual.node.run(sequence) {
                onComplete()
            }
        } else {
            onComplete()
        }
    }

    func flashColor(_ color: SKColor) {
        self.component(ofType: VisualComponent.self)?.flash(color: color, duration: 0.25)
    }

    func updateStepsAudio(isWalking: Bool) {
        if isWalking && !isPlayingStepsAudio {
            AudioService.shared.play("steps.wav", loop: true, volume: 0.03)
            isPlayingStepsAudio = true
        } else if (!isWalking && isPlayingStepsAudio) {
            AudioService.shared.stop("steps.wav")
            isPlayingStepsAudio = false
        }
    }
    
}
