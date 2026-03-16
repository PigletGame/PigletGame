import SpriteKit

class CoinSystem {

    private weak var scene: SKScene?
    private weak var player: PlayerEntity?

    private let attractRadius: CGFloat = 55
    private let attractSpeed:  CGFloat = 320

    init(scene: SKScene, player: PlayerEntity) {
        self.scene  = scene
        self.player = player
    }

    // MARK: – Attraction

    func attractCoins(dt: CGFloat) {
        guard let scene, let player else { return }

        for node in scene.children where node.name == "coin" {
            let dx   = player.position.x - node.position.x
            let dy   = player.position.y - node.position.y
            let dist = hypot(dx, dy)
            guard dist < attractRadius, dist > 0 else { continue }
            node.position.x += (dx / dist) * attractSpeed * dt
            node.position.y += (dy / dist) * attractSpeed * dt
        }
    }

    // MARK: – Collect

    func collectCoin(at pos: CGPoint, onScoreIncrease: (Int) -> Void) {
        onScoreIncrease(CoinEntity.value)
        floatText("+\(CoinEntity.value)", at: pos,
                  color: SKColor(red: 1, green: 0.85, blue: 0.1, alpha: 1))
    }

    func collectPowerUp(kind: PowerUpKind, at pos: CGPoint,
                        player: PlayerEntity,
                        onHUDUpdate: () -> Void) {
        switch kind {
        case .life:
            player.health.heal()
            onHUDUpdate()
            floatText("+VIDA ❤️", at: pos,
                      color: SKColor(red: 1, green: 0.3, blue: 0.3, alpha: 1))
        case .shield:
            player.shield.activate()
            onHUDUpdate()
            floatText("+ESCUDO 🛡", at: pos, color: .cyan)
        }
    }

    // MARK: – Drop

    func dropLoot(at pos: CGPoint) {
        guard let scene else { return }
        let drops = LootComponent().roll()

        for drop in drops {
            switch drop {
            case .coin:
                scene.addChild(CoinEntity(at: pos))
            case .extraCoin:
                let offset = CGPoint(x: CGFloat.random(in: -15...15),
                                     y: CGFloat.random(in: -15...15))
                scene.addChild(CoinEntity(at: CGPoint(x: pos.x + offset.x,
                                                       y: pos.y + offset.y)))
            case .shield:
                scene.addChild(PowerUpEntity(kind: .shield, at: pos))
            case .life:
                scene.addChild(PowerUpEntity(kind: .life, at: pos))
            case .nothing:
                break
            }
        }
    }

    // MARK: – Helpers

    private func floatText(_ text: String, at pos: CGPoint, color: SKColor) {
        guard let scene else { return }
        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.text      = text
        lbl.fontSize  = 13
        lbl.fontColor = color
        lbl.position  = pos
        lbl.zPosition = 30
        scene.addChild(lbl)

        lbl.run(SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 32, duration: 0.55),
                SKAction.fadeOut(withDuration: 0.55)
            ]),
            SKAction.removeFromParent()
        ]))
    }
}
