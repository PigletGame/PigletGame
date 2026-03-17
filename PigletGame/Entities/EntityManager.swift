//
//  EntityManager.swift
//  FarmAttackExperiment
//
//  Created by Adriel de Souza on 16/03/26.
//

import GameplayKit


class EntityManager {
    private(set) var entities: [GKEntity] = []
    let baseNode: SKNode
    
    init(baseNode: SKNode) {
        self.baseNode = baseNode
    }
    
    func addEntity(_ entity: GKEntity) {
        entities.append(entity)
        
        if let visual = VisualComponent.from(entity) {
            baseNode.addChild(visual.node)
        }
    }
    
    func removeEntity(_ entity: GKEntity) {
        entities.removeAll { $0 === entity }
        
        if let visual = VisualComponent.from(entity) {
            visual.node.removeFromParent()
        }
    }
    
    func update(deltaTime: TimeInterval) {
        // Cleanup entities whose visual nodes were removed (e.g. by animations)
        let toRemove = entities.filter { entity in
            if let visual = VisualComponent.from(entity) {
                return visual.node.parent == nil
            }
            return false
        }
        toRemove.forEach { removeEntity($0) }

        for entity in entities {
            entity.update(deltaTime: deltaTime)
        }
    }
}
