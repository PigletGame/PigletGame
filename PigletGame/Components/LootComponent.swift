import Foundation
import GameplayKit

/// Define as probabilidades de drop de loot ao matar um inimigo.
class LootComponent: GKComponent {

    /// Chance de dropar uma segunda moeda além da primeira (sempre cai).
    var extraCoinChance: Double = 0.35

    /// Chance de dropar um escudo.
    var shieldDropChance: Double = 0.05

    /// Chance de dropar uma vida extra (testada depois do escudo).
    var lifeDropChance: Double = 0.09

    // MARK: – Roll

    enum DropResult {
        case coin
        case extraCoin
        case shield
        case life
        case nothing
    }

    func roll(currentLives: Int, hasShield: Bool) -> [DropResult] {
        var results: [DropResult] = [.coin]

        if Double.random(in: 0...1) < extraCoinChance {
            results.append(.extraCoin)
        }

        let maxLives = 3
        let missingLives = max(0, maxLives - currentLives)

        let lifeChance: Double = currentLives == maxLives
            ? 0.0
            : min(0.25, 0.05 + Double(missingLives) * 0.08)

        let shieldChance = hasShield ? 0.0 : shieldDropChance

        let roll = Double.random(in: 0...1)

        if roll < lifeChance {
            results.append(.life)
        } else if roll < lifeChance + shieldChance {
            results.append(.shield)
        }

        return results
    }
}
