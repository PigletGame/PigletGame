import SpriteKit
import GameplayKit

class LootAnimationComponent: GKComponent {
    
    let lifetime: TimeInterval
    
    init(lifetime: TimeInterval = 6.0) {
        self.lifetime = lifetime
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func didAddToEntity() {
        super.didAddToEntity()
        startAnimation()
    }
    
    private func startAnimation() {
        guard let visual = entity?.component(ofType: VisualComponent.self) else { return }
        
        // Find the sprite node to animate (the one that actually has the texture)
        let sprite: SKNode
        if let s = visual.node as? SKSpriteNode {
            sprite = s
        } else if let s = visual.node.children.first(where: { $0 is SKSpriteNode }) {
            sprite = s
        } else {
            sprite = visual.node
        }
        
        // 1. Horizontal travel (Explosion)
        let randomX = CGFloat.random(in: -45...45)
        let randomY = CGFloat.random(in: -35...35)
        let travel = SKAction.moveBy(x: randomX, y: randomY, duration: 0.45)
        travel.timingMode = .easeOut
        
        // 2. Vertical Jump
        let jumpHeight: CGFloat = 30
        let jumpUp = SKAction.moveBy(x: 0, y: jumpHeight, duration: 0.22)
        jumpUp.timingMode = .easeOut
        let fallDown = SKAction.moveBy(x: 0, y: -jumpHeight, duration: 0.23)
        fallDown.timingMode = .easeIn
        let jumpSequence = SKAction.sequence([jumpUp, fallDown])
        
        let jumpAndScale = SKAction.group([jumpSequence, scaleSequence])
        
        // 4. Lifecycle (Wait and Remove)
        let waitDuration = max(0.1, lifetime - 1.0)
        let blink = SKAction.repeat(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.2),
            SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        ]), count: 3)
        
        let fullSequence = SKAction.sequence([
            SKAction.group([travel, jumpAndScale]),
            SKAction.wait(forDuration: waitDuration),
            blink,
            SKAction.run { [weak visual] in
                visual?.node.removeFromParent()
            }
        ])
        
        sprite.run(fullSequence)
    }
}
