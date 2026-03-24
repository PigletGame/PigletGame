import SpriteKit
import GameplayKit

class BulletEntity: GKEntity {
    static let radius: CGFloat = 5
    
    init(position: CGPoint, direaction: CGPoint, sprite: String) {
        super.init()

        addComponent(PositionComponent(position: position))

        let node = SKSpriteNode(imageNamed: sprite)
        node.texture?.filteringMode = .nearest
        node.zPosition = 3
        node.position = position

        addComponent(VisualComponent(node: node))
        addComponent(MovementByDirectionComponent(direction: direaction, speed: 8.0, shouldRotateSprite: true))
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }
}
