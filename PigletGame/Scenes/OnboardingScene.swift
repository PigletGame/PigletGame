import SpriteKit
import SwiftUI

class OnboardingScene: SKScene {

    // MARK: - State

    private enum OnboardingState {
        case narrative
        case image
    }

    private var state: OnboardingState = .narrative

    var dismiss: DismissAction?
    var onComplete: (() -> Void)?

    static let seenKey = "hasSeenOnboarding"

    // MARK: - Private

    private var playButton: SKNode?

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        buildScene()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        if oldSize != size {
            buildScene()
        }
    }

    // MARK: - Scene Builder

    private func buildScene() {
        removeAllChildren()

        switch state {
        case .narrative:
            setupNarrativeScene()

        case .image:
            setupImageScene()
        }
    }

    // MARK: - Scene 1 (Narrative)

    private func setupNarrativeScene() {
        backgroundColor = SKColor(red: 0.65, green: 0.01, blue: 0.01, alpha: 1)

        let texts = [
            String(localized: "THE TIGERS DESTROYED YOUR VILLAGE"),
            String(localized: "THEY TOOK EVERYTHING"),
            String(localized: "TAKE IT BACK")
        ]

        let startY = size.height * 0.7
        let spacing: CGFloat = 60

        for (index, text) in texts.enumerated() {
            let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
            label.text = text
            label.fontSize = 32
            label.fontColor = .white
            label.alpha = 0

            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center

            label.position = CGPoint(
                x: size.width / 2,
                y: startY - CGFloat(index) * spacing
            )

            addChild(label)

            let delay = Double(index) * 1.2

            let moveIn = SKAction.moveBy(x: 0, y: -10, duration: 0.25)
            moveIn.timingMode = .easeOut

            let appear = SKAction.group([
                SKAction.fadeIn(withDuration: 0.2),
                moveIn
            ])

            label.run(.sequence([
                .wait(forDuration: delay),
                appear
            ]))
        }

        // Vai automaticamente pra próxima tela
        let totalDelay = Double(texts.count) * 1.2 + 1.0

        run(.sequence([
            .wait(forDuration: totalDelay),
            .run { [weak self] in
                self?.goToImageScene()
            }
        ]))
    }

    // MARK: - Scene 2 (Image + Play)

    private func setupImageScene() {
        backgroundColor = .black

        setupSingleSlide()
        setupPlayButton()
    }

    // MARK: - Transition

    private func goToImageScene() {
        state = .image

        let transition = SKTransition.fade(withDuration: 0.6)

        let newScene = OnboardingScene(size: size)
        newScene.scaleMode = scaleMode
        newScene.state = .image
        newScene.onComplete = onComplete

        view?.presentScene(newScene, transition: transition)
    }

    // MARK: - Image

    private func setupSingleSlide() {
        let sprite = SKSpriteNode(imageNamed: "onboarding")
        sprite.texture?.filteringMode = .linear

        if let textureSize = sprite.texture?.size(),
           textureSize.width > 0, textureSize.height > 0 {

            let scale = max(
                size.width / textureSize.width,
                size.height / textureSize.height
            )

            sprite.size = CGSize(
                width: textureSize.width * scale,
                height: textureSize.height / 2.2
            )
        } else {
            sprite.size = size
        }

        sprite.position = CGPoint(
            x: size.width / 2,
            y: size.height / 2
        )

        addChild(sprite)
    }

    // MARK: - Play Button

    private func setupPlayButton() {
        playButton?.removeFromParent()

        let buttonSize = CGSize(width: 270, height: 64)

        let button = makePlayButton()

        button.position = CGPoint(
            x: size.width - (buttonSize.width / 2) - 32,
            y: (buttonSize.height / 2) + 32
        )

        button.alpha = 0
        addChild(button)
        playButton = button

        let moveIn = SKAction.moveBy(x: -20, y: 0, duration: 0.2)
        moveIn.timingMode = .easeOut

        let appear = SKAction.group([
            SKAction.fadeIn(withDuration: 0.15),
            moveIn
        ])

        button.run(appear)
    }

    private func makePlayButton() -> SKNode {
        let container = SKNode()
        container.name = "playButton"

        let buttonSize = CGSize(width: 270, height: 64)
        let cornerRadius: CGFloat = 8

        let shadow = SKShapeNode(rectOf: buttonSize, cornerRadius: cornerRadius)
        shadow.fillColor = .black
        shadow.strokeColor = .clear
        shadow.position = CGPoint(x: 3, y: -3)
        shadow.name = "playButton"

        let bg = SKShapeNode(rectOf: buttonSize, cornerRadius: cornerRadius)
        bg.fillColor = SKColor(StyleGuide.Colors.yellow)
        bg.strokeColor = .black
        bg.lineWidth = 3
        bg.name = "playButton"

        let label = SKLabelNode(fontNamed: "Geist-Black")
        label.text = String(localized: "Play")
        label.fontSize = 24
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.name = "playButton"

        container.addChild(shadow)
        container.addChild(bg)
        container.addChild(label)

        return container
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        switch state {

        case .narrative:
            // Permite pular direto
            goToImageScene()

        case .image:
            if nodes(at: location).contains(where: { $0.name == "playButton" }) {
                AudioService.shared.play("bumbo.mp3")
                onComplete?()
            }
        }
    }
}



#Preview {
    // Forçamos a cena inicial a ser o Onboarding para ver no Canvas
    GameView(initialSceneType: OnboardingScene.self)
}
