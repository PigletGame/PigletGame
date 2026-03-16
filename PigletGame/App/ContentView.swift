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
        SKViewContainer()
            .ignoresSafeArea()
            .statusBarHidden()
    }
}

struct SKViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.ignoresSiblingOrder = true
        view.isMultipleTouchEnabled = true
        let scene = MenuScene()
        scene.scaleMode = .resizeFill
        view.presentScene(scene)
        return view
    }
    func updateUIView(_ uiView: SKView, context: Context) {}
}
