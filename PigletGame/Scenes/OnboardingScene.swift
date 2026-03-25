import SpriteKit
import SwiftUI

class OnboardingScene: SKScene {
    var dismiss: DismissAction?
    var onComplete: (() -> Void)?

    static let seenKey = "hasSeenOnboarding"

    private let comicNames = (1...8).map { "comic\($0)" }
    private var currentIndex = 0
    private let carouselNode = SKNode()

    private var dragTouch: UITouch?
    private var dragStartLocation: CGPoint = .zero
    private var dragStartCarouselX: CGFloat = 0
    private var isDragging = false

    private var swipeHintBox: SKNode?
    private var playButton: SKNode?

    override func didMove(to view: SKView) {
        buildScene()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        if oldSize != size {
            buildScene()
        }
    }

    private func buildScene() {
        removeAllChildren()
        backgroundColor = .black

        currentIndex = 0
        addChild(carouselNode)
        setupCarouselSlides()
        setupSwipeHintBox()
        setupPlayButton()
        updateUIForCurrentIndex(animated: false)
    }

    private func setupSwipeHintBox() {
        swipeHintBox?.removeFromParent()

        let box = SKNode()
        box.position = CGPoint(x: size.width / 2, y: size.height / 2)
        box.zPosition = 100

        let boxSize = CGSize(width: 250, height: 58)
        let background = SKShapeNode(rectOf: boxSize, cornerRadius: 12)
        background.fillColor = UIColor(StyleGuide.Colors.darkRed)
        background.strokeColor = .black
        background.lineWidth = 2

        let label = SKLabelNode(fontNamed: "Geist-Black")
        label.text = "Swipe to continue"
        label.fontSize = max(14, min(18, size.height * 0.03))
        label.fontColor = .white
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center

        box.addChild(background)
        box.addChild(label)
        addChild(box)
        swipeHintBox = box

        box.removeAllActions()
        box.run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.fadeOut(withDuration: 0.2),
            SKAction.removeFromParent()
        ]))
    }

    private func setupCarouselSlides() {
        carouselNode.removeAllChildren()

        for (index, imageName) in comicNames.enumerated() {
            let slide = makeSlide(imageNamed: imageName)
            slide.position = CGPoint(
                x: size.width * 0.5 + CGFloat(index) * size.width,
                y: size.height * 0.5
            )
            carouselNode.addChild(slide)
        }
    }

    private func makeSlide(imageNamed imageName: String) -> SKNode {
        let slidePadding: CGFloat = 8
        let contentSize = CGSize(width: size.width - (slidePadding * 2),
                                 height: size.height - (slidePadding * 2))

        let sprite = SKSpriteNode(imageNamed: imageName)
        sprite.texture?.filteringMode = .linear

        if let textureSize = sprite.texture?.size(), textureSize.width > 0, textureSize.height > 0 {
            let fitScale = min(contentSize.width / textureSize.width,
                               contentSize.height / textureSize.height)
            sprite.size = CGSize(width: textureSize.width * fitScale,
                                 height: textureSize.height * fitScale)
        } else {
            sprite.size = contentSize
        }

        let mask = SKShapeNode(rectOf: contentSize)
        mask.fillColor = .white
        mask.strokeColor = .clear

        let cropNode = SKCropNode()
        cropNode.maskNode = mask
        cropNode.addChild(sprite)

        return cropNode
    }

    private func setupPlayButton() {
        playButton?.removeFromParent()

        let buttonSize = CGSize(width: 270, height: 64)
        let rightMargin: CGFloat = 24
        let bottomMargin: CGFloat = 24

        let button = makePlayButton()
        button.alpha = 0
        button.position = CGPoint(
            x: size.width - (buttonSize.width / 2) - rightMargin,
            y: (buttonSize.height / 2) + bottomMargin
        )
        addChild(button)
        playButton = button
    }

    private func updateUIForCurrentIndex(animated: Bool) {
        let targetX = -CGFloat(currentIndex) * size.width
        carouselNode.removeAllActions()

        if animated {
            let move = SKAction.moveTo(x: targetX, duration: 0.22)
            move.timingMode = .easeOut
            carouselNode.run(move)
        } else {
            carouselNode.position.x = targetX
        }

        let isLastSlide = currentIndex == comicNames.count - 1

        guard let playButton else { return }
        playButton.removeAllActions()
        if isLastSlide {
            playButton.run(.fadeAlpha(to: 1, duration: 0.2))
        } else {
            playButton.run(.fadeAlpha(to: 0, duration: 0.2))
        }
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
        label.text = "Play"
        label.fontSize = 24
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: 0)
        label.name = "playButton"

        container.addChild(shadow)
        container.addChild(bg)
        container.addChild(label)
        return container
    }

    private func nearestIndex(for xPosition: CGFloat) -> Int {
        let rawIndex = Int(round(-xPosition / size.width))
        return max(0, min(comicNames.count - 1, rawIndex))
    }

    private func clampedCarouselX(_ xPosition: CGFloat) -> CGFloat {
        let minX = -CGFloat(comicNames.count - 1) * size.width
        let maxX: CGFloat = 0

        if xPosition > maxX {
            return maxX + (xPosition - maxX) * 0.25
        }

        if xPosition < minX {
            return minX + (xPosition - minX) * 0.25
        }

        return xPosition
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        hideSwipeHintBox()

        if currentIndex == comicNames.count - 1,
           nodes(at: location).contains(where: { $0.name == "playButton" }) {
            AudioService.shared.play("bumbo.mp3")
            onComplete?()
            return
        }

        dragTouch = touch
        dragStartLocation = location
        dragStartCarouselX = carouselNode.position.x
        isDragging = false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = dragTouch, touches.contains(touch) else { return }

        hideSwipeHintBox()

        let location = touch.location(in: self)
        let deltaX = location.x - dragStartLocation.x
        if abs(deltaX) > 3 { isDragging = true }

        carouselNode.removeAllActions()
        carouselNode.position.x = clampedCarouselX(dragStartCarouselX + deltaX)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = dragTouch, touches.contains(touch) else { return }

        let location = touch.location(in: self)
        let deltaX = location.x - dragStartLocation.x

        if abs(deltaX) > size.width * 0.12 {
            if deltaX < 0 {
                currentIndex = min(currentIndex + 1, comicNames.count - 1)
            } else {
                currentIndex = max(currentIndex - 1, 0)
            }
        } else {
            currentIndex = nearestIndex(for: carouselNode.position.x)
        }

        updateUIForCurrentIndex(animated: true)

        dragTouch = nil
        isDragging = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = dragTouch, touches.contains(touch) else { return }
        updateUIForCurrentIndex(animated: true)
        dragTouch = nil
        isDragging = false
    }

    private func hideSwipeHintBox() {
        guard let swipeHintBox else { return }
        self.swipeHintBox = nil

        swipeHintBox.removeAllActions()
        swipeHintBox.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.15),
            SKAction.removeFromParent()
        ]))
    }
}
