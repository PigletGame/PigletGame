//
//  ContentView.swift
//  PigletGame
//
//  Created by Adriel de Souza on 13/03/26.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            let scene: SKScene = {
//                let scene: SKScene = OnboardingScene.hasSeenOnboarding
//                    ? MenuScene()
//                    : OnboardingScene()
                let scene = OnboardingScene()
                scene.size = geometry.size
                scene.scaleMode = .aspectFill
                return scene
            }()

            SpriteView(scene: scene)
                .ignoresSafeArea()
        }
    }
}
#Preview {
    ContentView()
}
