import SpriteKit
import GameplayKit

class ItemPickupSystem {

    private weak var scene: GameScene?
    private weak var player: PlayerEntity?

    private let attractRadius: CGFloat = 55
    private let attractSpeed:  CGFloat = 320

    init(scene: GameScene, player: PlayerEntity) {
        self.scene  = scene
        self.player = player
    }

    // MARK: – Attraction

    func attractCoins(dt: CGFloat) {
        guard let scene, let player else { return }
        let playerPos = player.component(ofType: PositionComponent.self)?.position ?? .zero

        let coins = scene.entityManager.entities.compactMap { $0 as? CoinEntity }
        for coin in coins {
            guard let posComp = coin.component(ofType: PositionComponent.self) else { continue }
            let dx   = playerPos.x - posComp.position.x
            let dy   = playerPos.y - posComp.position.y
            let dist = hypot(dx, dy)
            guard dist < attractRadius, dist > 0 else { continue }
            posComp.move(delta: CGPoint(x: (dx / dist) * attractSpeed * dt, y: (dy / dist) * attractSpeed * dt))
        }
    }

    // MARK: – Collect

    func collectCoin(entity: GKEntity, at pos: CGPoint, onScoreIncrease: (Int) -> Void) {
        guard let coin = entity as? CoinEntity else { return }
        scene?.entityManager.removeEntity(entity)
        AudioService.shared.play("coins.wav", volume: 0.18)
        onScoreIncrease(coin.value)
        floatText("+1", at: pos,
                  color: SKColor(red: 1, green: 0.85, blue: 0.1, alpha: 1))
    }

    func collectPowerUp(kind: PowerUpKind, entity: GKEntity, at pos: CGPoint,
                        player: PlayerEntity,
                        onHUDUpdate: () -> Void) {
        scene?.entityManager.removeEntity(entity)
        switch kind {
        case .life:
            player.health.heal()
            onHUDUpdate()
            floatText("+HEALTH", at: pos,
                      color: SKColor(red: 1, green: 0.3, blue: 0.3, alpha: 1))
        case .shield:
            player.shield.activate()
            AudioService.shared.play("shield.mp3", volume: 0.3)
            onHUDUpdate()
            floatText("+SHIELD", at: pos, color: .cyan)
        }
    }

    // MARK: – Drop

    func dropLoot(at pos: CGPoint, multiplier: Int) {
        guard let scene, let player else { return }

        let currentLives = player.health.lives
        let hasShield = player.shield.isActive
        let drops = LootComponent().roll(currentLives: currentLives, hasShield: hasShield)

        for drop in drops {
            switch drop {
            case .coin:
                for _ in 1...multiplier {
                    scene.entityManager.addEntity(CoinEntity(at: pos))
                }
            case .extraCoin:
                let offset = CGPoint(x: CGFloat.random(in: -15...15),
                                     y: CGFloat.random(in: -15...15))
                scene.entityManager.addEntity(CoinEntity(at: CGPoint(x: pos.x + offset.x,
                                                       y: pos.y + offset.y)))
            case .shield:
                scene.entityManager.addEntity(PowerUpEntity(kind: .shield, at: pos))
            case .life:
                scene.entityManager.addEntity(PowerUpEntity(kind: .life, at: pos))
            case .nothing:
                break
            }
        }
    }
//    func dropLoot(at pos: CGPoint, multiplier: Int) {
//        guard let scene else { return }
//        let drops = LootComponent().roll()
//
//        for drop in drops {
//            switch drop {
//            case .coin:
//                for _ in 1...multiplier {
//                    scene.entityManager.addEntity(CoinEntity(at: pos))
//                }
//            case .extraCoin:
//                let offset = CGPoint(x: CGFloat.random(in: -15...15),
//                                     y: CGFloat.random(in: -15...15))
//                scene.entityManager.addEntity(CoinEntity(at: CGPoint(x: pos.x + offset.x,
//                                                       y: pos.y + offset.y)))
//            case .shield:
//                scene.entityManager.addEntity(PowerUpEntity(kind: .shield, at: pos))
//            case .life:
//                scene.entityManager.addEntity(PowerUpEntity(kind: .life, at: pos))
//            case .nothing:
//                break
//            }
//        }
//    }

    // MARK: – Helpers

    private func floatText(_ text: String, at pos: CGPoint, color: SKColor) {
        guard let scene else { return }
        let lbl = SKLabelNode(fontNamed: StyleGuide.Typography.bold)
        lbl.text      = text
        lbl.fontSize  = 13
        lbl.fontColor = color
        lbl.position  = pos
        lbl.zPosition = 30
        scene.worldNode.addChild(lbl)

        lbl.run(SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 32, duration: 0.55),
                SKAction.fadeOut(withDuration: 0.55)
            ]),
            SKAction.removeFromParent()
        ]))
    }
}
