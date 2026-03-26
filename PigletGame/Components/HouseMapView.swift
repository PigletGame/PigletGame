//
//  HouseMapView.swift
//  PigletGame
//
//  Created by Diogo Camargo on 26/03/26.
//
import SpriteKit
import SwiftUI

struct HouseMapView: View {
    var size: CGFloat = 32
    @State private var float = false

    var body: some View {
        ZStack {
            // Sombra dinâmica
            Ellipse()
                .fill(Color.black.opacity(0.25))
                .frame(width: size * 0.9, height: size * 0.35)
                .blur(radius: 2)
                .scaleEffect(float ? 0.95 : 1.05)
                .offset(y: size * 0.35)

            // Casa com leve "idle animation"
            Image("house")
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .offset(y: float ? -4 : -2)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: float)
        }
        .onAppear {
            float = true
        }
    }
}
