import SpriteKit
import GameplayKit

class SpawnSystem {

    // Configuração inicial
    private var spawnInterval: TimeInterval = 2.4
    private var maxEnemies = 7

    private var lastSpawnTime: TimeInterval = 0
    private weak var scene: GameScene?
    private let mapSize: CGSize

    init(scene: GameScene, mapSize: CGSize) {
        self.scene = scene
        self.mapSize = mapSize
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
        let existing = scene.entityManager.entities.filter { $0 is EnemyEntity }.count
        guard existing < maxEnemies else { return }

        let pos      = randomEdgePoint(in: mapSize)
        let enemy    = EnemyEntity(at: pos, hp: difficultyConfig.enemyHealth)
        scene.entityManager.addEntity(enemy)
    }

    private func randomEdgePoint(in size: CGSize) -> CGPoint {
        switch Int.random(in: 0...3) {
        case 0:  return CGPoint(x: CGFloat.random(in: 0...size.width), y: size.height)
        case 1:  return CGPoint(x: CGFloat.random(in: 0...size.width), y: 0)
        case 2:  return CGPoint(x: 0, y: CGFloat.random(in: 0...size.height))
        default: return CGPoint(x: size.width, y: CGFloat.random(in: 0...size.height))
        }
    }
}
