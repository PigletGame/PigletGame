//
//  ContentView.swift
//  PigletGame
//
//  Created by Adriel de Souza on 13/03/26.
//

import SwiftUI

struct VillageView: View {
    @Environment(\.dismiss) private var dismiss

//    @State private var purchasedCount: Int = GameDataStore.shared.purchasedSlotsCount()
    private var purchasedCount: Int = 10

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)

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
                    Text("HOUSES")
                        .font(.custom("AvenirNext-Heavy", size: 34))
                        .foregroundColor(.black)
                        .padding(.top, -10)
                }
                .padding(.top, -50)

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(0..<purchasedCount, id: \.self) { _ in
                            HouseCell()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(
            Gradient(colors: [
                Color(hex: "A70202"),
                Color(hex: "C50202"),
            ])
        )
        .navigationBarHidden(true)
//        .task { purchasedCount = GameDataStore.shared.purchasedSlotsCount() }
    }
}

private struct HouseCell: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black)
                .frame(width: 99, height: 79)
                .offset(x: 3, y: 6)

            // Fundo
            RoundedRectangle(cornerRadius: 8)
                .fill(StyleGuide.Colors.darkRed)
                .frame(width: 94, height: 75)

            // Ícone central
            Image("house") // house.svg no Assets
                .resizable()
                .scaledToFit()
                .padding(6)
//                .frame(width: , height: 28)
                .foregroundColor(.white)

            // Borda amarela
            RoundedRectangle(cornerRadius: 8)
                .stroke(StyleGuide.Colors.yellow, lineWidth: 3)
                .frame(width: 94, height: 75)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

//#Preview {
//    VillageView()
//}
// 

#Preview {
    VillageView()
}
