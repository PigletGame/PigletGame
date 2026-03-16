import SpriteKit

// MARK: – Physics bitmasks
private struct PhysicsCategory {
    static let player:       UInt32 = 0b000001
    static let enemy:        UInt32 = 0b000010
    static let playerBullet: UInt32 = 0b000100
    static let enemyBullet:  UInt32 = 0b001000
    static let coin:         UInt32 = 0b010000
    static let powerUp:      UInt32 = 0b100000
}

// MARK: – GameScene
class GameScene: SKScene, SKPhysicsContactDelegate {

    // ––––– Player –––––
    private var player: SKShapeNode!
    private var playerLives = 3
    private var hasShield = false
    private var isInvincible = false
    private let playerSpeed: CGFloat = 190
    private let playerRadius: CGFloat = 18

    // ––––– Joysticks –––––
    private var leftJoystick: JoystickNode!
    private var rightJoystick: JoystickNode!
    private var leftTouch: UITouch?
    private var rightTouch: UITouch?
    private var leftJoyOrigin: CGPoint = .zero
    private var rightJoyOrigin: CGPoint = .zero

    // ––––– Shooting –––––
    private let bulletRadius: CGFloat = 5
    private let playerBulletSpeed: CGFloat = 500
    private var shootCooldown: TimeInterval = 0.12
    private var lastShotTime: TimeInterval = 0

    // ––––– HUD –––––
    private var killLabel: SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var heartNodes: [SKShapeNode] = []

    // ––––– Scoring –––––
    private var score = 0
    private var killCount = 0

    // ––––– Timing –––––
    private var elapsedTime: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0
    private var lastSpawnTime: TimeInterval = 0
    private var lastDifficultyStep: TimeInterval = 0
    private var scoreAccum: TimeInterval = 0

    // ––––– Difficulty –––––
    private var difficultyLevel = 1
    private var spawnInterval: TimeInterval = 2.4
    private var enemySpeed: CGFloat = 65
    private var maxEnemies = 7
    private var rangedShotInterval: TimeInterval = 2.6
    private var enemyBulletSpeed: CGFloat = 145
    private var meleeCooldown: TimeInterval = 1.1

    // ––––– Deferred removal –––––
    private var pendingRemovals = Set<ObjectIdentifier>()
    private var pendingRemovalNodes: [SKNode] = []

    // ––––– State –––––
    private var isGameOver = false

    // MARK: – Lifecycle

    override func didMove(to view: SKView) {
        AdCoordinator.shared.loadAd()
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        backgroundColor = .black
        setupArena()
        setupPlayer()
        setupHUD()
        setupJoysticks()
    }

    // MARK: – Setup
    private func setupArena() {
        let bg = SKSpriteNode(imageNamed: "arena")
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.size = size
        bg.zPosition = -10
        addChild(bg)
    }

    private func setupPlayer() {
        let pig = SKShapeNode(circleOfRadius: playerRadius)
        pig.fillColor = SKColor(red: 1.0, green: 0.72, blue: 0.72, alpha: 1)
        pig.strokeColor = SKColor(red: 0.85, green: 0.50, blue: 0.50, alpha: 1)
        pig.lineWidth = 2
        pig.position = CGPoint(x: size.width / 2, y: size.height / 2)
        pig.zPosition = 10
        pig.name = "player"

        // Pig details
        let nose = SKShapeNode(ellipseOf: CGSize(width: 13, height: 9))
        nose.fillColor = SKColor(red: 0.95, green: 0.60, blue: 0.60, alpha: 1)
        nose.strokeColor = .clear
        nose.position = CGPoint(x: 0, y: -5)
        nose.zPosition = 1
        pig.addChild(nose)

        for (dx, name) in [(-5.5, "eyeL"), (5.5, "eyeR")] {
            let eye = SKShapeNode(circleOfRadius: 2.8)
            eye.fillColor = .black
            eye.strokeColor = .clear
            eye.position = CGPoint(x: dx, y: 5)
            eye.zPosition = 1
            eye.name = name
            pig.addChild(eye)
        }

        let body = SKPhysicsBody(circleOfRadius: playerRadius)
        body.categoryBitMask    = PhysicsCategory.player
        body.contactTestBitMask = PhysicsCategory.enemyBullet | PhysicsCategory.coin | PhysicsCategory.powerUp
        body.collisionBitMask   = 0
        body.isDynamic = true
        body.linearDamping = 0
        pig.physicsBody = body

        player = pig
        addChild(player)
    }

