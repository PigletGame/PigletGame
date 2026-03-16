import GameplayKit

class HealthComponent: GKComponent {

    static let maxLives = 3

    private(set) var lives: Int
    private(set) var isInvincible: Bool = false

    init(lives: Int = HealthComponent.maxLives) {
        self.lives = lives
        super.init()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }


    var isDead: Bool { lives <= 0 }

    /// Tenta aplicar dano. Retorna `true` se o dano foi absorvido pelo escudo
    /// ou pelo estado de invencibilidade (caller não precisa fazer nada).
    /// Retorna `false` quando a vida foi descontada de fato.
    @discardableResult
    func takeDamage() -> DamageResult {
        guard !isInvincible else { return .ignored }
        lives = max(0, lives - 1)
        return .hit
    }

    func heal() {
        guard lives < HealthComponent.maxLives else { return }
        lives += 1
    }

    func setInvincible(_ value: Bool) {
        isInvincible = value
    }

    enum DamageResult {
        case ignored
        case hit
    }
}
