import SpriteKit

class PlayerEntity: SKShapeNode {

    static let radius: CGFloat = 18
    static let speed:  CGFloat = 190

    let health  = HealthComponent()
    lazy var shield = ShieldComponent(ownerNode: self, ownerRadius: PlayerEntity.radius)

    // MARK: – Init

    override init() {
        super.init()
        buildVisual()
        buildPhysics()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: – Visual

    private func buildVisual() {
        let r = PlayerEntity.radius
        // Recriar o path do círculo (não podemos passar para super.init diretamente)
        path       = CGPath(ellipseIn: CGRect(x: -r, y: -r, width: r*2, height: r*2), transform: nil)
        fillColor  = SKColor(red: 1.0, green: 0.72, blue: 0.72, alpha: 1)
        strokeColor = SKColor(red: 0.85, green: 0.50, blue: 0.50, alpha: 1)
        lineWidth  = 2
        zPosition  = 10
        name       = "player"

        let nose = SKShapeNode(ellipseOf: CGSize(width: 13, height: 9))
        nose.fillColor   = SKColor(red: 0.95, green: 0.60, blue: 0.60, alpha: 1)
        nose.strokeColor = .clear
        nose.position    = CGPoint(x: 0, y: -5)
        nose.zPosition   = 1
        addChild(nose)

        for (dx, eyeName) in [(-5.5, "eyeL"), (5.5, "eyeR")] as [(CGFloat, String)] {
            let eye = SKShapeNode(circleOfRadius: 2.8)
            eye.fillColor   = .black
            eye.strokeColor = .clear
            eye.position    = CGPoint(x: dx, y: 5)
            eye.zPosition   = 1
            eye.name        = eyeName
            addChild(eye)
        }
    }

    private func buildPhysics() {
        let body = SKPhysicsBody(circleOfRadius: PlayerEntity.radius)
        body.categoryBitMask    = PhysicsCategory.player
        body.contactTestBitMask = PhysicsCategory.enemyBullet | PhysicsCategory.coin | PhysicsCategory.powerUp
        body.collisionBitMask   = 0
        body.isDynamic          = true
        body.linearDamping      = 0
        physicsBody = body
    }

    // MARK: – Movement

    func move(velocity: CGPoint, dt: CGFloat, in bounds: CGSize) {
        guard velocity != .zero else { return }
        position.x += velocity.x * PlayerEntity.speed * dt
        position.y += velocity.y * PlayerEntity.speed * dt
        clamp(in: bounds)
    }

    private func clamp(in bounds: CGSize) {
        let m: CGFloat = 20
        position.x = max(m, min(bounds.width  - m, position.x))
        position.y = max(m, min(bounds.height - m, position.y))
    }

    // MARK: – Hit feedback

    func flashDamage(onComplete: @escaping () -> Void) {
        let baseColor = SKColor(red: 1, green: 0.72, blue: 0.72, alpha: 1)
        let flash = SKAction.repeat(SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.9, duration: 0.08),
            SKAction.colorize(with: baseColor, colorBlendFactor: 0, duration: 0.08)
        ]), count: 7)
        run(flash, completion: onComplete)
    }

    func flashColor(_ color: SKColor) {
        let baseColor = SKColor(red: 1, green: 0.72, blue: 0.72, alpha: 1)
        let flash = SKAction.sequence([
            SKAction.colorize(with: color, colorBlendFactor: 1, duration: 0.1),
            SKAction.colorize(with: baseColor, colorBlendFactor: 0, duration: 0.15)
        ])
        run(flash)
    }
}
