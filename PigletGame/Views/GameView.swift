//
//  ContentView.swift
//  PigletGame
//
//  Created by Adriel de Souza on 13/03/26.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    private enum PostOnboardingStep {
        case none
        case move
        case shoot
    }

    @Environment(\.dismiss) var dismiss
    @State private var isPaused = false
    @State private var isGameOver = false
    @State private var finalStats: (coins: Int, kills: Int, time: Int)?
    @State private var currentScene: SKScene?
    @State private var postOnboardingStep: PostOnboardingStep = .none
    @State private var shouldRunPostOnboardingTips = false
    
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
            
            if isGameOver, let stats = finalStats {
                GameOverView(
                    coins: stats.coins,
                    kills: stats.kills,
                    time: stats.time,
                    dismiss: dismiss) {
                        if let currentScene {
                            setupScene(size: currentScene.size)
                        }
                    }
            }

            if postOnboardingStep != .none {
                postOnboardingOverlay
            }
        }
        .navigationBarBackButtonHidden()
    }

    private func setupScene(size: CGSize) {
        isGameOver = false
        isPaused = false
        finalStats = nil

        let scene: SKScene
        if initialSceneType == OnboardingScene.self {
            AudioService.shared.stop("menu.mp3")
            let onboarding = OnboardingScene(size: size)
            onboarding.dismiss = dismiss
            onboarding.onComplete = {
                shouldRunPostOnboardingTips = true
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
        game.onComplete = { coins, kills, time in
            self.finalStats = (coins, kills, time)
            self.isGameOver = true
        }
        return game
    }

    @MainActor
    private func switchToGame(size: CGSize) {
        AudioService.shared.play("bumbo.mp3")
        let game = createGameScene(size: size)
        game.scaleMode = .resizeFill

        if shouldRunPostOnboardingTips {
            postOnboardingStep = .move
            setGameplayPausedForTutorial(true)
            AudioService.shared.pause("inGameCombat.mp3")
        }

        self.currentScene = game
    }

    private var postOnboardingOverlay: some View {
        ZStack {
            Color.black
                .opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text(postOnboardingMessage)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .font(.custom("Geist-Black", size: 20))
                    .padding(.horizontal, 40)

                Text("Tap to continue")
                    .foregroundStyle(.white)
                    .font(.custom("Geist-Heavy", size: 18))
            }
            .padding(.horizontal, 24)
        }
        .contentShape(Rectangle())
        .onAppear {
            setGameplayPausedForTutorial(true)
        }
        .onTapGesture {
            handlePostOnboardingTap()
        }
    }

    private var postOnboardingMessage: String {
        switch postOnboardingStep {
        case .move:
            return "Drag anywhere on the left side to move the character"
        case .shoot:
            return "Drag anywhere on the right side to shoot"
        case .none:
            return ""
        }
    }

    private func handlePostOnboardingTap() {
        switch postOnboardingStep {
        case .move:
            setPostOnboardingStep(.none)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if shouldRunPostOnboardingTips {
                    setPostOnboardingStep(.shoot)
                }
            }
        case .shoot:
            setPostOnboardingStep(.none)
            shouldRunPostOnboardingTips = false
            UserDefaults.standard.set(true, forKey: OnboardingScene.seenKey)
        case .none:
            break
        }
    }

    private func setPostOnboardingStep(_ step: PostOnboardingStep) {
        postOnboardingStep = step
        setGameplayPausedForTutorial(step != .none)
    }

    private func setGameplayPausedForTutorial(_ shouldPause: Bool) {
        guard let gameScene = currentScene as? GameScene else {
            if shouldPause {
                DispatchQueue.main.async {
                    setGameplayPausedForTutorial(true)
                }
            }
            return
        }

        gameScene.isPaused = shouldPause

        if shouldPause {
            AudioService.shared.pause("inGameCombat.mp3")
        } else if !isPaused && !isGameOver {
            AudioService.shared.resume("inGameCombat.mp3")
        }
    }

    private func restartGame() {
        guard let sceneSize = currentScene?.size else { return }

        isGameOver = false
        finalStats = nil
        isPaused = false

        let game = createGameScene(size: sceneSize)
        game.scaleMode = .resizeFill
        currentScene = game
    }
}

#Preview {
    GameView()
}
