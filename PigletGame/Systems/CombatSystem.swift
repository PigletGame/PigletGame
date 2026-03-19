import SpriteKit
import GameplayKit
import UIKit

class CombatSystem {

    private let playerBulletSpeed: CGFloat  = 500
    private var shootCooldown: TimeInterval = 0.12
    private var lastShotTime: TimeInterval  = 0

    private weak var scene: GameScene?
    private weak var player: PlayerEntity?

    init(scene: GameScene, player: PlayerEntity) {
        self.scene  = scene
        self.player = player
    }

    // MARK: – Player Shooting

    func tryFirePlayerBullet(direction: CGPoint, position: CGPoint, at now: TimeInterval) {
        guard now - lastShotTime >= shootCooldown else { return }
        guard let scene else { return }
        lastShotTime = now

        AudioService.shared.play("shot.wav", volume: 0.08)

        let bullet = BulletEntity(position: position, direaction: direction, sprite: "PLACEHOLDER/arrow")
        scene.entityManager.addEntity(bullet)
    }

    // MARK: – Enemy AI

    func updateEnemies(dt: CGFloat, now: TimeInterval,
                       elapsedTime: TimeInterval,
                       config: DifficultyConfig,
                       onMeleeDamage: () -> Void) {
        guard let scene, let player else { return }

        let enemies = scene.entityManager.entities.compactMap { $0 as? EnemyEntity }
        let playerPos = player.component(ofType: PositionComponent.self)?.position ?? .zero

        for enemy in enemies {
            guard let enemyPosComp = enemy.component(ofType: PositionComponent.self) else { continue }
            let enemyPos = enemyPosComp.position
            let dx   = playerPos.x - enemyPos.x
            let dy   = playerPos.y - enemyPos.y
            let dist = hypot(dx, dy)
            guard dist > 0 else { continue }

            // Stop moving if close enough to player to avoid fully overlapping
            let stopDistance = PlayerEntity.radius + EnemyEntity.radius - 10
            if dist > stopDistance {
                moveEnemy(enemyPosComp, dx: dx, dy: dy, dist: dist, speed: config.enemySpeed, dt: dt)
            }
            
            if dist <= stopDistance + 5 {
                if elapsedTime - player.lastHitTime >= config.meleeCooldown {
                    player.lastHitTime = elapsedTime // Update immediately so other enemies wait
                    onMeleeDamage()
                }
            }
        }
    }

    private func moveEnemy(_ enemyPos: PositionComponent, dx: CGFloat, dy: CGFloat,
                            dist: CGFloat, speed: CGFloat, dt: CGFloat) {
        enemyPos.move(delta: CGPoint(x: (dx / dist) * speed * dt, y: (dy / dist) * speed * dt))
    }

    // MARK: – Enemy Killed

    func onEnemyKilled(_ entity: GKEntity, onScoreIncrease: (Int) -> Void) {
        if let pos = entity.component(ofType: PositionComponent.self)?.position {
            spawnDeathFX(at: pos)
        }
        scene?.entityManager.removeEntity(entity)
        AudioService.shared.play("tiger.m4a", volume: 0.08)

        onScoreIncrease(25)
    }

    private func spawnDeathFX(at pos: CGPoint) {
        guard let scene else { return }
        for _ in 0..<8 {
            let p = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            p.fillColor   = [SKColor.orange, SKColor.red, SKColor.yellow].randomElement()!
            p.strokeColor = .clear
            p.position    = pos
            p.zPosition   = 7
            scene.worldNode.addChild(p)

            let angle = CGFloat.random(in: 0...(2 * .pi))
            let spd   = CGFloat.random(in: 55...130)
            let move  = SKAction.move(by: CGVector(dx: cos(angle) * spd * 0.35,
                                                    dy: sin(angle) * spd * 0.35),
                                      duration: 0.35)
            p.run(SKAction.sequence([
                SKAction.group([move, SKAction.fadeOut(withDuration: 0.35)]),
                SKAction.removeFromParent()
            ]))
        }
    }

    // MARK: – Player Damage

    func damagePlayer(player: PlayerEntity, onGameOver: () -> Void) {
        let health = player.health
        let shield = player.shield

        if shield.absorbHit() {
            player.flashColor(.cyan)
            return
        }

        let result = health.takeDamage()
        guard result == .hit else { return }
        
        AudioService.shared.play("pig.m4a", volume: 0.08)

        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        if health.isDead {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            onGameOver()
            return
        }

        health.setInvincible(true)
        player.flashDamage {
            health.setInvincible(false)
        }
    }
}
