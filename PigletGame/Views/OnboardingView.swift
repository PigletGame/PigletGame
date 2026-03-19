import SwiftUI
import SpriteKit

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { geometry in
            let scene: OnboardingScene = {
                let scene = OnboardingScene(size: geometry.size)
                scene.dismiss = dismiss
                scene.scaleMode = .resizeFill
                return scene
            }()

            SpriteView(scene: scene)
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
    }
}
