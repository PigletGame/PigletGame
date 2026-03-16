import SpriteKit

enum PowerUpKind: String {
    case shield
    case life
}

class PowerUpEntity: SKShapeNode {

    static let radius: CGFloat = 11
    static let lifetime: TimeInterval = 10

    let kind: PowerUpKind

    init(kind: PowerUpKind, at pos: CGPoint) {
        self.kind = kind
        super.init()
        position  = pos
        buildVisual(kind: kind)
        buildPhysics()
        runLifecycleActions()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func buildVisual(kind: PowerUpKind) {
        let r = PowerUpEntity.radius
        path      = CGPath(ellipseIn: CGRect(x: -r, y: -r, width: r*2, height: r*2), transform: nil)
        zPosition = 5
        lineWidth = 2.5
        name      = "powerUp"

        switch kind {
        case .life:
            fillColor   = SKColor(red: 0.95, green: 0.15, blue: 0.15, alpha: 1)
            strokeColor = .white
        case .shield:
            fillColor   = SKColor(red: 0.20, green: 0.50, blue: 1.0, alpha: 1)
            strokeColor = .cyan
        }

        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.25, duration: 0.45),
            SKAction.scale(to: 0.88, duration: 0.45)
        ]))
        run(pulse)
    }

    private func buildPhysics() {
        let body = SKPhysicsBody(circleOfRadius: PowerUpEntity.radius)
        body.categoryBitMask    = PhysicsCategory.powerUp
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask   = 0
        body.isDynamic          = false
        physicsBody = body
    }

    private func runLifecycleActions() {
        run(SKAction.sequence([
            SKAction.wait(forDuration: PowerUpEntity.lifetime),
            SKAction.removeFromParent()
        ]))
    }
}