    private func setupHUD() {
        // Dark strip behind HUD
        let strip = SKShapeNode(rectOf: CGSize(width: size.width, height: 38))
        strip.fillColor = SKColor(white: 0, alpha: 0.55)
        strip.strokeColor = .clear
        strip.position = CGPoint(x: size.width / 2, y: size.height - 18)
        strip.zPosition = 90
        addChild(strip)

        killLabel = makeHUDLabel(align: .left)
        killLabel.position = CGPoint(x: 16, y: size.height - 28)
        addChild(killLabel)

        scoreLabel = makeHUDLabel(align: .right)
        scoreLabel.position = CGPoint(x: size.width - 16, y: size.height - 28)
        addChild(scoreLabel)

        refreshHUD()
        refreshHearts()
    }

    private func makeHUDLabel(align: SKLabelHorizontalAlignmentMode) -> SKLabelNode {
        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.fontSize = 15
        lbl.fontColor = .white
        lbl.horizontalAlignmentMode = align
        lbl.verticalAlignmentMode = .center
        lbl.zPosition = 95
        return lbl
    }

    private func refreshHUD() {
        killLabel.text  = "☠ \(killCount)"
        scoreLabel.text = "⭐ \(score)"
    }

    private func refreshHearts() {
        heartNodes.forEach { $0.removeFromParent() }
        heartNodes.removeAll()

        let spacing: CGFloat = 26
        let total: CGFloat = spacing * 2
        let startX = size.width / 2 - total / 2

        for i in 0..<3 {
            let h = SKShapeNode(circleOfRadius: 9)
            h.fillColor  = i < playerLives ? SKColor(red: 0.9, green: 0.15, blue: 0.15, alpha: 1) : SKColor(white: 0.25, alpha: 1)
            h.strokeColor = SKColor(white: 1, alpha: 0.5)
            h.lineWidth  = 1.5
            h.position   = CGPoint(x: startX + CGFloat(i) * spacing, y: size.height - 20)
            h.zPosition  = 95
            addChild(h)
            heartNodes.append(h)
        }

        // Shield badge
        if hasShield {
            let shield = SKShapeNode(circleOfRadius: 9)
            shield.fillColor  = SKColor(red: 0.25, green: 0.55, blue: 1.0, alpha: 0.9)
            shield.strokeColor = .cyan
            shield.lineWidth  = 2
            shield.position   = CGPoint(x: startX + 3 * spacing, y: size.height - 20)
            shield.zPosition  = 95
            addChild(shield)
            heartNodes.append(shield)
        }
    }

    private func setupJoysticks() {
        let joyY: CGFloat = 80

        leftJoystick = JoystickNode(baseRadius: 55, thumbRadius: 22)
        leftJoystick.position  = CGPoint(x: 110, y: joyY)
        leftJoystick.zPosition = 50
        leftJoystick.alpha     = 0.65
        addChild(leftJoystick)

        rightJoystick = JoystickNode(baseRadius: 55, thumbRadius: 22)
        rightJoystick.position  = CGPoint(x: size.width - 110, y: joyY)
        rightJoystick.zPosition = 50
        rightJoystick.alpha     = 0.65
        addChild(rightJoystick)
    }

