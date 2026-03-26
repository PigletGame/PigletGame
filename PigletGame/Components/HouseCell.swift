//
//  HouseCell.swift
//  PigletGame
//
//  Created by Diogo Camargo on 26/03/26.
//

import Foundation
import SwiftUI

struct HouseCell: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black)
                .frame(width: 99, height: 79)
                .offset(x: 3, y: 6)

            RoundedRectangle(cornerRadius: 8)
                .fill(StyleGuide.Colors.darkRed)
                .frame(width: 94, height: 75)

            Image("house")
                .resizable()
                .scaledToFit()
                .padding(6)
                .foregroundColor(.white)

            RoundedRectangle(cornerRadius: 8)
                .stroke(StyleGuide.Colors.yellow, lineWidth: 3)
                .frame(width: 94, height: 75)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}


