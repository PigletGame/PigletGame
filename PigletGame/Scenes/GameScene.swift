import SpriteKit
import SwiftUI
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
    private var isPausedManually = false

    // map config
    let tileWidth: CGFloat = 16
    let mapWidthInTiles = 30
    let mapHeightInTiles = 30
    let mapPadding = 100
    var mapSize: CGSize {
        .init(width: (Double(mapWidthInTiles) * tileWidth), height: (Double(mapHeightInTiles) * tileWidth))
    }

    var dismiss: DismissAction?
    var onPause: (() -> Void)?

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
        cameraNode.setScale(0.65)

        setupLevel()
        setupJoysticks()
        setupPlayer()
        setupHUD()
        setupSystems()
    }

    // MARK: – Setup

    private func setupLevel() {
        for x in -mapPadding..<mapWidthInTiles+mapPadding {
            for y in -mapPadding..<mapHeightInTiles+mapPadding {
                var textureName = "Tile/Grass"
                var xScale: CGFloat = 1.0
                
                // Pebble center
                if x >= 0 && x <= mapWidthInTiles && y >= -1 && y <= mapHeightInTiles {
                    textureName = "Tile/Pebble"
                }

                // Vertical Fences
                else if (x == -1 ||  x == mapWidthInTiles + 1)  && y >= -1 && y <= mapHeightInTiles {
                    textureName = "Tile/Fence_TD"
                }

                // Horizontal Fences
                else if (y == -2  || y == mapHeightInTiles + 1) && x >= 0 && x <= mapWidthInTiles {
                    textureName = "Tile/Fence_LR"
                }

                // Corners Bottom
                else if x == -1 && y == -2 {
                    textureName = "Tile/Fence_Corner_Bottom"
                } else if x == mapWidthInTiles + 1 && y == -2 {
                    textureName = "Tile/Fence_Corner_Bottom"
                    xScale = -1.0
                }

                // Corners Top
                else if x == -1 && y == mapHeightInTiles + 1 {
                    textureName = "Tile/Fence_Corner_Top"
                } else if x == mapWidthInTiles + 1 && y == mapHeightInTiles + 1 {
                    textureName = "Tile/Fence_Corner_Top"
                    xScale = -1.0
                }

                let tile = SKSpriteNode(imageNamed: textureName)
                tile.texture?.filteringMode = .nearest
                tile.anchorPoint = .zero
                tile.xScale = xScale

                let xPosition = CGFloat(x) * tileWidth
                let yPosition = CGFloat(y) * tileWidth
                
                // Adjust position if flipped horizontally since anchor is at (0,0)
                let finalX = xScale < 0 ? xPosition + tileWidth : xPosition

                tile.position = CGPoint(x: finalX, y: yPosition)
                tile.zPosition = -10
                tile.size = .init(width: tileWidth, height: tileWidth)
                worldNode.addChild(tile)
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
        hud.onPausePressed = { [weak self] in
            self?.pauseGame()
        }
        cameraNode.addChild(hud)
        refreshHUD()
    }

    func pauseGame() {
        guard !isGameOver else { return }
        isPausedManually = true
        self.isPaused = true
        onPause?()
    }

    func resumeGame() {
        isPausedManually = false
        self.isPaused = false
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
        guard !isGameOver && !isPausedManually else { return }

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
                            VisualComponent.from(enemy)?.flash(color: .red, duration: 0.1)
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
        coinSystem.dropLoot(at: pos, multiplier: multiplier)
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
                guard let self else {return}

                let scene = GameOverScene(
                    score: self.score,
                    coins: self.coinCount,
                    kills: self.killCount,
                    time: Int(self.elapsedTime)
                )
                scene.dismiss = self.dismiss

                scene.scaleMode = .resizeFill
                self.view?.presentScene(scene,
                                        transition: SKTransition.fade(withDuration: 0.55))
            }
        ]))
    }
}
