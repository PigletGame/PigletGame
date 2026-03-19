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
    @State private var currentScene: SKScene?
    
    var initialSceneType: SKScene.Type = GameScene.self

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                if let scene = currentScene {
                    SpriteView(scene: scene)
                        .id(scene)
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
                        (currentScene as? GameScene)?.resumeGame()
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
        let scene: SKScene
        if initialSceneType == OnboardingScene.self {
            AudioService.shared.stop("menu.mp3")
            let onboarding = OnboardingScene(size: size)
            onboarding.dismiss = dismiss
            onboarding.onComplete = {
                UserDefaults.standard.set(true, forKey: OnboardingScene.seenKey)
                switchToGame(size: size)
            }
            scene = onboarding
        } else {
            scene = createGameScene(size: size)
        }
        scene.scaleMode = .resizeFill
        self.currentScene = scene
    }

    private func createGameScene(size: CGSize) -> GameScene {
        let game = GameScene(size: size)
        game.dismiss = dismiss
        game.onPause = {
            isPaused = true
        }
        return game
    }

    @MainActor
    private func switchToGame(size: CGSize) {
        AudioService.shared.play("bumbo.mp3")
            let game = createGameScene(size: size)
            game.scaleMode = .resizeFill
            self.currentScene = game
    }
}

#Preview {
    GameView()
}
