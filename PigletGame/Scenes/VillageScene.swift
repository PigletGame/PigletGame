import SpriteKit

class VillageScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.12, green: 0.22, blue: 0.10, alpha: 1)
        setupScene()
    }

    private func setupScene() {
        // Sky gradient feel – simple coloured strips
        let sky = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.55))
        sky.fillColor   = SKColor(red: 0.25, green: 0.50, blue: 0.80, alpha: 1)
        sky.strokeColor = .clear
        sky.position    = CGPoint(x: size.width / 2, y: size.height * 0.72)
        sky.zPosition   = -5
        addChild(sky)

        let ground = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.5))
        ground.fillColor   = SKColor(red: 0.20, green: 0.45, blue: 0.18, alpha: 1)
        ground.strokeColor = .clear
        ground.position    = CGPoint(x: size.width / 2, y: size.height * 0.23)
        ground.zPosition   = -5
        addChild(ground)

        // Title
        let title = SKLabelNode(fontNamed: StyleGuide.Typography.heavy)
        title.text      = "🏡  VILA"
        title.fontSize  = 40
        title.fontColor = .white
        title.position  = CGPoint(x: size.width / 2, y: size.height * 0.78)
        title.zPosition = 1
        addChild(title)

        let sub = SKLabelNode(fontNamed: StyleGuide.Typography.medium)
        sub.text      = "Em Construção..."
        sub.fontSize  = 20
        sub.fontColor = SKColor(white: 0.9, alpha: 0.8)
        sub.position  = CGPoint(x: size.width / 2, y: size.height * 0.65)
        sub.zPosition = 1
        addChild(sub)

        // Back button
        let btn = makeMenuButton()
        btn.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        addChild(btn)
    }

    private func makeMenuButton() -> SKNode {
        let container = SKNode()
        container.name     = "menuBtn"
        container.zPosition = 5

        let bg = SKShapeNode(rectOf: CGSize(width: 200, height: 48), cornerRadius: 10)
        bg.fillColor   = SKColor(red: 0.18, green: 0.35, blue: 0.65, alpha: 1)
        bg.strokeColor = SKColor(white: 1, alpha: 0.5)
        bg.lineWidth   = 1.5
        bg.name        = "menuBtn"

        let lbl = SKLabelNode(fontNamed: StyleGuide.Typography.bold)
        lbl.text      = "← Menu"
        lbl.fontSize  = 20
        lbl.fontColor = .white
        lbl.verticalAlignmentMode = .center
        lbl.name      = "menuBtn"

        container.addChild(bg)
        container.addChild(lbl)
        return container
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        for node in nodes(at: loc) where node.name == "menuBtn" {
            let scene = MenuScene()
            scene.scaleMode = .resizeFill
            view?.presentScene(scene, transition: SKTransition.fade(withDuration: 0.4))
            return
        }
    }
}
