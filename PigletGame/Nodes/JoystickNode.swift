import SpriteKit

class JoystickNode: SKNode {

    private let baseRadius:  CGFloat
    private let thumbRadius: CGFloat

    let baseShape:  SKShapeNode
    let thumbShape: SKShapeNode

    /// Velocidade normalizada em [-1, 1] por eixo. Zero quando inativo.
    var velocity: CGPoint = .zero

    init(baseRadius: CGFloat = 60, thumbRadius: CGFloat = 24) {
        self.baseRadius  = baseRadius
        self.thumbRadius = thumbRadius

        baseShape = SKShapeNode(circleOfRadius: baseRadius)
        baseShape.fillColor   = UIColor.white.withAlphaComponent(0.12)
        baseShape.strokeColor = UIColor.white.withAlphaComponent(0.4)
        baseShape.lineWidth   = 2

        thumbShape = SKShapeNode(circleOfRadius: thumbRadius)
        thumbShape.fillColor   = UIColor.white.withAlphaComponent(0.45)
        thumbShape.strokeColor = UIColor.white.withAlphaComponent(0.75)
        thumbShape.lineWidth   = 2

        super.init()
        addChild(baseShape)
        addChild(thumbShape)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    /// Chame sempre que o dedo se mover; `delta` é o offset desde o toque inicial.
    func updateThumb(to delta: CGPoint) {
        let dist = hypot(delta.x, delta.y)
        if dist <= baseRadius {
            thumbShape.position = delta
            velocity = CGPoint(x: delta.x / baseRadius, y: delta.y / baseRadius)
        } else {
            let angle = atan2(delta.y, delta.x)
            thumbShape.position = CGPoint(x: cos(angle) * baseRadius,
                                          y: sin(angle) * baseRadius)
            velocity = CGPoint(x: cos(angle), y: sin(angle))
        }
    }

    func reset() {
        thumbShape.position = .zero
        velocity = .zero
    }
}
