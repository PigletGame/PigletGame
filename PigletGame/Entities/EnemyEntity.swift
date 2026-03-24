import SpriteKit
import GameplayKit

class EnemyEntity: GKEntity {

    static let radius: CGFloat = 17

    let ai = AIComponent()
    let loot = LootComponent()
    let health: HealthComponent
    var lastHitTime: TimeInterval = 0

    init(at position: CGPoint, hp: Int = 1) {
        self.health = HealthComponent(lives: hp)
        super.init()
        
        let posComp = PositionComponent(position: position)
        addComponent(posComp)
        
        let animComp = SpriteAnimationComponent(
            default: "Tiger/Standby",
            walkingSprites:
                Array(0...13).map{return "Tiger/Walking/\($0)"},
            timePerFrame: 0.05
        )

        animComp.node.position = position
        animComp.node.name = "enemy"
        animComp.node.entity = self
        
        addComponent(animComp)
        addComponent(ai)
        addComponent(loot)
        addComponent(health)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }
}
