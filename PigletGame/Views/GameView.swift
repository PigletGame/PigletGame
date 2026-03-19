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
    @State private var isPaused = false
    @State private var gameScene: GameScene?

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                if let scene = gameScene {
                    SpriteView(scene: scene)
                        .ignoresSafeArea()
                } else {
                    Color.black
                        .onAppear {
                            setupScene(size: geometry.size)
                        }
                }
            }
            .ignoresSafeArea()

            if isPaused {
                PauseView(
                    onResume: {
                        isPaused = false
                        gameScene?.resumeGame()
                    },
                    onExit: {
                        dismiss()
                    }
                )
            }
        }
        .navigationBarBackButtonHidden()
    }

    private func setupScene(size: CGSize) {
        let scene = GameScene(size: size)
        scene.dismiss = dismiss
        scene.scaleMode = .resizeFill
        scene.onPause = {
            isPaused = true
        }
        self.gameScene = scene
    }
}

#Preview {
    GameView()
}
