//
//  CardInfo.swift
//  PigletGame
//
//  Created by júlia fazenda ruiz on 19/03/26.
//

import SwiftUI

struct CardInfo: View {
    
    var icon: String = "GameOver/coin"
    var value: String = "x"
    
    var body: some View {

        VStack {
            Image(icon)
                .resizable()
                .frame(width: 26, height: 26)

            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(StyleGuide.Colors.wine)
        )
    }
}

#Preview {
    CardInfo()
}
