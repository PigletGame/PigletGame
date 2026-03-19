//
//  PigletButton.swift
//  PigletGame
//
//  Created by Adriel de Souza on 18/03/26.
//


import SwiftUI

struct PigletButton: View {
    enum ButtonSize {
        case icon, small, medium, large

        var width: Double {
            switch self {
            case .icon: return 60
            case .small: return 127
            case .medium: return 157
            case .large: return 270
            }
        }

        var height: Double {
            self == .icon ? 44 : 64
        }

        var fontSize: Double {
            switch self {
            case .icon: return 0
            case .small: return 17
            case .medium: return 17
            case .large: return 24
            }
        }
    }

    enum ColorStyle {
        case red, yellow

        var background: Color {
            switch self {
            case .red:
                StyleGuide.Colors.darkRed
            case .yellow:
                StyleGuide.Colors.yellow
            }
        }

        var foreground: Color {
            switch self {
            case .red:
                Color.white
            case .yellow:
                Color.black
            }
        }
    }

    var size: ButtonSize = .large
    var text: String
    var icon: String
    var color: ColorStyle = .red
    var onTap: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            AudioService.shared.play("botao2.m4a", volume: 0.18)
            onTap()
        }) {
            content
                .foregroundStyle(color.foreground)
                .frame(width: size.width, height: size.height)
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
                        .fill(size != .icon ? Color.black : Color.clear)
                        .offset(x: 3, y: 3)
                )
        }
        .buttonStyle(PressableStyle(isPressed: $isPressed))
    }

    @ViewBuilder
    private var content: some View {
        if size == .large {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .black))

                Text(text)
                    .font(.custom("Geist-Black", size: size.fontSize))
            }
        } else {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .black))

                if size != .icon {
                    Text(text)
                        .font(.custom("Geist-Bold", size: size.fontSize))
                }
            }
        }
    }
    
    struct PressableStyle: ButtonStyle {
        @Binding var isPressed: Bool
        
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .onChange(of: configuration.isPressed) { _, newValue in
                    isPressed = newValue
                }
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        PigletButton(
            size: .medium,
            text: "Return to Menu",
            icon: "arrowshape.turn.up.backward.fill"
        ) {
            // showVillage = true
        }

        PigletButton(
            size: .medium,
            text: "Play Again",
            icon: "poweroutlet.type.a.fill",
            color: .yellow
        ) {
            // showGame = true
        }
    }
}
