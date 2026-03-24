//
//  RankUpOverlay.swift
//  PigletGame
//
//  Created by Adriel de Souza on 24/03/26.
//

import SwiftUI

struct RankUpOverlay: View {
    var rank: Int

    var body: some View {
        VStack(spacing: 16) {
            Image(rank >= 10 ? .HUD.rankUp3 : rank >= 5 ? .HUD.rankUp2 : .HUD.rankUp1)
                .resizable()
                .scaledToFit()
                .frame(width: 120)

            VStack(spacing: -16) {
                Text("RANK UP")
                    .font(Font.custom("Geist-Bold", size: 22))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)

                Text(rank.description)
                    .font(Font.custom("Geist-Bold", size: 82).weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        Gradient(colors: [
                            Color(hex: "FFD700"),
                            Color(hex: "FF9124"),
                        ])
                    )
            }
        }
        .padding(.horizontal, 6)
        .padding(.top, 32)
        .padding(.bottom, 8)
        .frame(width: 132)
        .background(
            PointedBanner()
        
                .foregroundStyle(rank >= 10 ? Color(hex: "570508") : Color(hex: "3F0303"))
                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                .overlay(
                    PointedBanner()
                        .stroke(Color(red: 0.98, green: 0.35, blue: 0), lineWidth: 6)
                )
                .overlay(
                    PointedBanner()
                        .stroke(.black.opacity(0.2), lineWidth: 6)
                )
        )
    }
}

#Preview {
    RankUpOverlay(rank: 10)
}
