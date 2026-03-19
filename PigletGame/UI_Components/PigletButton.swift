//
//  PigletButton.swift
//  PigletGame
//
//  Created by Adriel de Souza on 18/03/26.
//


import SwiftUI

struct PigletButton: View {
    enum ButtonSize {
        case small, medium, large, largeTwoLine, smallWide

        var width: Double {
            switch self {
                case .small: return 60
                case .medium: return 127
                case .large: return 270
                case .largeTwoLine: return 311
                case .smallWide: return 200
            }
        }

        var height: Double {
            switch self {
                case .small: return 44
                case .medium, .large: return 64
                case .largeTwoLine: return 0
                case .smallWide: return 40
            }
        }

        var fontSize: Double {
            switch self {
                case .small: return 0
                case .medium: return 17
                case .large, .largeTwoLine: return 24
                case .smallWide: return 17
            }
        }
    }

    enum ColorStyle {
        case red, yellow, disabledButton

        var background: Color {
            switch self {
            case .red:
                StyleGuide.Colors.darkRed
            case .yellow:
                StyleGuide.Colors.yellow
            case .disabledButton:
                StyleGuide.Colors.disabledButton
            }
        }

        var foreground: Color {
            switch self {
            case .red:
                Color.white
            case .yellow:
                Color.black
            case .disabledButton:
                Color.white
            }
        }
    }

    var size: ButtonSize = .large
    var text: String
    var icon: String
    var color: ColorStyle = .red
    var onTap: () -> Void
    var price: Int? = nil

    var body: some View {
        Button(action: onTap) {
            content
                .foregroundStyle(color.foreground)
                .frame(width: size.width, height: size == .largeTwoLine ? nil : size.height)
                .padding(.vertical, size == .largeTwoLine ? 11 : 0)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.background)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 3)
                )
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(size != .small ? Color.black : Color.clear)
                        .offset(x: 3, y: 3)
                )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var content: some View {
        if size == .large || size == .largeTwoLine {
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .black))
                    Text(text)
                        .font(.custom("Geist-Black", size: size.fontSize))
                }
                if let price {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text("\(price)")
                            .font(.system(size: 18, weight: .regular))
                    }
                }
            }
        } else if size == .smallWide {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .black))
                Text(text)
                    .font(.custom("Geist-Bold", size: size.fontSize))
            }
        } else {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .black))
                if size != .small {
                    Text(text)
                        .font(.custom("Geist-Bold", size: size.fontSize))
                }
            }
        }
    }
}

#Preview {
    PigletButton(size: .large, text: "Play", icon: "poweroutlet.type.a.fill", color: .yellow) {

    }
    PigletButton(
        size: .largeTwoLine,
        text: "Buy House",
        icon: "house.fill",
        color: .yellow,
        price: 200
    ) {
//        showPurchaseModal = true
    }
}
