import SpriteKit
import SwiftUI

class VillageScene: SKScene {

    // 🔥 CALLBACK PARA VOLTAR
    var onBack: (() -> Void)?

    private var coinsLabel: SKLabelNode!
    private var killsLabel: SKLabelNode!
    private var feedbackLabel: SKLabelNode?
    private var purchaseOverlay: SKNode?
    private var selectedSlotIndex: Int?

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
        sky.fillColor = SKColor(red: 0.25, green: 0.50, blue: 0.80, alpha: 1)
        sky.strokeColor = .clear
        sky.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        sky.zPosition = -5
        addChild(sky)

        let ground = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.5))
        ground.fillColor = SKColor(red: 0.20, green: 0.45, blue: 0.18, alpha: 1)
        ground.strokeColor = .clear
        ground.position = CGPoint(x: size.width / 2, y: size.height * 0.23)
        ground.zPosition = -5
        addChild(ground)

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "🏡  VILA"
        title.fontSize = 40
        title.fontColor = .white
        title.position = CGPoint(x: size.width / 2, y: size.height * 0.78)
        addChild(title)

        coinsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        coinsLabel.text = "🪙 Moedas: \(progress.totalCoins)"
        coinsLabel.fontSize = 21
        coinsLabel.position = CGPoint(x: size.width * 0.26, y: size.height * 0.67)
        coinsLabel.horizontalAlignmentMode = .left
        addChild(coinsLabel)

        killsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        killsLabel.text = "☠ Kills: \(progress.totalKills)"
        killsLabel.fontSize = 21
        killsLabel.position = CGPoint(x: size.width * 0.74, y: size.height * 0.67)
        killsLabel.horizontalAlignmentMode = .right
        addChild(killsLabel)

        setupSlotsGrid()

        let btn = makeMenuButton()
        btn.position = CGPoint(x: size.width / 2, y: size.height * 0.13)
        addChild(btn)
    }

    private func makeMenuButton() -> SKNode {
        let container = SKNode()
        container.name = "menuBtn"

        let bg = SKShapeNode(rectOf: CGSize(width: 200, height: 48), cornerRadius: 10)
        bg.fillColor = SKColor(red: 0.18, green: 0.35, blue: 0.65, alpha: 1)
        bg.name = "menuBtn"

        let lbl = SKLabelNode(fontNamed: "AvenirNext-Bold")
        lbl.text = "← Menu"
        lbl.verticalAlignmentMode = .center
        lbl.name = "menuBtn"

        container.addChild(bg)
        container.addChild(lbl)
        return container
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)

        for node in nodes(at: loc) {
            guard let name = node.name else { continue }

            // 🔥 VOLTAR CORRETO
            if name == "menuBtn" {
                onBack?()
                return
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
        }
    }

    // MARK: - Restante (igual ao seu)

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
            showFeedback("Faltam \(required - current) moedas.")
        case .unavailable:
            showFeedback("Não foi possível comprar.")
            hidePurchaseOverlay()
        }
    }

    private func showFeedback(_ message: String) {
        feedbackLabel?.removeFromParent()

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = message
        label.fontSize = 18
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.22)
        addChild(label)
        feedbackLabel = label

        label.run(.sequence([
            .wait(forDuration: 1.6),
            .fadeOut(withDuration: 0.3),
            .removeFromParent()
        ]))
    }

    private func slot(for index: Int) -> GameDataStore.SlotSnapshot? {
        slots.first { $0.index == index }
    }

    private func showPurchaseOverlay(for slot: GameDataStore.SlotSnapshot) {
        selectedSlotIndex = slot.index
    }

    private func hidePurchaseOverlay() {
        purchaseOverlay?.removeFromParent()
        purchaseOverlay = nil
        selectedSlotIndex = nil
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

        let bg = SKShapeNode(rectOf: size, cornerRadius: 8)
        bg.fillColor = SKColor(red: 0.15, green: 0.55, blue: 0.2, alpha: 1)
        bg.strokeColor = SKColor(white: 1, alpha: 0.45)
        bg.lineWidth = 2
        bg.name = "slot_\(slot.index)"
        container.addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "Casa \(slot.index + 1)"
        label.fontSize = 14
        label.verticalAlignmentMode = .center
        label.name = "slot_\(slot.index)"
        container.addChild(label)

        return container
    }
}
