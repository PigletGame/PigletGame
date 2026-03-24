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
    private let iconNode: SKSpriteNode

    // MARK: - Public state

    private(set) var movement: CGPoint = .zero

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

        let iconName = side == .left ? "leftJoystick" : "rightJoystick"
        iconNode = SKSpriteNode(imageNamed: iconName)
        iconNode.size = CGSize(width: thumbRadius * 1.5, height: thumbRadius * 1.5)
        iconNode.zPosition = 1
        iconNode.color = .darkGray
        iconNode.colorBlendFactor = 0.45

        super.init()

        isUserInteractionEnabled = false
        addChild(baseShape)
        addChild(thumbShape)
        thumbShape.addChild(iconNode)

        isHidden = true
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Public control

    func activate(at point: CGPoint) {
        position = point
        isHidden = false
        reset()
    }

    func updateTouch(at pointInParent: CGPoint) {
        let localPoint = CGPoint(x: pointInParent.x - position.x,
                                 y: pointInParent.y - position.y)
        updateThumb(to: localPoint)
    }

    func deactivate() {
        reset()
        isHidden = true
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
