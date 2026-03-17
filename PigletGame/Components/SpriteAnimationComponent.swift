import SpriteKit
import GameplayKit

class SpriteAnimationComponent: VisualComponent {
    let defaultSpriteName: String
    let walkingSpritesName: [String]
    let timePerFrame: Double
    let size: CGFloat

    private let walkingActionKey = "walkingAnimation"

    init(`default`: String, walkingSprites: [String], size: CGFloat = 32, timePerFrame: Double = 0.15) {
        let node = SKSpriteNode(imageNamed: `default`)
        node.texture?.filteringMode = .nearest
        node.size = CGSize(width: size, height: size)

        self.defaultSpriteName = `default`
        self.walkingSpritesName = walkingSprites
        self.size = size
        self.timePerFrame = timePerFrame
        super.init(node: node)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func update(deltaTime seconds: TimeInterval) {
        if let posComponent = entity?.component(ofType: PositionComponent.self) {
            node.position = posComponent.position

            if posComponent.lastDeltaPosition == .zero {
                stopWalking()
            } else {
                if posComponent.lastDeltaPosition.x > 0 {
                    node.xScale = 1
                } else if posComponent.lastDeltaPosition.x < 0 {
                    node.xScale = -1
                }
                startWalking()
            }
        }
    }

    private func startWalking() {
        guard node.action(forKey: walkingActionKey) == nil else { return }

        let textures = walkingSpritesName.map { SKTexture(imageNamed: $0) }
        textures.forEach { $0.filteringMode = .nearest }

        let animation = SKAction.animate(with: textures, timePerFrame: timePerFrame)
        let loop = SKAction.repeatForever(animation)
        node.run(loop, withKey: walkingActionKey)
    }

    private func stopWalking() {
        guard node.action(forKey: walkingActionKey) != nil else { return }

        super.node.removeAction(forKey: walkingActionKey)
        super.node.texture = SKTexture(imageNamed: defaultSpriteName)
        super.node.texture?.filteringMode = .nearest
    }
}
