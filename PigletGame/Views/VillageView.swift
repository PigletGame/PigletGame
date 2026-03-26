//
//  ContentView.swift
//  PigletGame
//
//  Created by Adriel de Souza on 13/03/26.
//

import SwiftUI

struct VillageView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var purchasedCount: Int = GameDataStore.shared.purchasedSlotsCount()

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

                if purchasedCount == 0 {
                    EmptyVillageView()
                } else {
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
        }
        .background(
            Gradient(colors: [
                Color(hex: "A70202"),
                Color(hex: "C50202"),
            ])
        )
        .navigationBarHidden(true)
        .task { purchasedCount = GameDataStore.shared.purchasedSlotsCount() }
    }
}

// MARK: - Empty State
private struct EmptyVillageView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image("house")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .opacity(0.35)
                .scaleEffect(isAnimating ? 1.05 : 0.95)
                .animation(
                    .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                    value: isAnimating
                )

            Text("No houses yet")
                .font(.custom("AvenirNext-Heavy", size: 18))
                .foregroundColor(.white.opacity(0.9))

            Text("Kill the tigers, earn coins\nand buy your houses")
                .font(.custom("AvenirNext-Medium", size: 13))
                .foregroundColor(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onAppear { isAnimating = true }
    }
}

//private struct HouseCell: View {
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 8)
//                .fill(Color.black)
//                .frame(width: 99, height: 79)
//                .offset(x: 3, y: 6)
//
//            RoundedRectangle(cornerRadius: 8)
//                .fill(StyleGuide.Colors.darkRed)
//                .frame(width: 94, height: 75)
//
//            Image("house")
//                .resizable()
//                .scaledToFit()
//                .padding(6)
//                .foregroundColor(.white)
//
//            RoundedRectangle(cornerRadius: 8)
//                .stroke(StyleGuide.Colors.yellow, lineWidth: 3)
//                .frame(width: 94, height: 75)
//        }
//        .aspectRatio(1, contentMode: .fit)
//    }
//}}

#Preview {
    VillageView()
}
