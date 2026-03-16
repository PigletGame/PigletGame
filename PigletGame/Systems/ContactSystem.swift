import SpriteKit

/// Delega as colisões físicas para os sistemas responsáveis.
class ContactSystem {

    private var pendingRemovals     = Set<ObjectIdentifier>()
    private var pendingRemovalNodes = [SKNode]()

    // MARK: – Deferred removal

    func flushRemovals() {
        pendingRemovalNodes.forEach { $0.removeFromParent() }
        pendingRemovalNodes.removeAll()
        pendingRemovals.removeAll()
    }

    func deferRemove(_ node: SKNode?) {
        guard let n = node else { return }
        let id = ObjectIdentifier(n)
        guard !pendingRemovals.contains(id) else { return }
        pendingRemovals.insert(id)
        pendingRemovalNodes.append(n)
    }

    func isPendingRemoval(_ node: SKNode) -> Bool {
        pendingRemovals.contains(ObjectIdentifier(node))
    }

    // MARK: – Contact dispatch

    func handle(contact: SKPhysicsContact,
                player: PlayerEntity,
                onEnemyKilled: (SKNode) -> Void,
                onPlayerDamaged: () -> Void,
                onCoinCollected: (CGPoint) -> Void,
                onPowerUpCollected: (PowerUpKind, CGPoint) -> Void) {

        let a = contact.bodyA
        let b = contact.bodyB

        // Player bullet ↔ enemy
        if match(a, b, cat1: PhysicsCategory.playerBullet, cat2: PhysicsCategory.enemy) {
            let bulletNode = nodeWith(category: PhysicsCategory.playerBullet, in: a, b)
            let enemyNode  = nodeWith(category: PhysicsCategory.enemy,        in: a, b)
            deferRemove(bulletNode)
            if let en = enemyNode, !isPendingRemoval(en) {
                deferRemove(en)
                onEnemyKilled(en)
            }
        }

        // Enemy bullet ↔ player
        if match(a, b, cat1: PhysicsCategory.enemyBullet, cat2: PhysicsCategory.player) {
            let bulletNode = nodeWith(category: PhysicsCategory.enemyBullet, in: a, b)
            deferRemove(bulletNode)
            onPlayerDamaged()
        }

        // Coin ↔ player
        if match(a, b, cat1: PhysicsCategory.coin, cat2: PhysicsCategory.player) {
            let coinNode = nodeWith(category: PhysicsCategory.coin, in: a, b)
            if let cn = coinNode, !isPendingRemoval(cn) {
                deferRemove(cn)
                onCoinCollected(cn.position)
            }
        }

        // PowerUp ↔ player
        if match(a, b, cat1: PhysicsCategory.powerUp, cat2: PhysicsCategory.player) {
            let puNode = nodeWith(category: PhysicsCategory.powerUp, in: a, b)
            if let pu = puNode as? PowerUpEntity, !isPendingRemoval(pu) {
                deferRemove(pu)
                onPowerUpCollected(pu.kind, pu.position)
            }
        }
    }

    // MARK: – Helpers

    private func match(_ a: SKPhysicsBody, _ b: SKPhysicsBody,
                       cat1: UInt32, cat2: UInt32) -> Bool {
        (a.categoryBitMask == cat1 && b.categoryBitMask == cat2) ||
        (a.categoryBitMask == cat2 && b.categoryBitMask == cat1)
    }

    private func nodeWith(category: UInt32,
                          in a: SKPhysicsBody,
                          _ b: SKPhysicsBody) -> SKNode? {
        a.categoryBitMask == category ? a.node : b.node
    }
}
