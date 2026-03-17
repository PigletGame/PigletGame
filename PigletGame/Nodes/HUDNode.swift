import SpriteKit

class HUDNode: SKNode {

    private var killLabel:  SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var coinLabel:  SKLabelNode!
    private var heartNodes: [SKShapeNode] = []

    private let sceneSize: CGSize

    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        super.init()
        zPosition = 90
        buildStrip()
        buildLabels()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: – Build

    private func buildStrip() {
        let strip = SKShapeNode(rectOf: CGSize(width: sceneSize.width, height: 38))
        strip.fillColor   = SKColor(white: 0, alpha: 0.55)
        strip.strokeColor = .clear
        strip.position    = CGPoint(x: 0, y: sceneSize.height / 2 - 18)
        strip.zPosition   = 90
        addChild(strip)
    }

    private func buildLabels() {
        killLabel = makeLabel(align: .left)
        killLabel.position = CGPoint(
            x: -sceneSize.width / 2 + 16,
            y: sceneSize.height / 2 - 28
        )
        addChild(killLabel)

        scoreLabel = makeLabel(align: .right)
        scoreLabel.position = CGPoint(
            x: sceneSize.width / 2 - 16,
            y: sceneSize.height / 2 - 28
        )
        addChild(scoreLabel)

        // 💰 Label central
        coinLabel = makeLabel(align: .center)
        coinLabel.position = CGPoint(
            x: 0,
            y: sceneSize.height / 2 - 28
        )
        addChild(coinLabel)
    }

    private func makeLabel(align: SKLabelHorizontalAlignmentMode) -> SKLabelNode {
        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.fontSize  = 15
        lbl.fontColor = .white
        lbl.horizontalAlignmentMode = align
        lbl.verticalAlignmentMode   = .center
        lbl.zPosition = 95
        return lbl
    }

    // MARK: – Update

    func update(score: Int, kills: Int, lives: Int, hasShield: Bool, coins: Int) {
        killLabel.text  = "☠ \(kills)"
        scoreLabel.text = "⭐ \(score)"
        coinLabel.text  = "💰 \(coins)" // ✅ moedas

        rebuildHearts(lives: lives, hasShield: hasShield)
    }

    // MARK: – Hearts

    private func rebuildHearts(lives: Int, hasShield: Bool) {
        heartNodes.forEach { $0.removeFromParent() }
        heartNodes.removeAll()

        let spacing: CGFloat = 26
        let total: CGFloat   = spacing * 2
        let startX = -total / 2

        for i in 0..<3 {
            let h = SKShapeNode(circleOfRadius: 9)
            h.fillColor = i < lives
                ? SKColor(red: 0.9, green: 0.15, blue: 0.15, alpha: 1)
                : SKColor(white: 0.25, alpha: 1)

            h.strokeColor = SKColor(white: 1, alpha: 0.5)
            h.lineWidth   = 1.5
            h.position    = CGPoint(
                x: startX + CGFloat(i) * spacing,
                y: sceneSize.height / 2 - 20
            )
            h.zPosition = 95

            addChild(h)
            heartNodes.append(h)
        }

        // 🛡 Shield
        if hasShield {
            let shield = SKShapeNode(circleOfRadius: 9)
            shield.fillColor   = SKColor(red: 0.25, green: 0.55, blue: 1.0, alpha: 0.9)
            shield.strokeColor = .cyan
            shield.lineWidth   = 2
            shield.position    = CGPoint(
                x: startX + 3 * spacing,
                y: sceneSize.height / 2 - 20
            )
            shield.zPosition = 95

            addChild(shield)
            heartNodes.append(shield)
        }
    }
}
