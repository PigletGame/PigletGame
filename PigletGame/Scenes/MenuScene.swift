import SpriteKit

class MenuScene: SKScene {

    private var lastLayoutSize: CGSize = .zero

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.06, green: 0.04, blue: 0.12, alpha: 1)
        layoutIfNeeded(force: true)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        layoutIfNeeded(force: false)
    }

    private func layoutIfNeeded(force: Bool) {
        guard size.width > 1, size.height > 1 else { return }
        guard force || lastLayoutSize != size else { return }

        removeAllChildren()
        setupBackground()
        setupTitle()
        setupButtons()
        lastLayoutSize = size
    }

    // MARK: – Background

    private func setupBackground() {
        // Starfield effect
        for _ in 0..<60 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.8...2))
            star.fillColor = .white
            star.strokeColor = .clear
            star.alpha = CGFloat.random(in: 0.3...0.9)
            star.position = CGPoint(x: CGFloat.random(in: 0...size.width),
                                    y: CGFloat.random(in: 0...size.height))
            star.zPosition = -1
            addChild(star)

            let blink = SKAction.sequence([
                SKAction.fadeAlpha(to: CGFloat.random(in: 0.1...0.4), duration: Double.random(in: 0.8...2.0)),
                SKAction.fadeAlpha(to: CGFloat.random(in: 0.6...1.0), duration: Double.random(in: 0.8...2.0))
            ])
            star.run(SKAction.repeatForever(blink))
        }
    }

    // MARK: – Title

    private func setupTitle() {
        let title = SKLabelNode(fontNamed: StyleGuide.Typography.heavy)
        title.text = "COINKS"
        title.fontSize = 70
        title.fontColor = SKColor(red: 1.0, green: 0.85, blue: 0.15, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.70)
        title.zPosition = 1
        addChild(title)

        // Subtle floating animation
        let up = SKAction.moveBy(x: 0, y: 6, duration: 1.2)
        let down = up.reversed()
        title.run(SKAction.repeatForever(SKAction.sequence([up, down])))

        let sub = SKLabelNode(fontNamed: StyleGuide.Typography.medium)
        sub.text = "Survivors"
        sub.fontSize = 26
        sub.fontColor = SKColor(white: 0.85, alpha: 1)
        sub.position = CGPoint(x: size.width / 2, y: size.height * 0.58)
        sub.zPosition = 1
        addChild(sub)
    }

    // MARK: – Buttons

    private func setupButtons() {
        addChild(makeButton(text: "⚔️  JOGAR",
                            name: "playButton",
                            color: SKColor(red: 0.85, green: 0.55, blue: 0.1, alpha: 1),
                            y: size.height * 0.38))

        addChild(makeButton(text: "🏡  VILA",
                            name: "villageButton",
                            color: SKColor(red: 0.2, green: 0.55, blue: 0.25, alpha: 1),
                            y: size.height * 0.24))
    }

    private func makeButton(text: String, name: String, color: SKColor, y: CGFloat) -> SKNode {
        let container = SKNode()
        container.name = name
        container.zPosition = 2

        let bg = SKShapeNode(rectOf: CGSize(width: 220, height: 54), cornerRadius: 12)
        bg.fillColor = color
        bg.strokeColor = SKColor(white: 1, alpha: 0.55)
        bg.lineWidth = 2
        bg.name = name

        let label = SKLabelNode(fontNamed: StyleGuide.Typography.bold)
        label.text = text
        label.fontSize = 22
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = name

        container.addChild(bg)
        container.addChild(label)
        container.position = CGPoint(x: size.width / 2, y: y)
        return container
    }

    // MARK: – Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        for node in nodes(at: location) {
            if node.name == "playButton" {
                presentGame()
                return
            }
            if node.name == "villageButton" {
                presentVillage()
                return
            }
        }
    }

    private func presentGame() {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
    }

    private func presentVillage() {
        let scene = VillageScene()
        scene.scaleMode = .resizeFill
        view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.5))
    }
}
