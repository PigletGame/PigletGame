import SpriteKit

class GameOverScene: SKScene {

    private let finalScore: Int
    private let finalKills: Int
    private let finalTime: Int

    init(score: Int, kills: Int, time: Int) {
        self.finalScore = score
        self.finalKills = kills
        self.finalTime  = time
        super.init(size: .zero)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.05, green: 0.03, blue: 0.10, alpha: 1)
        setupBackground()
        setupPanel()
    }

    // MARK: – Background

    private func setupBackground() {
        for _ in 0..<40 {
            let p = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.6...1.8))
            p.fillColor   = .white
            p.strokeColor = .clear
            p.alpha       = CGFloat.random(in: 0.2...0.7)
            p.position    = CGPoint(x: CGFloat.random(in: 0...size.width),
                                    y: CGFloat.random(in: 0...size.height))
            p.zPosition   = -1
            addChild(p)
        }
    }

    // MARK: – Panel

    private func setupPanel() {
        let cx = size.width / 2
        var y  = size.height * 0.85

        // Title
        let titleLbl = makeLabel("💀 FIM DE JOGO", font: "AvenirNext-Heavy", size: 38,
                                  color: SKColor(red: 0.95, green: 0.25, blue: 0.15, alpha: 1))
        titleLbl.position = CGPoint(x: cx, y: y)
        addChild(titleLbl)
        let nudge = SKAction.sequence([SKAction.moveBy(x: 0, y: 5, duration: 0.9),
                                        SKAction.moveBy(x: 0, y: -5, duration: 0.9)])
        titleLbl.run(SKAction.repeatForever(nudge))

        y -= 55

        // Stats panel background
        let panelH: CGFloat = 120
        let panel = SKShapeNode(rectOf: CGSize(width: 340, height: panelH), cornerRadius: 14)
        panel.fillColor   = SKColor(white: 1, alpha: 0.07)
        panel.strokeColor = SKColor(white: 1, alpha: 0.25)
        panel.lineWidth   = 1.5
        panel.position    = CGPoint(x: cx, y: y - panelH / 2 + 10)
        panel.zPosition   = 1
        addChild(panel)

        let timeStr = formatTime(finalTime)
        let stats: [(String, String)] = [
            ("⭐ Pontuação", "\(finalScore)"),
            ("☠ Eliminações", "\(finalKills)"),
            ("⏱ Tempo", timeStr)
        ]

        let rowSpacing: CGFloat = 32
        let startY = y - 4
        for (i, (label, value)) in stats.enumerated() {
            let row = CGPoint(x: cx, y: startY - CGFloat(i) * rowSpacing)

            let lbl = makeLabel(label, font: "AvenirNext-Medium", size: 15,
                                 color: SKColor(white: 0.75, alpha: 1))
            lbl.horizontalAlignmentMode = .right
            lbl.position = CGPoint(x: cx - 10, y: row.y)
            lbl.zPosition = 2
            addChild(lbl)

            let val = makeLabel(value, font: "AvenirNext-Bold", size: 15,
                                 color: .white)
            val.horizontalAlignmentMode = .left
            val.position = CGPoint(x: cx + 10, y: row.y)
            val.zPosition = 2
            addChild(val)
        }

        y -= panelH + 18

        // Buttons
        let playAgain = makeButton(text: "🔄  Jogar Novamente",
                                   name: "playAgain",
                                   color: SKColor(red: 0.82, green: 0.52, blue: 0.08, alpha: 1))
        playAgain.position = CGPoint(x: cx, y: y - 20)
        addChild(playAgain)

        let menu = makeButton(text: "🏠  Menu Principal",
                              name: "menu",
                              color: SKColor(red: 0.18, green: 0.35, blue: 0.65, alpha: 1))
        menu.position = CGPoint(x: cx, y: y - 80)
        addChild(menu)
    }

    private func makeLabel(_ text: String, font: String, size: CGFloat, color: SKColor) -> SKLabelNode {
        let lbl = SKLabelNode(fontNamed: font)
        lbl.text = text
        lbl.fontSize = size
        lbl.fontColor = color
        lbl.horizontalAlignmentMode = .center
        lbl.verticalAlignmentMode   = .center
        return lbl
    }

    private func makeButton(text: String, name: String, color: SKColor) -> SKNode {
        let container = SKNode()
        container.name = name
        container.zPosition = 5

        let bg = SKShapeNode(rectOf: CGSize(width: 270, height: 50), cornerRadius: 12)
        bg.fillColor   = color
        bg.strokeColor = SKColor(white: 1, alpha: 0.5)
        bg.lineWidth   = 1.5
        bg.name        = name

        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.text  = text
        lbl.fontSize  = 20
        lbl.fontColor = .white
        lbl.verticalAlignmentMode = .center
        lbl.name  = name

        container.addChild(bg)
        container.addChild(lbl)
        return container
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }

    // MARK: – Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        for node in nodes(at: loc) {
            if node.name == "playAgain" {
                let scene = GameScene()
                scene.scaleMode = .resizeFill
                view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.45))
                return
            }
            if node.name == "menu" {
                let scene = MenuScene()
                scene.scaleMode = .resizeFill
                view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.45))
                return
            }
        }
    }
}
