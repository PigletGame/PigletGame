//
//  MainMenu.swift
//  PigletGame
//
//  Created by Adriel de Souza on 18/03/26.
//

import SwiftUI

struct MainMenu: View {
    @State var showGame: Bool = false
    @State var showVillage: Bool = false

    var body: some View {
        VStack(alignment: .trailing) {
            HStack(spacing: 16) {
                PigletButton(size: .small, text: "", icon: "speaker.fill") {
                }

                PigletButton(size: .small, text: "", icon: "hand.tap.fill") {
                }
            }

            Spacer()

            HStack(alignment: .bottom) {
                Image("Menu/Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 385)

                Spacer()

                VStack(spacing: 16) {
                    PigletButton(size: .large, text: "Play", icon: "poweroutlet.type.a.fill", color: .yellow) {
                        showGame = true
                    }

                    HStack(spacing: 16) {
                        PigletButton(size: .medium, text: "Village", icon: "house.fill") {
                            showVillage = true
                        }

                        PigletButton(size: .medium, text: "Ranking", icon: "trophy.fill") {
                            GameCenterManager.shared.showLeaderboard()
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 64)
        .padding(.top, 24)
        .padding(.bottom, 100)
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("Menu/Lines")
                .resizable()
                .ignoresSafeArea()
                .blendMode(.multiply)

        )
        .background(
            Image("Menu/Texture")
                .resizable()
                .opacity(0.7)
                .blendMode(.multiply)
                .ignoresSafeArea()
        )
        .background(
            Gradient(colors: [
                Color(hex: "A70202"),
                Color(hex: "C50202")
            ])
        )
        .navigationDestination(isPresented: $showGame) {
            GameView()
        }
        .navigationDestination(isPresented: $showVillage) {
            VillageView()
        }
    }
}

#Preview {
    MainMenu()
}
