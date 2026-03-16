import SpriteKit

class CoinEntity: SKShapeNode {

    static let radius: CGFloat = 7
    static let value:  Int     = 5

    init(at pos: CGPoint) {
        super.init()
        position = pos
        buildVisual()
        buildPhysics()
        runLifecycleActions()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func buildVisual() {
        path        = CGPath(ellipseIn: CGRect(x: -CoinEntity.radius, y: -CoinEntity.radius,
                                               width: CoinEntity.radius*2, height: CoinEntity.radius*2), transform: nil)
        fillColor   = SKColor(red: 1.0, green: 0.85, blue: 0.1, alpha: 1)
        strokeColor = SKColor(red: 0.75, green: 0.55, blue: 0, alpha: 1)
        lineWidth   = 2
        zPosition   = 5
        name        = "coin"
    }

    private func buildPhysics() {
        let body = SKPhysicsBody(circleOfRadius: CoinEntity.radius)
        body.categoryBitMask    = PhysicsCategory.coin
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask   = 0
        body.isDynamic          = false
        physicsBody = body
    }

    private func runLifecycleActions() {
        let drift = SKAction.move(by: CGVector(dx: CGFloat.random(in: -22...22),
                                               dy: CGFloat.random(in: -22...22)),
                                  duration: 0.25)
        let blink = SKAction.repeat(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.2),
            SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        ]), count: 5)
        run(SKAction.sequence([drift,
                               SKAction.wait(forDuration: 6.0),
                               blink,
                               SKAction.removeFromParent()]))
    }
}
