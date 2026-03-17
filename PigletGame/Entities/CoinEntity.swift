import SpriteKit
import GameplayKit

class CoinEntity: GKEntity {

    static let radius: CGFloat = 7
    static let value:  Int     = 5

    init(at pos: CGPoint) {
        super.init()
        let posComp = PositionComponent(position: pos)
        addComponent(posComp)
        
        let sprite = SKSpriteNode(imageNamed: "PLACEHOLDER/Coin")
        sprite.texture?.filteringMode = .nearest
        sprite.zPosition = 5
        sprite.name = "coin"
        sprite.entity = self

        let visualComp = VisualComponent(node: sprite)
        addComponent(visualComp)
        
        runLifecycleActions(on: sprite)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func runLifecycleActions(on node: SKNode) {
        let drift = SKAction.move(by: CGVector(dx: CGFloat.random(in: -22...22),
                                               dy: CGFloat.random(in: -22...22)),
                                  duration: 0.25)
        let blink = SKAction.repeat(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.2),
            SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        ]), count: 5)
        node.run(SKAction.sequence([drift,
                               SKAction.wait(forDuration: 6.0),
                               blink,
                               SKAction.removeFromParent()]))
    }
}
