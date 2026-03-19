//
//  VillageHubView.swift
//  PigletGame
//
//  Created by Diogo Camargo on 19/03/26.
//

import SwiftUI

struct VillageHubView: View {

    @Environment(\.dismiss) var dismiss

    @State private var progress = GameDataStore.shared.progressSnapshot()
    @State private var purchasedCount: Int = GameDataStore.shared.purchasedSlotsCount()
    @State private var showVillage = false

    private var nextCost: Int {
        GameDataStore.shared.slotCost(for: purchasedCount)
    }

    private var canAfford: Bool {
        progress.totalCoins >= nextCost
    }

    var body: some View {
        ZStack {
            Image("Menu/Texture")
                .resizable()
                .opacity(0.7)
                .blendMode(.multiply)
                .ignoresSafeArea()

            Image("Menu/Lines")
                .resizable()
                .blendMode(.multiply)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    PigletButton(size: .icon, text: "", icon: "xmark") {
                        dismiss()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)

                VStack(spacing: 0) {
                    Text("THE")
                        .font(.custom("AvenirNext-Heavy", size: 14))
                        .foregroundColor(.white)

                    Text("VILLAGE")
                        .font(.custom("AvenirNext-Heavy", size: 34))
                        .foregroundColor(.black)
                        .padding(.top, -10)
                }
                .padding(.top, -50)

                VillageStatsBar(coins: progress.totalCoins, houses: purchasedCount)
                    .padding(.horizontal, 32)

                Spacer()

                VStack(spacing: 16) {
                    PigletButton(
                        size: .largeTwoLine,
                        text: "Buy House",
                        icon: "house.fill",
                        color: canAfford ? .yellow : .red,
                        price: nextCost) {
                            buyNextHouse()
                        }
                    
                    .disabled(!canAfford)
                    .opacity(canAfford ? 1 : 0.5)

                    PigletButton(size: .smallWide, text: "See the Village", icon: "house.lodge.fill") {
                        showVillage = true
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 27)
            }
        }
        .background(
            Gradient(colors: [
                Color(hex: "A70202"),
                Color(hex: "C50202"),
            ])
        )
        .navigationBarHidden(true)
        .task { reload() }
        .navigationDestination(isPresented: $showVillage) {
            VillageView()
        }
    }

    private func reload() {
        progress = GameDataStore.shared.progressSnapshot()
        purchasedCount = GameDataStore.shared.purchasedSlotsCount()
    }

    private func buyNextHouse() {
        let result = GameDataStore.shared.purchaseSlot(index: purchasedCount)
        if case .purchased = result {
            reload()
        }
    }
}

#Preview {
    VillageHubView()
}
#Preview {
    VillageHubView()
}
