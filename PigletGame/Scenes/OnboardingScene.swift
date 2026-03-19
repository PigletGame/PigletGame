import SpriteKit
import SwiftUI

class OnboardingScene: SKScene {
    var dismiss: DismissAction?

    static let seenKey = "hasSeenOnboarding"
    let linesPerPage = 4

    private let storyLines: [String] = [
        "The pig village was calm. \nCheerful and peaceful, as it had always been.",
        "Pigs traded goods and shopped.",
        "Piglets ran through the streets and played in the mud.",
        "Amid laughter, the days went by.",
        "Until the peace vanished.",
        "They came from afar.",
        "Not as travelers, but as conquerors.",
        "Tigers.",
        "They wanted money. A lot of money.",
        "They needed to sustain their sordid lives.",
        "They were never satisfied. \nThey wanted more, more, and more.",
        "And when the coffers ran dry… the destruction began.",
        "Houses crumbled. Streets burned. The mud turned to ash.",
        "The tigers believed there was more hidden. Always more.",
        "And so, they took everything.",
        "The village fell.",
        "The pigs fled.",
        "All of them.",
        "All except you.",
        "As fear spread chaos, you remained.",
        "That place was everything you had and \neverything you were.",
        "Now, alone, the objective is clear:",
        "Drive out the usurpers and \nrestore your village to its former glory."
    ]

    private var pageTexts: [String] = []
    private var currentPageIndex = 0

    private var storyLabel: SKLabelNode?
    private var hintLabel: SKLabelNode?
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

        currentPageIndex = 0
        pageTexts = buildPages(from: storyLines, linesPerPage: linesPerPage)
        setupPageUI()
        updatePage(animated: false)
    }

    private func buildPages(from lines: [String], linesPerPage: Int) -> [String] {
        guard linesPerPage > 0 else { return [lines.joined(separator: "\n")] }
        var pages: [String] = []
        var index = 0

        while index < lines.count {
            let end = min(index + linesPerPage, lines.count)
            pages.append(lines[index..<end].joined(separator: "\n"))
            index = end
        }
        return pages
    }

    private func setupPageUI() {
        let text = SKLabelNode(fontNamed: StyleGuide.Typography.medium)
        text.numberOfLines = 0
        text.preferredMaxLayoutWidth = size.width * 0.84
        text.fontSize = max(22, min(28, size.height * 0.06))
        text.fontColor = .white
        text.horizontalAlignmentMode = .center
        text.verticalAlignmentMode = .center
        text.position = CGPoint(x: size.width / 2, y: size.height * 0.56)
        addChild(text)
        storyLabel = text

        let hint = SKLabelNode(fontNamed: StyleGuide.Typography.medium)
        hint.text = "tap to continue"
        hint.fontSize = max(15, min(20, size.height * 0.04))
        hint.fontColor = SKColor(white: 0.68, alpha: 1)
        hint.horizontalAlignmentMode = .center
        hint.verticalAlignmentMode = .center
        hint.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        addChild(hint)
        hintLabel = hint
    }

    private func updatePage(animated: Bool) {
        guard !pageTexts.isEmpty, currentPageIndex >= 0, currentPageIndex < pageTexts.count else { return }

        let changeText: () -> Void = { [weak self] in
            guard let self else { return }
            applyCenteredStoryText(pageTexts[currentPageIndex])
        }

        if animated, let storyLabel {
            let out = SKAction.fadeOut(withDuration: 0.15)
            let set = SKAction.run(changeText)
            let `in` = SKAction.fadeIn(withDuration: 0.15)
            storyLabel.run(SKAction.sequence([out, set, `in`]))
        } else {
            changeText()
        }

        let isLastPage = currentPageIndex == pageTexts.count - 1
        hintLabel?.isHidden = isLastPage

        if isLastPage {
            UserDefaults.standard.set(true, forKey: OnboardingScene.seenKey)
            showPlayButtonIfNeeded()
        } else {
            playButton?.removeFromParent()
            playButton = nil
        }
    }

    private func applyCenteredStoryText(_ text: String) {
        guard let storyLabel else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byWordWrapping

        let fontSize = storyLabel.fontSize
        let fontName = storyLabel.fontName ?? StyleGuide.Typography.medium
        let font = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)

        let attributed = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
        )

        storyLabel.attributedText = attributed
    }

    private func showPlayButtonIfNeeded() {
        guard playButton == nil else { return }

        let button = makePlayButton()
        button.alpha = 0
        button.position = CGPoint(x: size.width / 2, y: size.height / 4)
        addChild(button)
        playButton = button

        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        button.run(fadeIn)
    }

    private func makePlayButton() -> SKNode {
        let container = SKNode()
        container.name = "playButton"

        let bg = SKShapeNode(rectOf: CGSize(width: 220, height: 56), cornerRadius: 12)
        bg.fillColor = SKColor(red: 0.20, green: 0.62, blue: 0.28, alpha: 1)
        bg.strokeColor = .white
        bg.lineWidth = 2
        bg.name = "playButton"

        let label = SKLabelNode(fontNamed: StyleGuide.Typography.bold)
        label.text = "PLAY"
        label.fontSize = 24
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = "playButton"

        container.addChild(bg)
        container.addChild(label)
        return container
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        for node in nodes(at: location) where node.name == "playButton" {
            let scene = GameScene()
            scene.dismiss = self.dismiss
            AudioService.shared.play("bumbo.mp3")
            scene.scaleMode = .resizeFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
            AudioService.shared.play("bumbo.mp3")
            return
        }

        if currentPageIndex < pageTexts.count - 1 {
            currentPageIndex += 1
            updatePage(animated: true)
        }
    }
}
