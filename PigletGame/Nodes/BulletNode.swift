import SpriteKit

enum BulletOwner {
    case player
    case enemy
}

class BulletNode: SKShapeNode {

    static let radius: CGFloat = 5

    init(owner: BulletOwner, position pos: CGPoint, velocity: CGVector) {
        super.init()
        position = pos

        let r = BulletNode.radius
        path      = CGPath(ellipseIn: CGRect(x: -r, y: -r, width: r*2, height: r*2), transform: nil)
        zPosition = 8
        lineWidth = owner == .player ? 1.5 : 1

        switch owner {
        case .player:
            fillColor   = SKColor(red: 1.0, green: 0.92, blue: 0.25, alpha: 1)
            strokeColor = SKColor(red: 1.0, green: 0.65, blue: 0.1,  alpha: 1)
            name        = "playerBullet"
        case .enemy:
            fillColor   = SKColor(red: 0.95, green: 0.15, blue: 0.15, alpha: 1)
            strokeColor = SKColor(red: 0.7,  green: 0.0,  blue: 0.0,  alpha: 1)
            name        = "enemyBullet"
        }

        buildPhysics(owner: owner, velocity: velocity)
        scheduleRemoval(owner: owner)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    private func buildPhysics(owner: BulletOwner, velocity: CGVector) {
        let body = SKPhysicsBody(circleOfRadius: BulletNode.radius)
        body.isDynamic     = true
        body.linearDamping = 0
        body.collisionBitMask = 0

        switch owner {
        case .player:
            body.categoryBitMask    = PhysicsCategory.playerBullet
            body.contactTestBitMask = PhysicsCategory.enemy
        case .enemy:
            body.categoryBitMask    = PhysicsCategory.enemyBullet
            body.contactTestBitMask = PhysicsCategory.player
        }

        physicsBody = body
        physicsBody?.velocity = velocity
    }

    private func scheduleRemoval(owner: BulletOwner) {
        let lifetime: TimeInterval = owner == .player ? 1.8 : 3.5
        run(SKAction.sequence([
            SKAction.wait(forDuration: lifetime),
            SKAction.removeFromParent()
        ]))
    }
}
