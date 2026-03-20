import SpriteKit

class HUDNode: SKNode {

    private var killLabel:  SKLabelNode!
    private var scoreLabel: SKLabelNode!
    private var coinLabel:  SKLabelNode!
    private var statusNodes: [SKSpriteNode] = []
    
    private var killIcon:  SKSpriteNode!
    private var scoreIcon: SKSpriteNode!
    private var coinIcon:  SKSpriteNode!
    private var pauseButton: SKSpriteNode!

    private let sceneSize: CGSize
    private let margin: CGFloat = 20
    private let lineSpacing: CGFloat = 28
    
    var onPausePressed: (() -> Void)?

    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        super.init()
        zPosition = 90
        isUserInteractionEnabled = true
        buildHUD()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: – Build

    private func buildHUD() {
        let topY = sceneSize.height / 2 - margin - 5
        let rightX = sceneSize.width / 2 - margin
        let leftX = -sceneSize.width / 2 + margin
        
        // --- Left Side ---
        // Kills Row (Icon on Left)
        killIcon = makeIcon(named: "Tiger/Standby")
        killIcon.anchorPoint = CGPoint(x: 0, y: 0.5)
        killIcon.position = CGPoint(x: leftX, y: topY - lineSpacing)
        addChild(killIcon)
        
        killLabel = makeValueLabel(align: .left)
        killLabel.position = CGPoint(x: killIcon.position.x + 24, y: topY - lineSpacing)
        addChild(killLabel)

        // --- Right Side ---
        // Score Row (Icon on Right)
        scoreIcon = makeIcon(named: "HUD/Score") // Placeholder as requested
        scoreIcon.anchorPoint = CGPoint(x: 1, y: 0.5)
        scoreIcon.position = CGPoint(x: rightX, y: topY)
        addChild(scoreIcon)
        
        scoreLabel = makeValueLabel(align: .right)
        scoreLabel.position = CGPoint(x: scoreIcon.position.x - 24, y: topY)
        addChild(scoreLabel)
        
        // Coin Row (Icon on Right)
        coinIcon = makeIcon(named: "HUD/Coin")
        coinIcon.anchorPoint = CGPoint(x: 1, y: 0.5)
        coinIcon.position = CGPoint(x: rightX, y: topY - lineSpacing)
        addChild(coinIcon)
        
        coinLabel = makeValueLabel(align: .right)
        coinLabel.position = CGPoint(x: coinIcon.position.x - 24, y: topY - lineSpacing)
        addChild(coinLabel)
        
        // --- Pause Button ---
        pauseButton = SKSpriteNode(color: .white.withAlphaComponent(0.2), size: CGSize(width: 34, height: 34))
        pauseButton.position = CGPoint(x: rightX - 5, y: topY - lineSpacing * 2.5)
        pauseButton.name = "pauseButton"
        pauseButton.zPosition = 100
        
        // Add a simple "||" label for the pause icon since we might not have a texture
        let pauseLabel = SKLabelNode(text: "||")
        pauseLabel.fontName = StyleGuide.Typography.heavy
        pauseLabel.fontSize = 18
        pauseLabel.verticalAlignmentMode = .center
        pauseLabel.horizontalAlignmentMode = .center
        pauseLabel.fontColor = .white
        pauseButton.addChild(pauseLabel)
        
        addChild(pauseButton)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        if nodes.contains(where: { $0.name == "pauseButton" || $0.parent?.name == "pauseButton" }) {
            onPausePressed?()
        }
    }

    private func makeValueLabel(align: SKLabelHorizontalAlignmentMode) -> SKLabelNode {
        let lbl = SKLabelNode(fontNamed: StyleGuide.Typography.bold)
        lbl.fontSize  = 16
        lbl.fontColor = .white
        lbl.horizontalAlignmentMode = align
        lbl.verticalAlignmentMode   = .center
        lbl.zPosition = 95
        
        let shadow = SKLabelNode(fontNamed: StyleGuide.Typography.bold)
        shadow.fontSize = lbl.fontSize
        shadow.fontColor = .black
        shadow.alpha = 0.5
        shadow.horizontalAlignmentMode = align
        shadow.verticalAlignmentMode = .center
        shadow.position = CGPoint(x: 1, y: -1)
        shadow.zPosition = -1
        lbl.addChild(shadow)
        
        return lbl
    }

    private func makeIcon(named name: String) -> SKSpriteNode {
        let node = SKSpriteNode(imageNamed: name)
        node.texture?.filteringMode = .nearest
        node.zPosition = 95
        
        let size: CGFloat = 18
        let texSize = node.texture?.size() ?? .zero
        if texSize.width > 0 {
            let ratio = size / max(texSize.width, texSize.height)
            node.size = CGSize(width: texSize.width * ratio, height: texSize.height * ratio)
        }
        return node
    }

    // MARK: – Update

    func update(score: Int, kills: Int, coins: Int, lives: Int, hasShield: Bool) {
        killLabel.text = "\(kills)"
        updateShadow(for: killLabel)
        
        scoreLabel.text = "\(score)"
        updateShadow(for: scoreLabel)
        
        coinLabel.text = "\(coins)"
        updateShadow(for: coinLabel)
        
        rebuildStatusIcons(lives: lives, hasShield: hasShield)
    }
    
    private func updateShadow(for label: SKLabelNode) {
        if let shadow = label.children.first as? SKLabelNode {
            shadow.text = label.text
        }
    }

    private func rebuildStatusIcons(lives: Int, hasShield: Bool) {
        statusNodes.forEach { $0.removeFromParent() }
        statusNodes.removeAll()

        let iconSpacing: CGFloat = 22
        let startX = -sceneSize.width / 2 + margin + 10
        let topY = sceneSize.height / 2 - margin - 5

        for i in 0..<3 {
            let textureName = i < lives ? "HUD/Heart" : "HUD/HeartEmpty"
            let h = makeStatusIcon(named: textureName)
            h.position    = CGPoint(x: startX + CGFloat(i) * iconSpacing, y: topY)
            addChild(h)
            statusNodes.append(h)
        }

        // Shield
        if hasShield {
            let shield = makeStatusIcon(named: "HUD/Shield")
            shield.position    = CGPoint(x: startX + 3 * iconSpacing, y: topY)
            addChild(shield)
            statusNodes.append(shield)
        }
    }

    private func makeStatusIcon(named name: String) -> SKSpriteNode {
        let node = SKSpriteNode(imageNamed: name)
        node.texture?.filteringMode = .nearest
        node.zPosition = 95

        let maxSize: CGFloat = 20
        let textureSize = node.texture?.size() ?? .zero

        if textureSize.width > 0 && textureSize.height > 0 {
            let widthRatio = maxSize / textureSize.width
            let heightRatio = maxSize / textureSize.height
            let ratio = min(widthRatio, heightRatio)
            node.size = CGSize(width: textureSize.width * ratio, height: textureSize.height * ratio)
        } else {
            node.size = CGSize(width: maxSize, height: maxSize)
        }

        return node
    }
}
