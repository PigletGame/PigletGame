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
        ZStack {

            VStack(spacing: 0) {
                Text(String(localized: "RANK UP"))
                    .font(Font.custom("Geist-Bold", size: 16))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(rank.description)
                    .font(Font.custom("Geist-Bold", size: 56))
                    .foregroundStyle(
                        Gradient(colors: [
                            Color(hex: "FFD700"),
                            Color(hex: "FF9124"),
                        ])
                    )
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 36)
            .padding(.bottom, 36)
            .frame(width: 110)
            .background(
                PointedBanner()
                    .foregroundStyle(rank >= 10 ? Color(hex: "570508") : Color(hex: "3F0303"))
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                    .overlay(
                        PointedBanner()
                            .stroke(Color(red: 0.98, green: 0.35, blue: 0), lineWidth: 4)
                    )
                    .overlay(
                        PointedBanner()
                            .stroke(.black.opacity(0.2), lineWidth: 4)
                    )
            )

            Image(rank >= 10 ? .HUD.rankUp3 : rank >= 5 ? .HUD.rankUp2 : .HUD.rankUp1)
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .offset(y: -90)
        }
    }
}

#Preview {
    RankUpOverlay(rank: 10)
}