    // MARK: – Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let loc = touch.location(in: self)
            if loc.x < size.width / 2 {
                guard leftTouch == nil else { continue }
                leftTouch = touch
                leftJoyOrigin = loc
                leftJoystick.position = loc
                leftJoystick.reset()
            } else {
                guard rightTouch == nil else { continue }
                rightTouch = touch
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

        let dt: CGFloat = lastUpdateTime == 0 ? 0 : min(currentTime - lastUpdateTime, 0.05)
        lastUpdateTime = currentTime

        // Flush deferred removals from previous frame
        for node in pendingRemovalNodes { node.removeFromParent() }
        pendingRemovalNodes.removeAll()
        pendingRemovals.removeAll()

        elapsedTime += dt

        // Score counter
        scoreAccum += dt
        if scoreAccum >= 1.0 {
            score += 10
            scoreAccum -= 1.0
            refreshHUD()
        }

        // Player movement
        let vel = leftJoystick.velocity
        if vel != .zero {
            player.position.x += vel.x * playerSpeed * dt
            player.position.y += vel.y * playerSpeed * dt
        }
        clampPlayer()

        // Shooting via right joystick (threshold avoids phantom near-zero values)
        let aimVel = rightJoystick.velocity
        let aimMag = hypot(aimVel.x, aimVel.y)
        if aimMag > 0.12 {
            firePlayerBullet(direction: aimVel, at: currentTime)
        }

        // Enemy AI + melee damage
        updateEnemies(dt: dt, now: currentTime)

        // Coin attraction
        attractCoins()

        // Spawn
        if currentTime - lastSpawnTime >= spawnInterval {
            spawnEnemy()
            lastSpawnTime = currentTime
        }

        // Difficulty ramp every 30 s
        if elapsedTime - lastDifficultyStep >= 30, lastDifficultyStep > 0 || elapsedTime >= 30 {
            if elapsedTime - lastDifficultyStep >= 30 {
                rampDifficulty()
                lastDifficultyStep = elapsedTime
            }
        }
    }

    // MARK: – Player Helpers

    private func clampPlayer() {
        let m: CGFloat = 20
        player.position.x = max(m, min(size.width  - m, player.position.x))
        player.position.y = max(m, min(size.height - m, player.position.y))
    }

    // MARK: – Shooting

    private func firePlayerBullet(direction: CGPoint, at now: TimeInterval) {
        guard now - lastShotTime >= shootCooldown else { return }
        lastShotTime = now

        let bullet = SKShapeNode(circleOfRadius: bulletRadius)
        bullet.fillColor   = SKColor(red: 1.0, green: 0.92, blue: 0.25, alpha: 1)
        bullet.strokeColor = SKColor(red: 1.0, green: 0.65, blue: 0.1, alpha: 1)
        bullet.lineWidth   = 1.5
        bullet.position    = player.position
        bullet.zPosition   = 8
        bullet.name        = "playerBullet"

        let body = SKPhysicsBody(circleOfRadius: bulletRadius)
        body.categoryBitMask    = PhysicsCategory.playerBullet
        body.contactTestBitMask = PhysicsCategory.enemy
        body.collisionBitMask   = 0
        body.isDynamic          = true
        body.linearDamping      = 0
        bullet.physicsBody = body

        addChild(bullet)

        bullet.physicsBody?.velocity = CGVector(dx: direction.x * playerBulletSpeed,
                                                 dy: direction.y * playerBulletSpeed)
        bullet.run(SKAction.sequence([SKAction.wait(forDuration: 1.8),
                                      SKAction.removeFromParent()]))
    }

    // MARK: – Enemy Spawning

    private func spawnEnemy() {
        let existing = children.filter { $0.name == "enemy" }.count
        guard existing < maxEnemies else { return }

        let pos = randomEdgePoint()
        let isRanged = Double.random(in: 0...1) < (difficultyLevel > 1 ? 0.38 : 0.18)
        createEnemy(at: pos, ranged: isRanged)
    }

    private func randomEdgePoint() -> CGPoint {
        switch Int.random(in: 0...3) {
        case 0: return CGPoint(x: CGFloat.random(in: 0...size.width), y: size.height + 22)
        case 1: return CGPoint(x: CGFloat.random(in: 0...size.width), y: -22)
        case 2: return CGPoint(x: -22, y: CGFloat.random(in: 0...size.height))
        default:return CGPoint(x: size.width + 22, y: CGFloat.random(in: 0...size.height))
        }
    }

