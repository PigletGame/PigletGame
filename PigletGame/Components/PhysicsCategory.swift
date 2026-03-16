import Foundation

struct PhysicsCategory {
    static let player:       UInt32 = 0b000001
    static let enemy:        UInt32 = 0b000010
    static let playerBullet: UInt32 = 0b000100
    static let enemyBullet:  UInt32 = 0b001000
    static let coin:         UInt32 = 0b010000
    static let powerUp:      UInt32 = 0b100000
}
