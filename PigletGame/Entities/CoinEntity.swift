import SpriteKit
import GameplayKit

class CoinEntity: GKEntity {

    static let radius: CGFloat = 7
    static let baseValue: Int  = 5
    
    let value: Int = CoinEntity.baseValue

    init(at pos: CGPoint) {
        super.init()
        
        let posComp = PositionComponent(position: pos)
        addComponent(posComp)
        
        let rootNode = SKNode()
        let sprite = SKSpriteNode(imageNamed: "HUD/Coin")
        sprite.texture?.filteringMode = .nearest
        sprite.size = CGSize(width: 15, height: 15)
        sprite.zPosition = 5
        sprite.name = "coin"
        sprite.entity = self
        rootNode.addChild(sprite)

        let visualComp = VisualComponent(node: rootNode)
        addComponent(visualComp)
        
        // Unify explosion effect
        addComponent(LootAnimationComponent(lifetime: 6.0))
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }
}
