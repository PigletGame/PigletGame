import SpriteKit
import GameplayKit

class EnemyEntity: GKEntity {

    static let radius: CGFloat = 17

    let ai = AIComponent()
    let loot = LootComponent()

    init(at position: CGPoint) {
        super.init()
        
        let posComp = PositionComponent(position: position)
        addComponent(posComp)
        
        let animComp = SpriteAnimationComponent(
            default: "Skeleton/Default",
            walkingSprites: [
                "Skeleton/Walking_01",
                "Skeleton/Walking_02",
                "Skeleton/Walking_03",
                "Skeleton/Walking_04",
                "Skeleton/Walking_05",
                "Skeleton/Walking_06",
            ]
        )
        
        animComp.node.name = "enemy"
        animComp.node.entity = self
        
        addComponent(animComp)
        addComponent(ai)
        addComponent(loot)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }
}
