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
        
        let sprite: SKSpriteNode
        if kind == .life {
            sprite = SKSpriteNode(imageNamed: "PLACEHOLDER/Heart")
            sprite.texture?.filteringMode = .nearest
            sprite.zPosition = 5
            sprite.name = "powerUp"
            sprite.entity = self
            
            let pulse = SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 1.25, duration: 0.45),
                SKAction.scale(to: 0.88, duration: 0.45)
            ]))
            sprite.run(pulse)
        } else {
            let r = PowerUpEntity.radius
            let path = CGPath(ellipseIn: CGRect(x: -r, y: -r, width: r*2, height: r*2), transform: nil)
            let shape = SKShapeNode(path: path)
            shape.zPosition = 5
            shape.lineWidth = 2.5
            shape.name      = "powerUp"
            shape.entity    = self
            shape.fillColor   = SKColor(red: 0.20, green: 0.50, blue: 1.0, alpha: 1)
            shape.strokeColor = .cyan
            
            let pulse = SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 1.25, duration: 0.45),
                SKAction.scale(to: 0.88, duration: 0.45)
            ]))
            shape.run(pulse)
            
            sprite = SKSpriteNode()
            sprite.addChild(shape)
        }
        
        let visualComp = VisualComponent(node: sprite)
        addComponent(visualComp)
        
        runLifecycleActions(on: sprite)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func runLifecycleActions(on node: SKNode) {
        node.run(SKAction.sequence([
            SKAction.wait(forDuration: PowerUpEntity.lifetime),
            SKAction.removeFromParent()
        ]))
    }
}
