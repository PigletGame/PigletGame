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
    private var leftJoystickTouchId: ObjectIdentifier?
    private var rightJoystickTouchId: ObjectIdentifier?

    // MARK: – Systems

    private var spawnSystem:      SpawnSystem!
    private var combatSystem:     CombatSystem!
    private var coinSystem:       ItemPickupSystem!
    private var difficultySystem: DifficultySystem!

    // MARK: – State

    private var score:       Int = 0
    private var killCount:   Int = 0
    private var coinCount:   Int = 0
    private var elapsedTime: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0
//    private var scoreAccum:  TimeInterval = 0
    private var isGameOver   = false
    private var isPausedManually = false {
        didSet {
            isResumingGame = !isPausedManually
        }
    }
    private var isResumingGame = false

    // map config
    let tileWidth: CGFloat = 16
    let mapWidthInTiles = 30
    let mapHeightInTiles = 30
    let mapPadding = 20
    var mapSize: CGSize {
        .init(width: (Double(mapWidthInTiles) * tileWidth), height: (Double(mapHeightInTiles) * tileWidth))
    }

    var dismiss: DismissAction?
    var onPause: (() -> Void)?
    var onRankUp: ((Int) -> Void)?
    var onComplete: ((Int, Int, Int) -> Void)?

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
        
        // Music transition
        AudioService.shared.stop("menu.mp3")
        AudioService.shared.play("inGameCombat.mp3", loop: true, volume: 0.07)
        if isPaused {
            AudioService.shared.pause("inGameCombat.mp3")
        }
    }

    // MARK: – Setup
    private func setupLevel() {
        // Create noise for terrain distribution
        let noiseSource = GKPerlinNoiseSource(frequency: 0.2, octaveCount: 3, persistence: 0.5, lacunarity: 2.0, seed: Int32.random(in: 0...1000))
        let noise = GKNoise(noiseSource)
        let noiseMap = GKNoiseMap(noise, size: vector_double2(Double(mapWidthInTiles + 2 * mapPadding), Double(mapHeightInTiles + 2 * mapPadding)),
                                  origin: vector_double2(0, 0),
                                  sampleCount: vector_int2(Int32(mapWidthInTiles + 2 * mapPadding), Int32(mapHeightInTiles + 2 * mapPadding)),
                                  seamless: false)

        for x in -mapPadding..<mapWidthInTiles+mapPadding {
            for y in -mapPadding..<mapHeightInTiles+mapPadding {
                
                let xPosition = CGFloat(x) * tileWidth
                let yPosition = CGFloat(y) * tileWidth

                // 1. Check if inside Pebble center area
                if x >= 0 && x <= mapWidthInTiles && y >= -1 && y <= mapHeightInTiles {
                    let noiseX = Int32(x + mapPadding)
                    let noiseY = Int32(y + mapPadding)
                    let noiseValue = noiseMap.value(at: vector_int2(noiseX, noiseY))

                    // Always Pebble as base
                    let base = SKSpriteNode(imageNamed: "Tile/Pebble")
                    base.texture?.filteringMode = .nearest
                    base.anchorPoint = .zero
                    base.position = CGPoint(x: xPosition, y: yPosition)
                    base.zPosition = -10
                    base.size = .init(width: tileWidth, height: tileWidth)
                    worldNode.addChild(base)

                    // Overlay Grass with opacity based on noise
                    let grass = SKSpriteNode(imageNamed: "Tile/Pebble_Grass")
                    grass.texture?.filteringMode = .nearest
                    grass.anchorPoint = .zero
                    grass.position = base.position
                    grass.zPosition = -9
                    grass.size = base.size
                    
                    // Smooth transition: use noise value (usually -1 to 1)
                    let alphaVal = CGFloat((noiseValue - 0.0) / 0.5)
                    grass.alpha = max(0, min(1, alphaVal))
                    
                    if grass.alpha > 0 {
                        worldNode.addChild(grass)
                    }
                    continue
                }

                // 2. Otherwise handle Fences or Background Grass
                var textureName = "Tile/Grass"
                var xScale: CGFloat = 1.0
                
                if (x == -1 || x == mapWidthInTiles + 1) && y >= -1 && y <= mapHeightInTiles {
                    textureName = "Tile/Fence_TD"
                } else if (y == -2 || y == mapHeightInTiles + 1) && x >= 0 && x <= mapWidthInTiles {
                    textureName = "Tile/Fence_LR"
                } else if x == -1 && y == -2 {
                    textureName = "Tile/Fence_Corner_Bottom"
                } else if x == mapWidthInTiles + 1 && y == -2 {
                    textureName = "Tile/Fence_Corner_Bottom"
                    xScale = -1.0
                } else if x == -1 && y == mapHeightInTiles + 1 {
                    textureName = "Tile/Fence_Corner_Top"
                } else if x == mapWidthInTiles + 1 && y == mapHeightInTiles + 1 {
                    textureName = "Tile/Fence_Corner_Top"
                    xScale = -1.0
                }

                let finalX = xScale < 0 ? xPosition + tileWidth : xPosition
                let tile = SKSpriteNode(imageNamed: textureName)
                tile.texture?.filteringMode = .nearest
                tile.anchorPoint = .zero
                tile.position = CGPoint(x: finalX, y: yPosition)
                tile.zPosition = -10
                tile.xScale = xScale
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
        releaseAllJoystickTouches()
        leftJoystick.alpha = 0
        rightJoystick.alpha = 0
        AudioService.shared.pause("inGameCombat.mp3")
        onPause?()
    }

    func resumeGame() {
        isPausedManually = false
        self.isPaused = false
        leftJoystick.alpha = 1
        rightJoystick.alpha = 1
        AudioService.shared.resume("inGameCombat.mp3")
    }

    private func setupJoysticks() {
        leftJoystick = JoystickNode(side: .left)
        leftJoystick.zPosition = 99
        leftJoystick.deactivate()
        cameraNode.addChild(leftJoystick)

        rightJoystick = JoystickNode(side: .right)
        rightJoystick.zPosition = 99
        rightJoystick.deactivate()
        cameraNode.addChild(rightJoystick)
    }

    // MARK: - Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver, !isPausedManually else { return }

        for touch in touches {
            if isTouchInHUD(touch) { continue }

            let touchId = ObjectIdentifier(touch)
            let pointInCamera = touch.location(in: cameraNode)

            if pointInCamera.x < 0 {
                guard leftJoystickTouchId == nil else { continue }
                leftJoystickTouchId = touchId
                leftJoystick.activate(at: pointInCamera)
                leftJoystick.updateTouch(at: pointInCamera)
            } else {
                guard rightJoystickTouchId == nil else { continue }
                rightJoystickTouchId = touchId
                rightJoystick.activate(at: pointInCamera)
                rightJoystick.updateTouch(at: pointInCamera)
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }

        for touch in touches {
            let touchId = ObjectIdentifier(touch)
            let pointInCamera = touch.location(in: cameraNode)

            if leftJoystickTouchId == touchId {
                leftJoystick.updateTouch(at: pointInCamera)
            } else if rightJoystickTouchId == touchId {
                rightJoystick.updateTouch(at: pointInCamera)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            releaseJoystickTouch(touch)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    private func releaseJoystickTouch(_ touch: UITouch) {
        let touchId = ObjectIdentifier(touch)

        if leftJoystickTouchId == touchId {
            leftJoystickTouchId = nil
            leftJoystick.deactivate()
        }

        if rightJoystickTouchId == touchId {
            rightJoystickTouchId = nil
            rightJoystick.deactivate()
        }
    }

    private func releaseAllJoystickTouches() {
        leftJoystickTouchId = nil
        rightJoystickTouchId = nil
        leftJoystick?.deactivate()
        rightJoystick?.deactivate()
    }

    private func isTouchInHUD(_ touch: UITouch) -> Bool {
        let pointInScene = touch.location(in: self)
        let touchedNodes = nodes(at: pointInScene)

        return touchedNodes.contains { node in
            var current: SKNode? = node
            while let currentNode = current {
                if currentNode === hud {
                    return true
                }
                current = currentNode.parent
            }
            return false
        }
    }

    private func setupSystems() {
        difficultySystem = DifficultySystem(node: cameraNode, sceneSize: size, onDificultyIncrease: self.onRankUp)
        spawnSystem      = SpawnSystem(scene: self, mapSize: mapSize)
        combatSystem     = CombatSystem(scene: self, player: player)
        coinSystem       = ItemPickupSystem(scene: self, player: player)
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
        print(self.entityManager.entities.count)
        if isResumingGame { lastUpdateTime = currentTime; isResumingGame = false }
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

//        scoreAccum += dt
//        if scoreAccum >= 1.0 {
//            score      += 10
//            scoreAccum -= 1.0
//            refreshHUD()
//        }

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

            if bulletPos.x < tileWidth * -10
                || bulletPos.y < tileWidth * -10
                || bulletPos.x > mapSize.width * 1.5
                || bulletPos.y > mapSize.height * 1.5 {
                entityManager.removeEntity(bullet)
            }

            for enemy in enemies {
                guard let enemyPos = enemy.component(ofType: PositionComponent.self)?.position else { continue }
                let dist = hypot(bulletPos.x - enemyPos.x, bulletPos.y - enemyPos.y)
                if dist < BulletEntity.radius + EnemyEntity.radius {
                    entityManager.removeEntity(bullet)
                    
                    let result = enemy.health.takeDamage()
                    if result == .hit {
                        HapticsService.shared.vibrate(with: .light)
                        if enemy.health.isDead {
                            handleEnemyKilled(enemy)
                        } else {
                            // Visual feedback for hit with immunity
                            let immunityDuration: TimeInterval = 0.5
                            enemy.health.setInvincible(true)
                            VisualComponent.from(enemy)?.blink(colors: [.red, .white], duration: immunityDuration) {
                                enemy.health.setInvincible(false)
                            }
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
        releaseAllJoystickTouches()
        
        // Music transition and endind haptics
        AudioService.shared.stop("inGameCombat.mp3")
        HapticsService.shared.vibrate(with: .gameOver)
        AudioService.shared.play("gameOver.mp3", loop: false)

        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.6),
            SKAction.run { [weak self] in
                guard let self else {return}
                self.onComplete?(self.coinCount, self.killCount, Int(self.elapsedTime))
            }
        ]))
    }
}

//#Preview {
//    GameScene()
//}
