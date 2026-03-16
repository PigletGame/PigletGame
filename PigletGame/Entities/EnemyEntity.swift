import SpriteKit

class EnemyEntity: SKShapeNode {

    static let radius: CGFloat = 17

    let ai: AIComponent
    let loot = LootComponent()

    // MARK: – Init

    init(type: EnemyType, at position: CGPoint) {
        self.ai = AIComponent(type: type)
        super.init()
        self.position = position
        buildVisual(type: type)
        buildPhysics()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: – Visual

    private func buildVisual(type: EnemyType) {
        let r = EnemyEntity.radius
        path      = CGPath(ellipseIn: CGRect(x: -r, y: -r, width: r*2, height: r*2), transform: nil)
        zPosition = 9
        name      = "enemy"

        switch type {
        case .melee:
            fillColor   = SKColor(red: 0.92, green: 0.40, blue: 0.08, alpha: 1)
            strokeColor = SKColor(red: 0.65, green: 0.20, blue: 0.00, alpha: 1)
            lineWidth   = 2
            for angle in [CGFloat.pi / 4, -CGFloat.pi / 4] {
                let stripe = SKShapeNode(rectOf: CGSize(width: r * 1.6, height: 3.5))
                stripe.fillColor   = SKColor(red: 0.60, green: 0.15, blue: 0.0, alpha: 0.7)
                stripe.strokeColor = .clear
                stripe.zRotation   = angle
                stripe.zPosition   = 1
                addChild(stripe)
            }

        case .ranged:
            fillColor   = SKColor(red: 0.50, green: 0.10, blue: 0.80, alpha: 1)
            strokeColor = SKColor(red: 0.30, green: 0.00, blue: 0.55, alpha: 1)
            lineWidth   = 2
            let inner = SKShapeNode(circleOfRadius: r * 0.55)
            inner.fillColor   = SKColor(red: 0.75, green: 0.45, blue: 1.0, alpha: 0.6)
            inner.strokeColor = .clear
            inner.zPosition   = 1
            addChild(inner)
        }
    }

    private func buildPhysics() {
        let body = SKPhysicsBody(circleOfRadius: EnemyEntity.radius)
        body.categoryBitMask    = PhysicsCategory.enemy
        body.contactTestBitMask = PhysicsCategory.playerBullet
        body.collisionBitMask   = 0
        body.isDynamic          = true
        body.linearDamping      = 0
        physicsBody = body
    }
}
