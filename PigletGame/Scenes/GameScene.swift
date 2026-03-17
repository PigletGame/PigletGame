import SpriteKit
import GameplayKit

class GameScene: SKScene {

    // MARK: – ECS & Nodes

    let entityManager: EntityManager
    let worldNode = SKNode()
    let cameraNode = SKCameraNode()

    private var player: PlayerEntity!
    private var hud:    HUDNode!
    private var leftJoystick:  JoystickNode!
    private var rightJoystick: JoystickNode!

    // MARK: – Systems

    private var spawnSystem:      SpawnSystem!
    private var combatSystem:     CombatSystem!
    private var coinSystem:       CoinSystem!
    private var difficultySystem: DifficultySystem!

    // MARK: – State

    private var score:       Int = 0
    private var killCount:   Int = 0
    private var coinCount:   Int = 0
    private var elapsedTime: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0
    private var scoreAccum:  TimeInterval = 0
    private var isGameOver   = false

    // map config
    let tileWidth: CGFloat = 16
    let mapWidthInTiles = 30
    let mapHeightInTiles = 30
    var mapSize: CGSize {
        .init(width: (Double(mapWidthInTiles) * tileWidth), height: (Double(mapHeightInTiles) * tileWidth))
    }

    override init() {
        entityManager = .init(baseNode: worldNode)
        super.init()
    }

    override init(size: CGSize) {
        entityManager = .init(baseNode: worldNode)
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: – Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
        view.isMultipleTouchEnabled = true

        addChild(worldNode)

        self.camera = cameraNode
        worldNode.addChild(cameraNode)
        cameraNode.setScale(0.5)

        setupLevel()
        setupJoysticks()
        setupPlayer()
        setupHUD()
        setupSystems()
    }

    // MARK: – Setup

    private func setupLevel() {
        // Create the Floor
        for x in 0..<mapWidthInTiles {
            for y in 0..<mapHeightInTiles {
                let grass = SKSpriteNode(imageNamed: "Tile/Grass/Middle")
                grass.texture?.filteringMode = .nearest
                grass.anchorPoint = .zero

                let xPosition = CGFloat(x) * tileWidth
                let yPosition = CGFloat(y) * tileWidth

                grass.position = CGPoint(x: xPosition, y: yPosition)
                grass.zPosition = -10
                worldNode.addChild(grass)
            }
        }
    }

    private func setupPlayer() {
        player = PlayerEntity(
            position: CGPoint(x: mapSize.width / 2, y: mapSize.height / 2),
            leftJoystick: leftJoystick,
            rightJoystick: rightJoystick
        ) { [weak self] pos, dir in
            // handled by combatSystem or directly
            self?.combatSystem.tryFirePlayerBullet(direction: dir, position: pos, at: CFAbsoluteTimeGetCurrent())
        }
        entityManager.addEntity(player)
    }

    private func setupHUD() {
        hud = HUDNode(sceneSize: size)
        cameraNode.addChild(hud)
        refreshHUD()
    }

    private func setupJoysticks() {
        leftJoystick = JoystickNode(side: .left)
        leftJoystick.zPosition = 99
        leftJoystick.position = .init(
            x: -size.width / 2 + 100,
            y: -size.height / 2 + 100
        )
        cameraNode.addChild(leftJoystick)

        rightJoystick = JoystickNode(side: .right)
        rightJoystick.zPosition = 99
        rightJoystick.position = .init(
            x: size.width / 2 - 100,
            y: -size.height / 2 + 100
        )
        cameraNode.addChild(rightJoystick)
    }

    private func setupSystems() {
        difficultySystem = DifficultySystem(node: cameraNode, sceneSize: size)
        spawnSystem      = SpawnSystem(scene: self, mapSize: mapSize)
        combatSystem     = CombatSystem(scene: self, player: player)
        coinSystem       = CoinSystem(scene: self, player: player)
    }

    // MARK: – HUD

    private func refreshHUD() {
        hud.update(score: score,
                   kills: killCount,
                   coins: coinCount,
                   lives: player.health.lives,
                   hasShield: player.shield.isActive)
    }

    // MARK: – Update Loop

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        elapsedTime   += dt

        entityManager.update(deltaTime: dt)

        if let posComponent = player.component(ofType: PositionComponent.self) {
            posComponent.clamp(to: CGRect(origin: .zero, size: mapSize))
            cameraNode.position = posComponent.position
        }

        scoreAccum += dt
        if scoreAccum >= 1.0 {
            score      += 10
            scoreAccum -= 1.0
            refreshHUD()
        }

