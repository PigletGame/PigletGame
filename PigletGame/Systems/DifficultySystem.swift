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
    var onDificultyIncrease: ((Int) -> Void)?

    init(node: SKNode, sceneSize: CGSize, onDificultyIncrease: ((Int) -> Void)? = nil) {
        self.scene = node
        self.sceneSize = sceneSize
        self.onDificultyIncrease = onDificultyIncrease
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

        onDificultyIncrease?(config.level)
    }
}
