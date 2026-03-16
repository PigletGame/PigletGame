import Foundation
import SpriteKit

class Pause: SKNode {

    var background: SKSpriteNode

    var resumeLabel: SKLabelNode
    var resumeButton: SKSpriteNode

    var exitLabel: SKLabelNode
    var exitButton: SKSpriteNode

    var onEndedPauseAction: () -> Void = { }

    private(set) var isPauseActive = false

    init(size: CGSize) {

        background = SKSpriteNode(color: .black, size: size)
        background.alpha = 0.6
        background.zPosition = 0

        resumeButton = SKSpriteNode(color: SKColor(red: 0.20, green: 0.60, blue: 0.25, alpha: 1),
                                    size: CGSize(width: size.width * 0.24, height: size.width * 0.24 * 0.45))
        resumeButton.position = CGPoint(x: 0, y: size.height * 0.1)
        resumeButton.zPosition = 1
        resumeButton.name = "playButton"

        resumeLabel = SKLabelNode(text: "Resume")
        resumeLabel.fontSize = 30
        resumeLabel.fontColor = .white
        resumeLabel.fontName = "AvenirNext-Bold"
        resumeLabel.position = CGPoint(x: 0, y: resumeButton.position.y + 90)
        resumeLabel.name = "playButton"
        resumeLabel.zPosition = 1

        exitButton = SKSpriteNode(color: SKColor(red: 0.55, green: 0.20, blue: 0.20, alpha: 1),
                                  size: CGSize(width: size.width * 0.24 * 0.72, height: size.width * 0.24 * 0.45))
        exitButton.position = CGPoint(x: 0, y: -size.height * 0.1)
        exitButton.zPosition = 1
        exitButton.name = "backButton"

        exitLabel = SKLabelNode(text: "Exit")
        exitLabel.fontSize = 30
        exitLabel.fontColor = .white
        exitLabel.fontName = "AvenirNext-Bold"
        exitLabel.position = CGPoint(x: 0, y: exitButton.position.y - 90)
        exitLabel.name = "backButton"
        exitLabel.zPosition = 1

        super.init()

        addChild(background)

        addChild(resumeLabel)
        addChild(resumeButton)

        addChild(exitLabel)
        addChild(exitButton)

        self.alpha = 0
        self.isUserInteractionEnabled = false
        self.zPosition = 2000
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func pauseGame() {
        self.alpha = 1
        self.isUserInteractionEnabled = true
        self.isPauseActive = true

        scene?.isPaused = true
        scene?.physicsWorld.speed = 0
    }

    func resumeGame() {
        self.alpha = 0
        self.isUserInteractionEnabled = false
        self.isPauseActive = false

        scene?.isPaused = false
        scene?.physicsWorld.speed = 1
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)

            if node.name == "playButton" {
                resumeGame()
                onEndedPauseAction()
            } else if node.name == "backButton" {
                scene?.isPaused = false
                scene?.physicsWorld.speed = 1
                if let skView = self.scene?.view, let currentScene = self.scene {
                    let menuScene = MenuScene(size: currentScene.size)
                    menuScene.scaleMode = currentScene.scaleMode
                    skView.presentScene(menuScene, transition: SKTransition.fade(withDuration: 0.35))
                }
            }
        }
    }
}
