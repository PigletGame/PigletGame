import SpriteKit
import GameplayKit

enum PowerUpKind: String {
    case shield
    case life
}

class PowerUpEntity: GKEntity {

    static let radius: CGFloat = 11
    static let lifetime: TimeInterval = 10

    let kind: PowerUpKind

    init(kind: PowerUpKind, at pos: CGPoint) {
        self.kind = kind
        super.init()
        let posComp = PositionComponent(position: pos)
        addComponent(posComp)
        
        let rootNode = SKNode()
        let sprite: SKSpriteNode
        if kind == .life {
            sprite = SKSpriteNode(imageNamed: "HUD/Heart")
            sprite.texture?.filteringMode = .nearest
            sprite.size = CGSize(width: 15, height: 15)
            sprite.zPosition = 5
            sprite.name = "powerUp"
            sprite.entity = self
            
            let pulse = SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 1.25, duration: 0.45),
                SKAction.scale(to: 0.88, duration: 0.45)
            ]))
            sprite.run(pulse)
        } else {
            sprite = SKSpriteNode(imageNamed: "HUD/Shield")
            sprite.texture?.filteringMode = .nearest
            sprite.size = CGSize(width: 15, height: 15)
            sprite.zPosition = 5
            sprite.name = "powerUp"
            sprite.entity = self
            
            let pulse = SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 1.25, duration: 0.45),
                SKAction.scale(to: 0.88, duration: 0.45)
            ]))
            sprite.run(pulse)
        }
        rootNode.addChild(sprite)
        
        let visualComp = VisualComponent(node: rootNode)
        visualComp.node.position = pos
        addComponent(visualComp)
        
        // Unify explosion effect
        addComponent(LootAnimationComponent(lifetime: PowerUpEntity.lifetime))
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }
}
