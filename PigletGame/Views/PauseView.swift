import SwiftUI

struct PauseView: View {
    var onResume: () -> Void
    var onExit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("PAUSED")
                    .font(.custom(StyleGuide.Typography.heavy, size: 48))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2, x: 2, y: 2)

                VStack(spacing: 20) {
                    PigletButton(size: .large, text: "RESUME", icon: "play.fill", color: .yellow) {
                        onResume()
                    }

                    PigletButton(size: .large, text: "EXIT", icon: "arrow.left", color: .red) {
                        onExit()
                    }
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
            )
        }
    }
}

#Preview {
    PauseView(onResume: {}, onExit: {})
}
