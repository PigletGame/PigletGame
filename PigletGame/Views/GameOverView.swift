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
    private let playAgainAction: (() -> Void)?

    @State private var displayedCoins: Int = 0
    @State private var didUseReward = false
    @State private var showRewardLabel = false

    @State private var hasSaved = false

    @State var returnMenu: Bool = false

    // Animation states
    @State private var showBars = false
    @State private var showBackground = false
    @State private var showTitle = false
    @State private var showContent = false
    @State private var animateCoins = false

    init(
        coins: Int,
        kills: Int,
        time: Int,
        dismiss: DismissAction? = nil,
        playAgainAction: (() -> Void)? = nil
    ) {
        self.finalCoins = coins
        self.finalKills = kills
        self.finalTime = time
        self.dismiss = dismiss
        self.playAgainAction = playAgainAction

        self._displayedCoins = State(initialValue: coins)
    }

    private func saveProgressIfNeeded() {
        guard !hasSaved else { return }
        hasSaved = true

        let coinsToSave = didUseReward ? displayedCoins : finalCoins

        GameDataStore.shared.recordRun(
            collectedCoins: coinsToSave,
            kills: finalKills
        )
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
            AdManager.shared.loadAd()
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
        ZStack {
            Rectangle()
                .fill(StyleGuide.Colors.wine)
                .frame(height: 105)
                .frame(maxHeight: .infinity, alignment: .top)
                .offset(y: showBars ? 0 : -200)

            Rectangle()
                .fill(StyleGuide.Colors.wine)
                .frame(height: 90)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .offset(y: showBars ? 0 : 200)
        }
        .ignoresSafeArea()
    }

    private var menuContent: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .center) {

                Image(String(localized: "ASSET_YOU_DIED"))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 295)
                    .offset(x: showTitle ? 0 : -500)
                    .opacity(showTitle ? 1 : 0)

                Spacer()

                VStack(alignment: .trailing, spacing: 16) {

                    HStack(spacing: 8) {
                        CardInfo(icon: "GameOver/death", value: ("x\(finalKills)"))

                        CardInfo(icon: "GameOver/coin", value: "x\(displayedCoins)")
                            .scaleEffect(animateCoins ? 1.2 : 1.0)
                            .animation(.spring(response: 0.4), value: animateCoins)

                        CardInfo(icon: "GameOver/clock", value: formatTime(finalTime))
                    }

                    if showRewardLabel {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 14, weight: .bold))

                            Text(String(localized: "x2 REWARD APPLIED"))
                                .font(.custom("Geist-Bold", size: 14))
                                .tracking(0.5)
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(StyleGuide.Colors.yellow)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.black, lineWidth: 2)
                        )
                        .transition(.scale.combined(with: .opacity))
                    }

                    Spacer()

                    HStack(spacing: 16) {
                        PigletButton(
                            size: .medium,
                            text: String(localized: "Back to Menu"),
                            icon: "arrowshape.turn.up.backward.fill"
                        ) {
                            saveProgressIfNeeded()
                            dismiss?()
                        }

                        PigletButton(
                            size: .medium,
                            text: String(localized: "Play Again"),
                            icon: "poweroutlet.type.a.fill",
                            color: .orange
                        ) {
                            saveProgressIfNeeded()
                            playAgainAction?()
                        }
                    }

                    PigletButton(
                        size: .extraLarge,
                        text: didUseReward ? String(localized: "Reward Used") : String(localized: "Double your Coins"),
                        icon: "play.rectangle.fill",
                        color: .yellow
                    ) {
                        guard !didUseReward else { return }

                        AdManager.shared.showAd {
                            withAnimation {
                                displayedCoins *= 2
                                didUseReward = true
                                showRewardLabel = true
                                animateCoins = true
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                AudioService.shared.play("coins.wav", volume: 0.45)
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                AudioService.shared.play("coins.wav", volume: 0.45)
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                animateCoins = false
                            }
                        }
                    }
                    .opacity(didUseReward ? 0.6 : 1.0)
                }
                .padding(.vertical, 120)
                .offset(x: showContent ? 0 : 500)
                .opacity(showContent ? 1 : 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func animateEntrance() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showBars = true
        }

        withAnimation(.easeIn(duration: 0.4).delay(0.2)) {
            showBackground = true
        }

        withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.5)) {
            showTitle = true
        }

        withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.7)) {
            showContent = true
        }
    }
}

#Preview{
    GameOverView(coins: 0, kills: 0, time: 0)
}