    private func createEnemy(at pos: CGPoint, ranged: Bool) {
        let radius: CGFloat = 17
        let e = SKShapeNode(circleOfRadius: radius)
        e.name      = "enemy"
        e.zPosition = 9
        e.position  = pos

        if ranged {
            // Purple ranged tiger
            e.fillColor   = SKColor(red: 0.50, green: 0.10, blue: 0.80, alpha: 1)
            e.strokeColor = SKColor(red: 0.30, green: 0.00, blue: 0.55, alpha: 1)
            e.lineWidth   = 2

            let inner = SKShapeNode(circleOfRadius: radius * 0.55)
            inner.fillColor   = SKColor(red: 0.75, green: 0.45, blue: 1.0, alpha: 0.6)
            inner.strokeColor = .clear
            inner.zPosition   = 1
            e.addChild(inner)

            e.userData = NSMutableDictionary(dictionary: ["type": "ranged",
                                                           "lastShot": 0.0,
                                                           "lastHit": 0.0])
        } else {
            // Orange melee tiger
            e.fillColor   = SKColor(red: 0.92, green: 0.40, blue: 0.08, alpha: 1)
            e.strokeColor = SKColor(red: 0.65, green: 0.20, blue: 0.00, alpha: 1)
            e.lineWidth   = 2

            // Stripes
            for angle in [CGFloat.pi / 4, -CGFloat.pi / 4] {
                let stripe = SKShapeNode(rectOf: CGSize(width: radius * 1.6, height: 3.5))
                stripe.fillColor   = SKColor(red: 0.60, green: 0.15, blue: 0.0, alpha: 0.7)
                stripe.strokeColor = .clear
                stripe.zRotation   = angle
                stripe.zPosition   = 1
                e.addChild(stripe)
            }
            e.userData = NSMutableDictionary(dictionary: ["type": "melee",
                                                           "lastHit": 0.0])
        }

        let body = SKPhysicsBody(circleOfRadius: radius)
        body.categoryBitMask    = PhysicsCategory.enemy
        body.contactTestBitMask = PhysicsCategory.playerBullet
        body.collisionBitMask   = 0
        body.isDynamic          = true
        body.linearDamping      = 0
        e.physicsBody = body

        addChild(e)
    }

    // MARK: – Enemy AI

    private func updateEnemies(dt: CGFloat, now: TimeInterval) {
        let enemies = children.filter { $0.name == "enemy" }

        for node in enemies {
            guard let e = node as? SKShapeNode else { continue }
            let dx = player.position.x - e.position.x
            let dy = player.position.y - e.position.y
            let dist = hypot(dx, dy)
            guard dist > 0 else { continue }

            let type = e.userData?["type"] as? String ?? "melee"

            if type == "melee" {
                // Chase directly
                let nx = dx / dist, ny = dy / dist
                e.position.x += nx * enemySpeed * dt
                e.position.y += ny * enemySpeed * dt

                // Melee damage on proximity
                if dist < playerRadius + 20 {
                    let lastHit = (e.userData?["lastHit"] as? Double) ?? 0
                    if elapsedTime - lastHit >= meleeCooldown {
                        e.userData?["lastHit"] = elapsedTime
                        damagePlayer()
                    }
                }

            } else {
                // Ranged: orbit at preferred distance
                let preferred: CGFloat = 195
                let nx = dx / dist, ny = dy / dist
                let speed = enemySpeed * 0.72

                if dist > preferred + 25 {
                    e.position.x += nx * speed * dt
                    e.position.y += ny * speed * dt
                } else if dist < preferred - 25 {
                    e.position.x -= nx * speed * dt
                    e.position.y -= ny * speed * dt
                } else {
                    // Strafe perpendicular
                    e.position.x += (-ny) * speed * 0.5 * dt
                    e.position.y += nx   * speed * 0.5 * dt
                }

                // Shoot
                let lastShot = (e.userData?["lastShot"] as? Double) ?? 0
                if now - lastShot >= rangedShotInterval {
                    e.userData?["lastShot"] = now
                    fireEnemyBullet(from: e.position)
                }
            }
        }
    }

    private func fireEnemyBullet(from pos: CGPoint) {
        let dx = player.position.x - pos.x
        let dy = player.position.y - pos.y
        let dist = hypot(dx, dy)
        guard dist > 0 else { return }

        let bullet = SKShapeNode(circleOfRadius: 5)
        bullet.fillColor   = SKColor(red: 0.95, green: 0.15, blue: 0.15, alpha: 1)
        bullet.strokeColor = SKColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1)
        bullet.lineWidth   = 1
        bullet.position    = pos
        bullet.zPosition   = 8
        bullet.name        = "enemyBullet"