        // IA dos inimigos
        combatSystem.updateEnemies(
            dt: CGFloat(dt), now: currentTime,
            elapsedTime: elapsedTime,
            config: difficultySystem.config,
            onMeleeDamage: { [weak self] in self?.handlePlayerDamage() }
        )

        // Atração de moedas
        coinSystem.attractCoins(dt: CGFloat(dt))

        // Spawn
        spawnSystem.update(currentTime: currentTime,
                           difficultyConfig: difficultySystem.config)

        // Dificuldade
        difficultySystem.update(elapsedTime: elapsedTime)

        // Manual Collisions
        checkCollisions()
    }

    // MARK: – Collisions

    private func checkCollisions() {
        let playerPos = player.component(ofType: PositionComponent.self)?.position ?? .zero
        let enemies = entityManager.entities.compactMap { $0 as? EnemyEntity }
        let coins = entityManager.entities.compactMap { $0 as? CoinEntity }
        let powerups = entityManager.entities.compactMap { $0 as? PowerUpEntity }
        let bullets = entityManager.entities.compactMap { $0 as? BulletEntity }

        // Bullet vs Enemy
        for bullet in bullets {
            guard let bulletPos = bullet.component(ofType: PositionComponent.self)?.position else { continue }
            for enemy in enemies {
                guard let enemyPos = enemy.component(ofType: PositionComponent.self)?.position else { continue }
                let dist = hypot(bulletPos.x - enemyPos.x, bulletPos.y - enemyPos.y)
                if dist < BulletEntity.radius + EnemyEntity.radius {
                    entityManager.removeEntity(bullet)
                    
                    let result = enemy.health.takeDamage()
                    if result == .hit {
                        if enemy.health.isDead {
                            handleEnemyKilled(enemy)
                        } else {
                            // Visual feedback for hit
                            enemy.component(ofType: VisualComponent.self)?.flash(color: .white, duration: 0.1)
                        }
                    }
                    break
                }
            }
        }

        // Player vs Coin
        for coin in coins {
            guard let coinPos = coin.component(ofType: PositionComponent.self)?.position else { continue }
            let dist = hypot(playerPos.x - coinPos.x, playerPos.y - coinPos.y)
            if dist < PlayerEntity.radius + CoinEntity.radius {
                handleCoinCollected(entity: coin)
            }
        }

        // Player vs PowerUp
        for powerup in powerups {
            guard let puPos = powerup.component(ofType: PositionComponent.self)?.position else { continue }
            let dist = hypot(playerPos.x - puPos.x, playerPos.y - puPos.y)
            if dist < PlayerEntity.radius + PowerUpEntity.radius {
                handlePowerUpCollected(kind: powerup.kind, entity: powerup)
            }
        }
    }

    // MARK: – Event Handlers

    private func handleEnemyKilled(_ entity: GKEntity) {
        killCount += 1
        let pos = entity.component(ofType: PositionComponent.self)?.position ?? .zero
        combatSystem.onEnemyKilled(entity) { [weak self] points in
            self?.score += points
            self?.refreshHUD()
        }
        
        let multiplier = difficultySystem.config.coinsPerKill
        for _ in 0..<multiplier {
            coinSystem.dropLoot(at: pos)
        }
    }

    private func handlePlayerDamage() {
        combatSystem.damagePlayer(player: player) { [weak self] in
            self?.triggerGameOver()
        }
        refreshHUD()
    }

    private func handleCoinCollected(entity: GKEntity) {
        let pos = entity.component(ofType: PositionComponent.self)?.position ?? .zero
        coinSystem.collectCoin(entity: entity, at: pos) { [weak self] points in
            self?.score += points
            self?.coinCount += 1
            self?.refreshHUD()
        }
    }

    private func handlePowerUpCollected(kind: PowerUpKind, entity: GKEntity) {
        let pos = entity.component(ofType: PositionComponent.self)?.position ?? .zero
        coinSystem.collectPowerUp(kind: kind, entity: entity, at: pos, player: player) { [weak self] in
            self?.refreshHUD()
        }
    }

    // MARK: – Game Over

    private func triggerGameOver() {
        isGameOver = true
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.6),
            SKAction.run { [weak self] in
                guard let self else { return }
                let scene = GameOverScene(score: self.score,
                                          kills: self.killCount,
                                          time: Int(self.elapsedTime))
                scene.scaleMode = .resizeFill
                self.view?.presentScene(scene,
                                        transition: SKTransition.fade(withDuration: 0.55))
            }
        ]))
    }
}
