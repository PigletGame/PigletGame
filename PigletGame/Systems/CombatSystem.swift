import SpriteKit

class CombatSystem {

    private let playerBulletSpeed: CGFloat  = 500
    private var shootCooldown: TimeInterval = 0.12
    private var lastShotTime: TimeInterval  = 0

    private weak var scene: SKScene?
    private weak var player: PlayerEntity?

    init(scene: SKScene, player: PlayerEntity) {
        self.scene  = scene
        self.player = player
    }

    // MARK: – Player Shooting

    func tryFirePlayerBullet(direction: CGPoint, at now: TimeInterval) {
        guard now - lastShotTime >= shootCooldown else { return }
        guard let scene, let player else { return }
        lastShotTime = now

        let vel = CGVector(dx: direction.x * playerBulletSpeed,
                           dy: direction.y * playerBulletSpeed)
        let bullet = BulletNode(owner: .player, position: player.position, velocity: vel)
        scene.addChild(bullet)
    }

    // MARK: – Enemy AI & Shooting

    func updateEnemies(dt: CGFloat, now: TimeInterval,
                       elapsedTime: TimeInterval,
                       config: DifficultyConfig,
                       onMeleeDamage: () -> Void) {
        guard let scene, let player else { return }

        let enemies = scene.children.compactMap { $0 as? EnemyEntity }

        for enemy in enemies {
            let dx   = player.position.x - enemy.position.x
            let dy   = player.position.y - enemy.position.y
            let dist = hypot(dx, dy)
            guard dist > 0 else { continue }

            switch enemy.ai.type {
            case .melee:
                moveEnemy(enemy, dx: dx, dy: dy, dist: dist, speed: config.enemySpeed, dt: dt)
                if dist < PlayerEntity.radius + 20 {
                    if elapsedTime - enemy.ai.lastHitTime >= config.meleeCooldown {
                        enemy.ai.lastHitTime = elapsedTime
                        onMeleeDamage()
                    }
                }

            case .ranged:
                orbitEnemy(enemy, dx: dx, dy: dy, dist: dist, speed: config.enemySpeed, dt: dt)
                if now - enemy.ai.lastShotTime >= config.rangedShotInterval {
                    enemy.ai.lastShotTime = now
                    fireEnemyBullet(from: enemy.position,
                                    toward: player.position,
                                    speed: config.enemyBulletSpeed)
                }
            }
        }
    }

    private func moveEnemy(_ enemy: EnemyEntity, dx: CGFloat, dy: CGFloat,
                            dist: CGFloat, speed: CGFloat, dt: CGFloat) {
        enemy.position.x += (dx / dist) * speed * dt
        enemy.position.y += (dy / dist) * speed * dt
    }

    private func orbitEnemy(_ enemy: EnemyEntity, dx: CGFloat, dy: CGFloat,
                             dist: CGFloat, speed: CGFloat, dt: CGFloat) {
        let preferred: CGFloat = 195
        let nx = dx / dist
        let ny = dy / dist
        let orbitSpeed = speed * 0.72

        if dist > preferred + 25 {
            enemy.position.x += nx * orbitSpeed * dt
            enemy.position.y += ny * orbitSpeed * dt
        } else if dist < preferred - 25 {
            enemy.position.x -= nx * orbitSpeed * dt
            enemy.position.y -= ny * orbitSpeed * dt
        } else {
            enemy.position.x += (-ny) * orbitSpeed * 0.5 * dt
            enemy.position.y +=   nx  * orbitSpeed * 0.5 * dt
        }
    }

    private func fireEnemyBullet(from pos: CGPoint, toward target: CGPoint, speed: CGFloat) {
        guard let scene else { return }
        let dx   = target.x - pos.x
        let dy   = target.y - pos.y
        let dist = hypot(dx, dy)
        guard dist > 0 else { return }

        let vel    = CGVector(dx: (dx / dist) * speed, dy: (dy / dist) * speed)
        let bullet = BulletNode(owner: .enemy, position: pos, velocity: vel)
        scene.addChild(bullet)
    }

    // MARK: – Enemy Killed

    func onEnemyKilled(_ node: SKNode, onScoreIncrease: (Int) -> Void) {
        spawnDeathFX(at: node.position)
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
            scene.addChild(p)

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

        if health.isDead {
            onGameOver()
            return
        }

        health.setInvincible(true)
        player.flashDamage {
            health.setInvincible(false)
        }
    }
}
