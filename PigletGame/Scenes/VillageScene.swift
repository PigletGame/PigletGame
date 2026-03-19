import SpriteKit
import SwiftUI

class VillageScene: SKScene {
    private var coinsLabel: SKLabelNode!
    private var killsLabel: SKLabelNode!
    private var feedbackLabel: SKLabelNode?
    private var purchaseOverlay: SKNode?
    private var selectedSlotIndex: Int?
    var dismiss: DismissAction?

    private var slots: [GameDataStore.SlotSnapshot] = []
    private var progress = GameDataStore.ProgressSnapshot(totalCoins: 0, totalKills: 0)


    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.12, green: 0.22, blue: 0.10, alpha: 1)
        reloadDataAndRebuildScene()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        reloadDataAndRebuildScene()
    }

    private func reloadDataAndRebuildScene() {
        progress = GameDataStore.shared.progressSnapshot()
        slots = GameDataStore.shared.slotSnapshots()

        removeAllChildren()
        purchaseOverlay = nil
        selectedSlotIndex = nil

        setupScene()
    }

    private func setupScene() {

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

        coinsLabel = SKLabelNode(fontNamed: StyleGuide.Typography.medium)
        coinsLabel.text = "🪙 Moedas: \(progress.totalCoins)"
        coinsLabel.fontSize = 21
        coinsLabel.fontColor = .white
        coinsLabel.position = CGPoint(x: size.width * 0.26, y: size.height * 0.67)
        coinsLabel.horizontalAlignmentMode = .left
        coinsLabel.zPosition = 2
        addChild(coinsLabel)

        killsLabel = SKLabelNode(fontNamed: StyleGuide.Typography.medium)
        killsLabel.text = "☠ Kills: \(progress.totalKills)"
        killsLabel.fontSize = 21
        killsLabel.fontColor = .white
        killsLabel.position = CGPoint(x: size.width * 0.74, y: size.height * 0.67)
        killsLabel.horizontalAlignmentMode = .right
        killsLabel.zPosition = 2
        addChild(killsLabel)

        setupSlotsGrid()

        // Back button
        let btn = makeMenuButton()
        btn.position = CGPoint(x: size.width / 2, y: size.height * 0.13)
        addChild(btn)
    }

    private func setupSlotsGrid() {
        let columns = 3
        let slotSize = CGSize(width: 70, height: 70)
        let spacingX: CGFloat = 36
        let spacingY: CGFloat = 28
        let totalWidth = CGFloat(columns) * slotSize.width + CGFloat(columns - 1) * spacingX
        let startX = size.width / 2 - totalWidth / 2 + slotSize.width / 2
        let startY = size.height * 0.55

        for slot in slots {
            let row = slot.index / columns
            let col = slot.index % columns

            let x = startX + CGFloat(col) * (slotSize.width + spacingX)
            let y = startY - CGFloat(row) * (slotSize.height + spacingY)

            let node = makeSlotNode(slot: slot, size: slotSize)
            node.position = CGPoint(x: x, y: y)
            addChild(node)
        }
    }

    private func makeSlotNode(slot: GameDataStore.SlotSnapshot, size: CGSize) -> SKNode {
        let container = SKNode()
        container.name = "slot_\(slot.index)"
        container.zPosition = 4

        let bg = SKShapeNode(rectOf: size, cornerRadius: 8)
        bg.fillColor = slot.isPurchased
            ? SKColor(red: 0.15, green: 0.55, blue: 0.2, alpha: 1)
            : SKColor(red: 0.25, green: 0.25, blue: 0.28, alpha: 1)
        bg.strokeColor = SKColor(white: 1, alpha: 0.45)
        bg.lineWidth = 2
        bg.name = "slot_\(slot.index)"
        container.addChild(bg)

        let topLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        topLabel.text = "Lote \(slot.index + 1)"
        topLabel.fontSize = 18
        topLabel.fontColor = .white
        topLabel.position = CGPoint(x: 0, y: 22)
        topLabel.verticalAlignmentMode = .center
        topLabel.name = "slot_\(slot.index)"
        container.addChild(topLabel)

        let status = SKLabelNode(fontNamed: "AvenirNext-Medium")
        status.text = slot.isPurchased ? "COMPRADA" : "CUSTO: \(slot.cost) 🪙"
        status.fontSize = 12
        status.fontColor = slot.isPurchased
            ? SKColor(red: 0.9, green: 1.0, blue: 0.9, alpha: 1)
            : SKColor(white: 0.95, alpha: 1)
        status.position = CGPoint(x: 0, y: -14)
        status.verticalAlignmentMode = .center
        status.name = "slot_\(slot.index)"
        container.addChild(status)

        return container
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

    private func showPurchaseOverlay(for slot: GameDataStore.SlotSnapshot) {
        hidePurchaseOverlay()
        selectedSlotIndex = slot.index

        let overlay = SKNode()
        overlay.name = "purchaseOverlay"
        overlay.zPosition = 20

        let shade = SKShapeNode(rectOf: size)
        shade.fillColor = SKColor(white: 0, alpha: 0.55)
        shade.strokeColor = .clear
        shade.position = CGPoint(x: size.width / 2, y: size.height / 2)
        shade.name = "cancelPurchase"
        overlay.addChild(shade)

        let panel = SKShapeNode(rectOf: CGSize(width: 360, height: 210), cornerRadius: 14)
        panel.fillColor = SKColor(red: 0.17, green: 0.18, blue: 0.2, alpha: 1)
        panel.strokeColor = SKColor(white: 1, alpha: 0.35)
        panel.lineWidth = 2
        panel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.addChild(panel)

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "Comprar Lote \(slot.index + 1)?"
        title.fontSize = 30
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 58)
        panel.addChild(title)

        let detail = SKLabelNode(fontNamed: "AvenirNext-Medium")
        detail.text = "Custo: \(slot.cost) moedas"
        detail.fontSize = 21
        detail.fontColor = SKColor(white: 0.9, alpha: 1)
        detail.position = CGPoint(x: 0, y: 15)
        panel.addChild(detail)

        let buyButton = makeOverlayButton(text: "Comprar", name: "buySlot", color: SKColor(red: 0.22, green: 0.62, blue: 0.28, alpha: 1))
        buyButton.position = CGPoint(x: -85, y: -58)
        panel.addChild(buyButton)

        let cancelButton = makeOverlayButton(text: "Cancelar", name: "cancelPurchase", color: SKColor(red: 0.55, green: 0.2, blue: 0.2, alpha: 1))
        cancelButton.position = CGPoint(x: 85, y: -58)
        panel.addChild(cancelButton)

        addChild(overlay)
        purchaseOverlay = overlay
    }

    private func hidePurchaseOverlay() {
        purchaseOverlay?.removeFromParent()
        purchaseOverlay = nil
        selectedSlotIndex = nil
    }

    private func makeOverlayButton(text: String, name: String, color: SKColor) -> SKNode {
        let container = SKNode()
        container.name = name

        let bg = SKShapeNode(rectOf: CGSize(width: 140, height: 44), cornerRadius: 10)
        bg.fillColor = color
        bg.strokeColor = SKColor(white: 1, alpha: 0.45)
        bg.lineWidth = 1.5
        bg.name = name
        container.addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = text
        label.fontSize = 20
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.name = name
        container.addChild(label)

        return container
    }

    private func purchaseSelectedSlot() {
        guard let index = selectedSlotIndex else { return }

        let result = GameDataStore.shared.purchaseSlot(index: index)
        switch result {
        case .purchased:
            showFeedback("Lote comprado com sucesso!")
            reloadDataAndRebuildScene()
        case .alreadyOwned:
            showFeedback("Esse lote já foi comprado.")
            hidePurchaseOverlay()
        case let .insufficientFunds(required, current):
            showFeedback("Faltam \(required - current) moedas para comprar.")
        case .unavailable:
            showFeedback("Não foi possível comprar agora.")
            hidePurchaseOverlay()
        }
    }

    private func showFeedback(_ message: String) {
        feedbackLabel?.removeFromParent()

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = message
        label.fontSize = 18
        label.fontColor = SKColor(red: 1.0, green: 0.92, blue: 0.65, alpha: 1)
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.22)
        label.zPosition = 30
        addChild(label)
        feedbackLabel = label

        label.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.6),
            SKAction.fadeOut(withDuration: 0.35),
            SKAction.removeFromParent()
        ]))
    }

    private func slot(for index: Int) -> GameDataStore.SlotSnapshot? {
        slots.first { $0.index == index }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)

        for node in nodes(at: loc) {
            guard let name = node.name else { continue }

            if name == "menuBtn" {
                self.dismiss?()
            }

            if name == "buySlot" {
                purchaseSelectedSlot()
                return
            }

            if name == "cancelPurchase" {
                hidePurchaseOverlay()
                return
            }

            if name.hasPrefix("slot_"),
               let index = Int(name.replacingOccurrences(of: "slot_", with: "")),
               let slot = slot(for: index) {
                if slot.isPurchased {
                    showFeedback("Lote \(index + 1) já comprado.")
                } else {
                    showPurchaseOverlay(for: slot)
                }
                return
            }
        }

        if purchaseOverlay != nil {
            hidePurchaseOverlay()
            return
        }
    }
}
