import SpriteKit

/// Parameters for difficulty at a given moment — passed to other systems.
struct DifficultyConfig {
    var level:              Int            = 1
    var spawnInterval:      TimeInterval   = 2.4
    var enemySpeed:         CGFloat        = 65
    var maxEnemies:         Int            = 7
    var rangedShotInterval: TimeInterval   = 3
    var enemyBulletSpeed:   CGFloat        = 120
    var meleeCooldown:      TimeInterval   = 2.0
    var coinsPerKill:       Int            = 1
    var enemyHealth:        Int            = 1
}

class DifficultySystem {

    private(set) var config = DifficultyConfig()

    private var lastDifficultyStep: TimeInterval = 0
    private let stepInterval: TimeInterval = 30
    private weak var scene: SKNode?
    private let sceneSize: CGSize

    init(node: SKNode, sceneSize: CGSize) {
        self.scene = node
        self.sceneSize = sceneSize
    }

    // MARK: – Update

    func update(elapsedTime: TimeInterval) {
        if elapsedTime - lastDifficultyStep >= stepInterval {
            lastDifficultyStep = elapsedTime
            ramp()
        }
    }

    // MARK: – Ramp

    private func ramp() {
        config.level             += 1
        config.spawnInterval      = max(0.65, config.spawnInterval - 0.24)
        config.enemySpeed         = min(175,  config.enemySpeed    + 11)
        config.maxEnemies         = min(24,   config.maxEnemies    + 2)
        config.rangedShotInterval = max(0.85, config.rangedShotInterval - 0.22)
        config.enemyBulletSpeed   = min(295,  config.enemyBulletSpeed   + 22)
        config.meleeCooldown      = max(1, config.meleeCooldown      - 0.09)
        config.coinsPerKill       = min(10,   config.coinsPerKill       + 1)
        config.enemyHealth        = min(5,    config.enemyHealth        + 1)

        showAlert()
    }

    private func showAlert() {
        guard let scene = self.scene else { return }
        
        let alert = SKLabelNode(fontNamed: StyleGuide.Typography.heavy)
        alert.text      = "Difficulty \(config.level)"
        alert.fontSize  = 22
        alert.fontColor = SKColor(red: 1, green: 0.3, blue: 0.1, alpha: 1)
        alert.position  = CGPoint(x: 0, y: sceneSize.height / 2 - 30)
        alert.zPosition = 100
        scene.addChild(alert)

        let sub = SKLabelNode(fontNamed: StyleGuide.Typography.bold)
        sub.text = "Stronger enemies, greater rewards"
        sub.fontSize = 14
        sub.fontColor = .white
        sub.position = CGPoint(x: 0, y: -24)
        alert.addChild(sub)

        alert.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ]))
    }
}
