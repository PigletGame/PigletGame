import SpriteKit

/// Parâmetros de dificuldade em um dado instante — passado para os outros sistemas.
struct DifficultyConfig {
    var level:              Int            = 1
    var spawnInterval:      TimeInterval   = 2.4
    var enemySpeed:         CGFloat        = 65
    var maxEnemies:         Int            = 7
    var rangedShotInterval: TimeInterval   = 2.6
    var enemyBulletSpeed:   CGFloat        = 145
    var meleeCooldown:      TimeInterval   = 1.1
}

class DifficultySystem {

    private(set) var config = DifficultyConfig()

    private var lastDifficultyStep: TimeInterval = 0
    private let stepInterval: TimeInterval = 30
    private weak var scene: SKScene?

    init(scene: SKScene) {
        self.scene = scene
    }

    // MARK: – Update

    func update(elapsedTime: TimeInterval) {
        guard elapsedTime >= stepInterval else { return }
        guard elapsedTime - lastDifficultyStep >= stepInterval else { return }
        lastDifficultyStep = elapsedTime
        ramp()
    }

    // MARK: – Ramp

    private func ramp() {
        config.level             += 1
        config.spawnInterval      = max(0.65, config.spawnInterval - 0.24)
        config.enemySpeed         = min(175,  config.enemySpeed    + 11)
        config.maxEnemies         = min(24,   config.maxEnemies    + 2)
        config.rangedShotInterval = max(0.85, config.rangedShotInterval - 0.22)
        config.enemyBulletSpeed   = min(295,  config.enemyBulletSpeed   + 22)
        config.meleeCooldown      = max(0.48, config.meleeCooldown      - 0.09)

        showAlert()
    }

    private func showAlert() {
        guard let scene else { return }
        let alert = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        alert.text      = "⚡ Dificuldade \(config.level)!"
        alert.fontSize  = 22
        alert.fontColor = SKColor(red: 1, green: 0.3, blue: 0.1, alpha: 1)
        alert.position  = CGPoint(x: 0, y: 0)
        alert.zPosition = 100
        scene.addChild(alert)

        alert.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.6),
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.removeFromParent()
        ]))
    }
}
