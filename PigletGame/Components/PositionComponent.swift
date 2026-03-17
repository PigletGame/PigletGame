//
//  PositionComponent.swift
//  FarmAttackExperiment
//
//  Created by Adriel de Souza on 16/03/26.
//


import GameplayKit

class PositionComponent: GKComponent {
    private(set) var position: CGPoint
    private(set) var lastDeltaPosition: CGPoint = .zero

    init(position: CGPoint) {
        self.position = position
        super.init()
    }

    func moveTo(_ position: CGPoint) {
        self.lastDeltaPosition = position - self.position
        self.position = position
    }

    func clamp(to rect: CGRect) {
        let clampedX = max(rect.minX, min(rect.maxX, position.x))
        let clampedY = max(rect.minY, min(rect.maxY, position.y))
        self.position = CGPoint(x: clampedX, y: clampedY)
    }

    func move(delta: CGPoint) {
        self.lastDeltaPosition = delta
        self.position += delta
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }
}
