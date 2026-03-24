import SpriteKit
import GameplayKit

class BulletEntity: GKEntity {
    static let radius: CGFloat = 5
    
    init(position: CGPoint, direaction: CGPoint, sprite: String) {
        super.init()

        addComponent(PositionComponent(position: position))

        let node = SKSpriteNode(imageNamed: sprite)

        let textureSize = node.texture!.size()
        let targetSize = CGSize(width: 18, height: 18)

        let scale = min(targetSize.width / textureSize.width,
                        targetSize.height / textureSize.height)

        node.setScale(scale)

        node.texture?.filteringMode = .nearest
        node.zPosition = 3

        addComponent(VisualComponent(node: node))
        addComponent(MovementByDirectionComponent(direction: direaction, speed: 8.0, shouldRotateSprite: true))
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }
}
