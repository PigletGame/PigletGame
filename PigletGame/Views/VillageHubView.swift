//
//  VillageHubView.swift
//  PigletGame
//
//  Created by Diogo Camargo on 19/03/26.
//

import SwiftUI

struct VillageHubView: View {

    @State private var progress = GameDataStore.shared.progressSnapshot()
    @State private var purchasedCount: Int = GameDataStore.shared.purchasedSlotsCount()

    @State var showVillage = false
    @State var showPurchaseModal = false

    @State private var alertMessage: String? = nil

//    @State var nextCost: Int = 0

    // ADICIONA propriedade computada:
    private var nextCost: Int {
        GameDataStore.shared.slotCost(for: purchasedCount)
    }

    private var purchaseModal: some View {
        VStack(spacing: 24) {

            Text("🏡 Comprar Casa")
                .font(.title)
                .bold()

            Text("Custo: \(nextCost) moedas")
                .font(.title2)

            Button("Confirmar Compra") {
                confirmPurchase()
            }
            .padding()
            .frame(width: 220)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(12)

            Button("Cancelar") {
                showPurchaseModal = false
            }
            .foregroundColor(.red)

            if let msg = alertMessage {
                Text(msg)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

        }
        .padding()
    }

    private func confirmPurchase() {
        let result = GameDataStore.shared.purchaseSlot(index: purchasedCount)
        switch result {
        case .purchased:
            reload()
            showPurchaseModal = false
        case .insufficientFunds(let required, let current):
            alertMessage = "Faltam \(required - current) 🪙 para comprar esta casa."
        case .alreadyOwned:
            alertMessage = "Esta casa já foi comprada."
        case .unavailable:
            alertMessage = "Não foi possível comprar agora."
        }
    }

    var body: some View {
        VStack(spacing: 32) {

            Spacer()

            Text("🏡 Sua Vila")
                .font(.largeTitle)
                .bold()

            VStack(spacing: 16) {

                Text("🪙 Moedas: \(progress.totalCoins)")
                    .font(.title2)

                Text("🏡 Casas: \(purchasedCount)")
                    .font(.title2)

            }

            Button {
//                nextCost = GameDataStore.shared.slotCost(for: purchasedCount)
                showPurchaseModal = true
            } label: {
                Text("Comprar Casa")
                    .font(.headline)
                    .padding()
                    .frame(width: 220)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            Button(action: {
                showVillage = true
            }) {
                Text("Ver Vila")
                    .font(.headline)
                    .padding()
                    .frame(width: 220)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .task {
            reload()
        }
        .navigationDestination(isPresented: $showVillage) {
            VillageView()
        }
        .sheet(isPresented: $showPurchaseModal) {
            purchaseModal
        }
    }

    // MARK: - Logic

    private func reload() {
        progress = GameDataStore.shared.progressSnapshot()
        purchasedCount = GameDataStore.shared.purchasedSlotsCount()
    }

    private func buyNextHouse() {
        let nextIndex = purchasedCount

        let result = GameDataStore.shared.purchaseSlot(index: nextIndex)

        switch result {
        case .purchased:
            reload()

        case .insufficientFunds:
            print("Sem moedas")

        case .alreadyOwned:
            print("Já tem")

        case .unavailable:
            print("Indisponível")
        }
    }
}

