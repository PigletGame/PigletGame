import SwiftUI

struct PauseView: View {
    var onResume: () -> Void
    var onExit: () -> Void

    @State private var isVisible = false

    var body: some View {
        ZStack {
            // Background
            StyleGuide.Colors.gray.opacity(0.9)
                .blendMode(.multiply)
                .opacity(isVisible ? 0.3 : 0.0)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                // Top Menu (Paused Image)
                Rectangle()
                    .foregroundStyle(StyleGuide.Colors.wine)
                    .frame(height: 95)
                    .overlay {
                        Image(.Menu.paused)
                            .frame(height: 90)
                            .offset(y: 45)
                    }
                    .offset(y: isVisible ? 0 : -200)

                Spacer()

                // Bottom Menu (Buttons)
                Rectangle()
                    .foregroundStyle(StyleGuide.Colors.wine)
                    .frame(height: 95)
                    .overlay(alignment: .top) {
                        HStack {
                            PigletButton(size: .medium, text: "Exit", icon: "rectangle.portrait.and.arrow.right") {
                                AudioService.shared.stop("inGameCombat.mp3")
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                                    isVisible = false
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    onExit()
                                }
                            }

                            PigletButton(size: .medium, text: "Resume", icon: "poweroutlet.type.a.fill", color: .yellow) {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                                    isVisible = false
                                }

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    onResume()
                                }
                            }
                        }
                        .offset(y: -16)
                    }
                    .offset(y: isVisible ? 0 : 200)
            }
            .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                isVisible = true
            }
        }
    }
}

#Preview {
    PauseView(onResume: {}, onExit: {})
}
