import SpriteKit

class SpawnSystem {

    // Configuração inicial
    private var spawnInterval: TimeInterval = 2.4
    private var maxEnemies = 7

    private var lastSpawnTime: TimeInterval = 0
    private weak var scene: SKScene?

    init(scene: SKScene) {
        self.scene = scene
    }

    // MARK: – Update

    func update(currentTime: TimeInterval, difficultyConfig: DifficultyConfig) {
        spawnInterval = difficultyConfig.spawnInterval
        maxEnemies    = difficultyConfig.maxEnemies

        guard currentTime - lastSpawnTime >= spawnInterval else { return }
        lastSpawnTime = currentTime
        spawnEnemy(difficultyConfig: difficultyConfig)
    }

    // MARK: – Spawn

    private func spawnEnemy(difficultyConfig: DifficultyConfig) {
        guard let scene else { return }
        let existing = scene.children.filter { $0.name == "enemy" }.count
        guard existing < maxEnemies else { return }

        let pos      = randomEdgePoint(in: scene.size)
        let isRanged = Double.random(in: 0...1) < (difficultyConfig.level > 1 ? 0.38 : 0.18)
        let enemy    = EnemyEntity(type: isRanged ? .ranged : .melee, at: pos)
        scene.addChild(enemy)
    }

    private func randomEdgePoint(in size: CGSize) -> CGPoint {
        switch Int.random(in: 0...3) {
        case 0:  return CGPoint(x: CGFloat.random(in: 0...size.width), y: size.height + 22)
        case 1:  return CGPoint(x: CGFloat.random(in: 0...size.width), y: -22)
        case 2:  return CGPoint(x: -22, y: CGFloat.random(in: 0...size.height))
        default: return CGPoint(x: size.width + 22, y: CGFloat.random(in: 0...size.height))
        }
    }
}
