import Foundation

enum EnemyType {
    case melee
    case ranged
}

class AIComponent {

    let type: EnemyType
    var lastShotTime: TimeInterval = 0
    var lastHitTime:  TimeInterval = 0

    init(type: EnemyType) {
        self.type = type
    }
}
