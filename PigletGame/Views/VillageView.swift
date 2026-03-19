//
//  ContentView.swift
//  PigletGame
//
//  Created by Adriel de Souza on 13/03/26.
//

import SwiftUI
import SpriteKit

struct VillageView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            let scene: VillageScene = {
                let scene = VillageScene(size: geometry.size)
                
                scene.onBack = {
                    dismiss()
                }

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
    VillageView()
}
