//
//  ContentView.swift
//  PigletGame
//
//  Created by Adriel de Souza on 13/03/26.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geometry in
            let scene: SKScene = {
                let scene = VillageScene(size: geometry.size)
                scene.dismiss = dismiss
                scene.scaleMode = .resizeFill
                return scene
            }()

            SpriteView(scene: scene)
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    GameView()
}
