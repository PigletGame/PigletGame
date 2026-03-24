import GameplayKit

class HealthComponent: GKComponent {

    static let initialLives = 3

    private(set) var lives: Int
    private(set) var isInvincible: Bool = false

    init(lives: Int = HealthComponent.initialLives) {
        self.lives = lives
        super.init()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    var isDead: Bool { lives <= 0 }

    var onDeath: (() -> Void)?

    @discardableResult
    func takeDamage() -> DamageResult {
        guard !isInvincible else { return .ignored }
        lives = max(0, lives - 1)
        if isDead { onDeath?() }
        return .hit
    }

    func heal() {
        lives += 1  // sem teto — acumula livremente
    }

    func setInvincible(_ value: Bool) {
        isInvincible = value
    }

    enum DamageResult {
        case ignored
        case hit
    }
}
