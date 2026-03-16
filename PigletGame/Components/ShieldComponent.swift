import SpriteKit

class ShieldComponent {

    private(set) var isActive: Bool = false
    private weak var ownerNode: SKShapeNode?
    private let ownerRadius: CGFloat

    init(ownerNode: SKShapeNode, ownerRadius: CGFloat) {
        self.ownerNode   = ownerNode
        self.ownerRadius = ownerRadius
    }

    func activate() {
        guard !isActive else { return }
        isActive = true
        attachVisual()
    }

    /// Absorve um hit. Retorna `true` se o escudo ainda estava ativo e foi
    /// consumido; `false` se não havia escudo (dano deve ser repassado).
    @discardableResult
    func absorbHit() -> Bool {
        guard isActive else { return false }
        isActive = false
        removeVisual()
        return true
    }

    // MARK: – Visual

    private func attachVisual() {
        removeVisual()
        let sv = SKShapeNode(circleOfRadius: ownerRadius + 8)
        sv.strokeColor = .cyan
        sv.fillColor   = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.18)
        sv.lineWidth   = 3
        sv.name        = "shieldVisual"
        sv.zPosition   = 3
        let spin = SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 2.2))
        sv.run(spin)
        ownerNode?.addChild(sv)
    }

    private func removeVisual() {
        ownerNode?.childNode(withName: "shieldVisual")?.removeFromParent()
    }
}
