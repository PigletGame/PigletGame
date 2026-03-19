//
//  MainMenu.swift
//  PigletGame
//
//  Created by Adriel de Souza on 18/03/26.
//

import SwiftUI

struct MainMenu: View {
    @AppStorage(OnboardingScene.seenKey) var hasSeenOnboarding: Bool = false
    @State private var showOnboarding = false
    @State private var showMenu = false
    @State private var isHapticsEnabled = HapticsService.shared.isEnabled

    @State var showGame: Bool = false
    @State var showVillage: Bool = false

    var body: some View {
        menuContent
            .overlay(
                Color.black.ignoresSafeArea()
                    .allowsHitTesting(false)
                    .opacity(showMenu ? 0 : 1)
            )
            .navigationDestination(
                isPresented: $showOnboarding,
                destination: {
                    GameView(initialSceneType: OnboardingScene.self)
                }
            )
            .onAppear {
                if !hasSeenOnboarding {
                    showOnboarding = true
                }
                isHapticsEnabled = HapticsService.shared.isEnabled
                showMenu = true
                AudioService.shared.play("menu.mp3", loop: true, volume: 0.1)
            }
    }

    private var menuContent: some View {
        VStack(alignment: .trailing) {
            HStack(spacing: 16) {
                PigletButton(
                    size: .icon,
                    text: "",
                    icon: "speaker\(AudioService.shared.isAudioMuted ? ".slash" : "").fill",
                    color: AudioService.shared.isAudioMuted ? .disabledButton : .red
                ) {
                    AudioService.shared.toggleMute()
                }

                PigletButton(
                    size: .icon,
                    text: "",
                    icon: isHapticsEnabled ? "hand.tap.fill" : "hand.raised.slash.fill",
                    color: isHapticsEnabled ? .red : .disabledButton
                ) {
                    isHapticsEnabled.toggle()
                    HapticsService.shared.setEnabled(isHapticsEnabled)
                    if isHapticsEnabled {
                        HapticsService.shared.vibrate(with: .light)
                    }
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
                        PigletButton(size: .small, text: "Village", icon: "house.fill") {
                            showVillage = true
                        }

                        PigletButton(size: .small, text: "Ranking", icon: "trophy.fill") {
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
                Color(hex: "C50202"),
            ])
        )
        .navigationDestination(isPresented: $showGame) {
            GameView()
        }
        .navigationDestination(isPresented: $showVillage) {
            VillageHubView()
        }
    }
}

#Preview {
    MainMenu()
}
