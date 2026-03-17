import GameplayKit

class AIComponent: GKComponent {
    var lastHitTime: TimeInterval = 0

    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }
}
