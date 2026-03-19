//
//  VillageStatsBar.swift
//  PigletGame
//
//  Created by Diogo Camargo on 19/03/26.
//

import SwiftUI

struct VillageStatsBar: View {
    let coins: Int
    let houses: Int

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 13)
                .fill(StyleGuide.Colors.darkRedStatsBackground)

            HStack(spacing: 12) {
                VillageStatPill(
                    icon: "dollarsign.circle.fill",
                    iconColor: Color(hex: "F5A623"),
                    value: "x\(coins)"
                )
                VillageStatPill(
                    icon: "house.and.flag.fill",
                    iconColor: Color(hex: "F5A623"),
                    value: "x\(houses)"
                )
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 14)
        }
        .fixedSize()
    }
}

private struct VillageStatPill: View {
    let icon: String
    let iconColor: Color
    let value: String

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(iconColor)

            Text(value)
                .font(.custom("Geist-Black", size: 19))
                .foregroundColor(.white)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 23)
        .padding(.vertical, 10)
        .background(StyleGuide.Colors.darkRedStats)
        .cornerRadius(9)
    }
}

#Preview{
    VillageHubView()
}
