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
    private let dismiss: DismissAction?

    @State var showGame: Bool = false
    @State var returnMenu: Bool = false
    
    // Animation states
    @State private var showBars = false
    @State private var showBackground = false
    @State private var showTitle = false
    @State private var showContent = false

    init(
        coins: Int,
        kills: Int,
        time: Int,
        dismiss: DismissAction? = nil
    ) {
        self.finalCoins = coins
        self.finalKills = kills
        self.finalTime = time
        self.dismiss = dismiss
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            backgroundLayer
            
            barsLayer
            
            menuContent
        }
        .onAppear {
            animateEntrance()
        }
    }
    
    private var backgroundLayer: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "A70202"),
                    Color(hex: "C50202"),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )

            StyleGuide.Colors.darkRed

            Image("Menu/Texture")
                .resizable()
                .opacity(0.7)
                .blendMode(.multiply)

            Image("Menu/Lines")
                .resizable()
                .blendMode(.multiply)
        }
        .opacity(showBackground ? 1.0 : 0.0)
        .ignoresSafeArea()
    }
    
    private var barsLayer: some View {
        VStack {
            Rectangle()
                .fill(StyleGuide.Colors.wine)
                .frame(maxWidth: .infinity, maxHeight: 80)
                .offset(y: showBars ? 0 : -200)
            
            Spacer()
            
            Rectangle()
                .fill(StyleGuide.Colors.wine)
                .frame(maxWidth: .infinity, maxHeight: 80)
                .offset(y: showBars ? 0 : 200)
        }
        .ignoresSafeArea()
    }
    
    private var menuContent: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .center) {

                Image("GameOver/youDied")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 295)
                    .offset(x: showTitle ? 0 : -500)
                    .opacity(showTitle ? 1 : 0)

                Spacer()

                VStack(alignment: .trailing, spacing: 16) {

                    HStack(spacing: 8) {
                        CardInfo(
                            icon: "GameOver/death",
                            value: ("x\(finalKills)")
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
                            if let dismiss = dismiss {
                                dismiss()
                            } else {
                                returnMenu = true
                            }
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
                .offset(x: showContent ? 0 : 500)
                .opacity(showContent ? 1 : 0)

            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationDestination(isPresented: $showGame) {
            GameView()
        }
        .navigationDestination(isPresented: $returnMenu) {
            MainMenu()
        }
    }
    
    private func animateEntrance() {
        // 1. Red bars move in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showBars = true
        }
        
        // 2. Background fades in
        withAnimation(.easeIn(duration: 0.4).delay(0.2)) {
            showBackground = true
        }
        
        // 3. 'You Died' moves from left
        withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.5)) {
            showTitle = true
        }
        
        // 4. Stats and buttons move from right
        withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.7)) {
            showContent = true
        }
    }
}

//#Preview {
//    GameOverView()
//}