        let body = SKPhysicsBody(circleOfRadius: 5)
        body.categoryBitMask    = PhysicsCategory.enemyBullet
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask   = 0
        body.isDynamic          = true
        body.linearDamping      = 0
        bullet.physicsBody = body

        addChild(bullet)
        bullet.physicsBody?.velocity = CGVector(dx: (dx / dist) * enemyBulletSpeed,
                                                 dy: (dy / dist) * enemyBulletSpeed)
        bullet.run(SKAction.sequence([SKAction.wait(forDuration: 3.5),
                                      SKAction.removeFromParent()]))
    }

    // MARK: – Physics Contacts

    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA, b = contact.bodyB

        // Player bullet ↔ enemy
        if matchContact(a, b, cat1: PhysicsCategory.playerBullet, cat2: PhysicsCategory.enemy) {
            let bulletNode = a.categoryBitMask == PhysicsCategory.playerBullet ? a.node : b.node
            let enemyNode  = a.categoryBitMask == PhysicsCategory.enemy ? a.node : b.node
            deferRemove(bulletNode)
            if let en = enemyNode, !pendingRemovals.contains(ObjectIdentifier(en)) {
                deferRemove(en)
                onEnemyKilled(en)
            }
        }

        // Enemy bullet ↔ player
        if matchContact(a, b, cat1: PhysicsCategory.enemyBullet, cat2: PhysicsCategory.player) {
            let bulletNode = a.categoryBitMask == PhysicsCategory.enemyBullet ? a.node : b.node
            deferRemove(bulletNode)
            damagePlayer()
        }

        // Coin ↔ player
        if matchContact(a, b, cat1: PhysicsCategory.coin, cat2: PhysicsCategory.player) {
            let coinNode = a.categoryBitMask == PhysicsCategory.coin ? a.node : b.node
            if let cn = coinNode, !pendingRemovals.contains(ObjectIdentifier(cn)) {
                deferRemove(cn)
                collectCoin(at: cn.position)
            }
        }

        // PowerUp ↔ player
        if matchContact(a, b, cat1: PhysicsCategory.powerUp, cat2: PhysicsCategory.player) {
            let puNode = a.categoryBitMask == PhysicsCategory.powerUp ? a.node : b.node
            if let pu = puNode, !pendingRemovals.contains(ObjectIdentifier(pu)) {
                let kind = pu.userData?["kind"] as? String ?? ""
                deferRemove(pu)
                collectPowerUp(kind: kind, at: pu.position)
            }
        }
    }

    private func matchContact(_ a: SKPhysicsBody, _ b: SKPhysicsBody,
                               cat1: UInt32, cat2: UInt32) -> Bool {
        (a.categoryBitMask == cat1 && b.categoryBitMask == cat2) ||
        (a.categoryBitMask == cat2 && b.categoryBitMask == cat1)
    }

    private func deferRemove(_ node: SKNode?) {
        guard let n = node else { return }
        let id = ObjectIdentifier(n)
        guard !pendingRemovals.contains(id) else { return }
        pendingRemovals.insert(id)
        pendingRemovalNodes.append(n)
    }

    // MARK: – Enemy Killed

    private func onEnemyKilled(_ node: SKNode) {
        killCount += 1
        score += 25
        refreshHUD()

        spawnDeathFX(at: node.position)
        dropLoot(at: node.position)
    }

    private func spawnDeathFX(at pos: CGPoint) {
        for _ in 0..<8 {
            let p = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...5))
            p.fillColor   = [SKColor.orange, SKColor.red, SKColor.yellow].randomElement()!
            p.strokeColor = .clear
            p.position    = pos
            p.zPosition   = 7
            addChild(p)

            let angle  = CGFloat.random(in: 0...(2 * .pi))
            let spd    = CGFloat.random(in: 55...130)
            let move   = SKAction.move(by: CGVector(dx: cos(angle) * spd * 0.35,
                                                     dy: sin(angle) * spd * 0.35),
                                        duration: 0.35)
            let fade   = SKAction.fadeOut(withDuration: 0.35)
            let remove = SKAction.removeFromParent()
            p.run(SKAction.sequence([SKAction.group([move, fade]), remove]))
        }
    }

    // MARK: – Loot

    private func dropLoot(at pos: CGPoint) {
        spawnCoin(at: pos)
        if Double.random(in: 0...1) < 0.35 {
            let offset = CGPoint(x: CGFloat.random(in: -15...15),
                                 y: CGFloat.random(in: -15...15))
            spawnCoin(at: CGPoint(x: pos.x + offset.x, y: pos.y + offset.y))
        }

        let roll = Double.random(in: 0...1)
        if roll < 0.05 {
            spawnPowerUp(at: pos, kind: "shield")
        } else if roll < 0.09 {
            spawnPowerUp(at: pos, kind: "life")
        }
    }

    private func spawnCoin(at pos: CGPoint) {
        let coin = SKShapeNode(circleOfRadius: 7)
        coin.fillColor   = SKColor(red: 1.0, green: 0.85, blue: 0.1, alpha: 1)
        coin.strokeColor = SKColor(red: 0.75, green: 0.55, blue: 0, alpha: 1)
        coin.lineWidth   = 2
        coin.position    = pos
        coin.zPosition   = 5
        coin.name        = "coin"

        let body = SKPhysicsBody(circleOfRadius: 7)
        body.categoryBitMask    = PhysicsCategory.coin
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask   = 0
        body.isDynamic          = false
        coin.physicsBody = body
        addChild(coin)

        // Drift outward
        let drift = SKAction.move(by: CGVector(dx: CGFloat.random(in: -22...22),
                                                dy: CGFloat.random(in: -22...22)),
                                   duration: 0.25)
        let blink = SKAction.repeat(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.2),
            SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        ]), count: 5)
        let remove = SKAction.removeFromParent()
        coin.run(SKAction.sequence([drift,
                                    SKAction.wait(forDuration: 6.0),
                                    blink,
                                    remove]))
    }

    private func spawnPowerUp(at pos: CGPoint, kind: String) {
        let pu = SKShapeNode(circleOfRadius: 11)
        pu.name     = "powerUp"
        pu.position = pos
        pu.zPosition = 5
        pu.lineWidth = 2.5
        pu.userData  = NSMutableDictionary(dictionary: ["kind": kind])

        if kind == "life" {
            pu.fillColor   = SKColor(red: 0.95, green: 0.15, blue: 0.15, alpha: 1)
            pu.strokeColor = .white
        } else {
            pu.fillColor   = SKColor(red: 0.20, green: 0.50, blue: 1.0, alpha: 1)
            pu.strokeColor = .cyan
        }

        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.25, duration: 0.45),
            SKAction.scale(to: 0.88, duration: 0.45)
        ]))
        pu.run(pulse)

        let body = SKPhysicsBody(circleOfRadius: 11)
        body.categoryBitMask    = PhysicsCategory.powerUp
        body.contactTestBitMask = PhysicsCategory.player
        body.collisionBitMask   = 0
        body.isDynamic          = false
        pu.physicsBody = body
        addChild(pu)

        pu.run(SKAction.sequence([SKAction.wait(forDuration: 10),
                                   SKAction.removeFromParent()]))
    }

    // MARK: – Coin Attraction

    private func attractCoins() {
        let attractRadius: CGFloat = 55
        let attractSpeed: CGFloat  = 320
        let dt: CGFloat = 1.0 / 60.0

        for node in children where node.name == "coin" {
            let dx = player.position.x - node.position.x
            let dy = player.position.y - node.position.y
            let dist = hypot(dx, dy)
            if dist < attractRadius && dist > 0 {
                node.position.x += (dx / dist) * attractSpeed * dt
                node.position.y += (dy / dist) * attractSpeed * dt
            }
        }
    }

    // MARK: – Collect

    private func collectCoin(at pos: CGPoint) {
        score += 5
        refreshHUD()
        floatText("+5", at: pos, color: SKColor(red: 1, green: 0.85, blue: 0.1, alpha: 1))
    }

    private func collectPowerUp(kind: String, at pos: CGPoint) {
        if kind == "life" {
            if playerLives < 3 {
                playerLives += 1
                refreshHearts()
                floatText("+VIDA ❤️", at: pos, color: SKColor(red: 1, green: 0.3, blue: 0.3, alpha: 1))
            }
        } else if kind == "shield" {
            hasShield = true
            attachShieldVisual()
            refreshHearts()
            floatText("+ESCUDO 🛡", at: pos, color: .cyan)
        }
    }

    private func attachShieldVisual() {
        player.childNode(withName: "shieldVisual")?.removeFromParent()
        let sv = SKShapeNode(circleOfRadius: playerRadius + 8)
        sv.strokeColor = .cyan
        sv.fillColor   = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.18)
        sv.lineWidth   = 3
        sv.name        = "shieldVisual"
        sv.zPosition   = 3
        player.addChild(sv)

        let spin = SKAction.repeatForever(SKAction.rotate(byAngle: .pi * 2, duration: 2.2))
        sv.run(spin)
    }

    // MARK: – Damage

    private func damagePlayer() {
        guard !isInvincible else { return }

        if hasShield {
            hasShield = false
            player.childNode(withName: "shieldVisual")?.removeFromParent()
            refreshHearts()
            flashPlayer(color: .cyan)
            return
        }

        playerLives -= 1
        refreshHearts()

        if playerLives <= 0 {
            triggerGameOver()
            return
        }

        // Invincibility frames
        isInvincible = true
        let flash = SKAction.repeat(SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.9, duration: 0.08),
            SKAction.colorize(with: SKColor(red: 1, green: 0.72, blue: 0.72, alpha: 1),
                              colorBlendFactor: 0, duration: 0.08)
        ]), count: 7)
        player.run(flash) { self.isInvincible = false }
    }

    private func flashPlayer(color: SKColor) {
        let flash = SKAction.sequence([
            SKAction.colorize(with: color, colorBlendFactor: 1, duration: 0.1),
            SKAction.colorize(with: SKColor(red: 1, green: 0.72, blue: 0.72, alpha: 1),
                              colorBlendFactor: 0, duration: 0.15)
        ])
        player.run(flash)
    }

    // MARK: – Difficulty

    private func rampDifficulty() {
        difficultyLevel += 1
        spawnInterval      = max(0.65, spawnInterval - 0.24)
        enemySpeed         = min(175, enemySpeed + 11)
        maxEnemies         = min(24, maxEnemies + 2)
        rangedShotInterval = max(0.85, rangedShotInterval - 0.22)
        enemyBulletSpeed   = min(295, enemyBulletSpeed + 22)
        meleeCooldown      = max(0.48, meleeCooldown - 0.09)

        let alert = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        alert.text      = "⚡ Dificuldade \(difficultyLevel)!"
        alert.fontSize  = 22
        alert.fontColor = SKColor(red: 1, green: 0.3, blue: 0.1, alpha: 1)
        alert.position  = CGPoint(x: size.width / 2, y: size.height / 2 + 55)
        alert.zPosition = 100
        addChild(alert)

        alert.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.6),
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: – Float text helper

    private func floatText(_ text: String, at pos: CGPoint, color: SKColor) {
        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.text      = text
        lbl.fontSize  = 13
        lbl.fontColor = color
        lbl.position  = pos
        lbl.zPosition = 30
        addChild(lbl)

        lbl.run(SKAction.sequence([
            SKAction.group([SKAction.moveBy(x: 0, y: 32, duration: 0.55),
                            SKAction.fadeOut(withDuration: 0.55)]),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: – Game Over

    private func triggerGameOver() {
        isGameOver = true
        physicsWorld.speed = 0

        // Dramatic pause then transition
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.6),
            SKAction.run { [weak self] in
                guard let self else { return }
                let scene = GameOverScene(score: self.score,
                                         kills: self.killCount,
                                         time: Int(self.elapsedTime))
                scene.scaleMode = .resizeFill
                self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.55))
            }
        ]))
    }
}
