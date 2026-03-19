//
//  GameOverView.swift
//  PigletGame
//
//  Created by júlia fazenda ruiz on 19/03/26.
//

import SwiftUI

struct GameOverView: View {

    private let finalCoins: Int
    private let finalKills: Int
    private let finalTime: Int

    @State var showGame: Bool = false
    @State var returnMenu: Bool = false

    init(
        coins: Int,
        kills: Int,
        time: Int,
        dismiss: DismissAction? = nil
    ) {
        self.finalCoins = coins
        self.finalKills = kills
        self.finalTime = time
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        menuContent
            .overlay(
                Color.black.ignoresSafeArea()
                    .allowsHitTesting(false)
            )
    }
    
    private var menuContent: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .center) {

                Image("GameOver/youDied")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 295)

                Spacer()

                VStack(alignment: .trailing, spacing: 16) {

                    HStack(spacing: 8) {
                        CardInfo(
                            icon: "GameOver/death",
                            value: ("x\(finalKills)"),
                        )
                        CardInfo(
                            icon: "GameOver/coin",
                            value: "x\(finalCoins)"
                        )
                        CardInfo(
                            icon: "GameOver/clock",
                            value: formatTime(finalTime)
                        )
                    }

                    Spacer()

                    HStack(spacing: 16) {
                        PigletButton(
                            size: .medium,
                            text: "Return to Menu",
                            icon: "arrowshape.turn.up.backward.fill"
                        ) {
                            returnMenu = true
                        }

                        PigletButton(
                            size: .medium,
                            text: "Play Again",
                            icon: "poweroutlet.type.a.fill",
                            color: .yellow
                        ) {
                            showGame = true
                        }
                    }
                }
                .padding(.vertical, 120)

            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "A70202"),
                        Color(hex: "C50202"),
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )

                StyleGuide.Colors.darkRedGameOver
                    .blendMode(.multiply)

                Image("Menu/Texture")
                    .resizable()
                    .opacity(0.7)
                    .blendMode(.multiply)

                Rectangle()
                    .fill(StyleGuide.Colors.darkRed)
                    .frame(maxWidth: .infinity, maxHeight: 240)
                    .ignoresSafeArea()

                Image("Menu/Lines")
                    .resizable()
                    .blendMode(.multiply)

            }
            .ignoresSafeArea()
        )

        .navigationDestination(isPresented: $showGame) {
            GameView()
        }
        .navigationDestination(isPresented: $returnMenu) {
            MainMenu()
        }
    }
}

//#Preview {
//    GameOverView()
//}
