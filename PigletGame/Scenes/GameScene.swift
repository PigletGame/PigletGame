import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: – Nodes

    private var player: PlayerEntity!
    private var hud:    HUDNode!
    private var leftJoystick:  JoystickNode!
    private var rightJoystick: JoystickNode!

    // MARK: – Systems

    private var spawnSystem:      SpawnSystem!
    private var combatSystem:     CombatSystem!
    private var coinSystem:       CoinSystem!
    private var difficultySystem: DifficultySystem!
    private var contactSystem:    ContactSystem!

    // MARK: – State

    private var score:       Int = 0
    private var killCount:   Int = 0
    private var elapsedTime: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0
    private var scoreAccum:  TimeInterval = 0
    private var isGameOver   = false

    // MARK: – Touch tracking

    private var leftTouch:    UITouch?
    private var rightTouch:   UITouch?
    private var leftJoyOrigin:  CGPoint = .zero
    private var rightJoyOrigin: CGPoint = .zero

    // MARK: – Lifecycle

    override func didMove(to view: SKView) {
        physicsWorld.gravity         = .zero
        physicsWorld.contactDelegate = self
        backgroundColor = .black

        setupArena()
        setupPlayer()
        setupHUD()
        setupJoysticks()
        setupSystems()
    }

    // MARK: – Setup

    private func setupArena() {
        let bg = SKSpriteNode(imageNamed: "arena")
        bg.position  = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.size      = size
        bg.zPosition = -10
        addChild(bg)
    }

    private func setupPlayer() {
        player          = PlayerEntity()
        player.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(player)
    }

    private func setupHUD() {
        hud = HUDNode(sceneSize: size)
        addChild(hud)
        refreshHUD()
    }

    private func setupJoysticks() {
        let joyY: CGFloat = 80

        leftJoystick          = JoystickNode(baseRadius: 55, thumbRadius: 22)
        leftJoystick.position = CGPoint(x: 110, y: joyY)
        leftJoystick.zPosition = 50
        leftJoystick.alpha    = 0.65
        addChild(leftJoystick)

        rightJoystick          = JoystickNode(baseRadius: 55, thumbRadius: 22)
        rightJoystick.position = CGPoint(x: size.width - 110, y: joyY)
        rightJoystick.zPosition = 50
        rightJoystick.alpha    = 0.65
        addChild(rightJoystick)
    }

    private func setupSystems() {
        difficultySystem = DifficultySystem(scene: self)
        spawnSystem      = SpawnSystem(scene: self)
        combatSystem     = CombatSystem(scene: self, player: player)
        coinSystem       = CoinSystem(scene: self, player: player)
        contactSystem    = ContactSystem()
    }

    // MARK: – HUD

    private func refreshHUD() {
        hud.update(score: score,
                   kills: killCount,
                   lives: player.health.lives,
                   hasShield: player.shield.isActive)
    }

    // MARK: – Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let loc = touch.location(in: self)
            if loc.x < size.width / 2 {
                guard leftTouch == nil else { continue }
                leftTouch     = touch
                leftJoyOrigin = loc
                leftJoystick.position = loc
                leftJoystick.reset()
            } else {
                guard rightTouch == nil else { continue }
                rightTouch     = touch
                rightJoyOrigin = loc
                rightJoystick.position = loc
                rightJoystick.reset()
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let loc = touch.location(in: self)
            if touch === leftTouch {
                leftJoystick.updateThumb(to: CGPoint(x: loc.x - leftJoyOrigin.x,
                                                      y: loc.y - leftJoyOrigin.y))
            } else if touch === rightTouch {
                rightJoystick.updateThumb(to: CGPoint(x: loc.x - rightJoyOrigin.x,
                                                       y: loc.y - rightJoyOrigin.y))
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch === leftTouch  { leftTouch  = nil; leftJoystick.reset() }
            if touch === rightTouch { rightTouch = nil; rightJoystick.reset() }
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    // MARK: – Update Loop

    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        let dt: CGFloat = lastUpdateTime == 0
            ? 0
            : min(currentTime - lastUpdateTime, 0.05)
        lastUpdateTime = currentTime
        elapsedTime   += dt

        // Flush removals pendentes do frame anterior
        contactSystem.flushRemovals()

        // Score por sobrevivência
        scoreAccum += dt
        if scoreAccum >= 1.0 {
            score      += 10
            scoreAccum -= 1.0
            refreshHUD()
        }

        // Movimento do player via joystick esquerdo
        player.move(velocity: leftJoystick.velocity, dt: dt, in: size)

        // Tiro via joystick direito
        let aimVel = rightJoystick.velocity
        if hypot(aimVel.x, aimVel.y) > 0.12 {
            combatSystem.tryFirePlayerBullet(direction: aimVel, at: currentTime)
        }

        // IA dos inimigos
        combatSystem.updateEnemies(
            dt: dt, now: currentTime,
            elapsedTime: elapsedTime,
            config: difficultySystem.config,
            onMeleeDamage: { [weak self] in self?.handlePlayerDamage() }
        )

        // Atração de moedas
        coinSystem.attractCoins(dt: dt)

        // Spawn
        spawnSystem.update(currentTime: currentTime,
                           difficultyConfig: difficultySystem.config)

        // Dificuldade
        difficultySystem.update(elapsedTime: elapsedTime)
    }

    // MARK: – Physics Contacts

    func didBegin(_ contact: SKPhysicsContact) {
        contactSystem.handle(
            contact: contact,
            player: player,
            onEnemyKilled: { [weak self] node in
                self?.handleEnemyKilled(node)
            },
            onPlayerDamaged: { [weak self] in
                self?.handlePlayerDamage()
            },
            onCoinCollected: { [weak self] pos in
                self?.handleCoinCollected(at: pos)
            },
            onPowerUpCollected: { [weak self] kind, pos in
                self?.handlePowerUpCollected(kind: kind, at: pos)
            }
        )
    }

    // MARK: – Event Handlers

    private func handleEnemyKilled(_ node: SKNode) {
        killCount += 1
        combatSystem.onEnemyKilled(node) { [weak self] points in
            self?.score += points
            self?.refreshHUD()
        }
        coinSystem.dropLoot(at: node.position)
    }

    private func handlePlayerDamage() {
        combatSystem.damagePlayer(player: player) { [weak self] in
            self?.triggerGameOver()
        }
        refreshHUD()
    }

    private func handleCoinCollected(at pos: CGPoint) {
        coinSystem.collectCoin(at: pos) { [weak self] points in
            self?.score += points
            self?.refreshHUD()
        }
    }

    private func handlePowerUpCollected(kind: PowerUpKind, at pos: CGPoint) {
        coinSystem.collectPowerUp(kind: kind, at: pos, player: player) { [weak self] in
            self?.refreshHUD()
        }
    }

    // MARK: – Game Over

    private func triggerGameOver() {
        isGameOver = true
        physicsWorld.speed = 0

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
