//
//  JoystickNode.swift
//  FarmAttackExperiment
//
//  Created by Adriel de Souza on 16/03/26.
//

import SpriteKit

class JoystickNode: SKNode {

    // MARK: - Configuration

    private let baseRadius: CGFloat
    private let thumbRadius: CGFloat

    enum Side { case left, right }
    private let side: Side

    // MARK: - Visual

    let baseShape: SKShapeNode
    let thumbShape: SKShapeNode
    private let touchArea: SKShapeNode

    // MARK: - Public state

    private(set) var movement: CGPoint = .zero

    // MARK: - Private touch state

    private var trackedTouch: UITouch?

    // MARK: - Init

    init(side: Side, baseRadius: CGFloat = 55, thumbRadius: CGFloat = 22) {
        self.side        = side
        self.baseRadius  = baseRadius
        self.thumbRadius = thumbRadius

        baseShape = SKShapeNode(circleOfRadius: baseRadius)
        baseShape.fillColor   = UIColor.white.withAlphaComponent(0.12)
        baseShape.strokeColor = UIColor.white.withAlphaComponent(0.40)
        baseShape.lineWidth   = 2

        thumbShape = SKShapeNode(circleOfRadius: thumbRadius)
        thumbShape.fillColor   = UIColor.white.withAlphaComponent(0.45)
        thumbShape.strokeColor = UIColor.white.withAlphaComponent(0.75)
        thumbShape.lineWidth   = 2
        
        // Large invisible touch area to catch nearby touches
        touchArea = SKShapeNode(circleOfRadius: baseRadius * 3)
        touchArea.fillColor = .clear
        touchArea.strokeColor = .clear

        super.init()

        isUserInteractionEnabled = true
        addChild(touchArea)
        addChild(baseShape)
        addChild(thumbShape)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Touch handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard trackedTouch == nil,
              let touch = touches.first else { return }

        // Since isUserInteractionEnabled is true and this node is correctly 
        // positioned on its side, SpriteKit's hit testing already ensures 
        // the touch is intended for this joystick.
        trackedTouch = touch
        let loc = touch.location(in: self)
        updateThumb(to: loc)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = trackedTouch, touches.contains(touch) else { return }

        // Use position relative to joystick center so thumb follows the finger
        let loc = touch.location(in: self)
        updateThumb(to: loc)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = trackedTouch, touches.contains(touch) else { return }
        trackedTouch = nil
        reset()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    // MARK: - Internal helpers

    private func updateThumb(to position: CGPoint) {
        let dist = hypot(position.x, position.y)

        if dist <= baseRadius {
            thumbShape.position = position
            movement = CGPoint(x: position.x / baseRadius,
                               y: position.y / baseRadius)
        } else {
            let angle = atan2(position.y, position.x)
            thumbShape.position = CGPoint(x: cos(angle) * baseRadius,
                                          y: sin(angle) * baseRadius)
            movement = CGPoint(x: cos(angle), y: sin(angle))
        }
    }

    func reset() {
        thumbShape.position = .zero
        movement = .zero
    }
}
