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

    /// Retorna a lista de drops para um único inimigo morto.
    func roll() -> [DropResult] {
        var results: [DropResult] = [.coin]

        if Double.random(in: 0...1) < extraCoinChance {
            results.append(.extraCoin)
        }

        let roll = Double.random(in: 0...1)
        if roll < shieldDropChance {
            results.append(.shield)
        } else if roll < shieldDropChance + lifeDropChance {
            results.append(.life)
        }

        return results
    }
}
