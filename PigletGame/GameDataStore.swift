import Foundation
import SwiftData

@Model
final class PlayerProgress {
    var id: String
    var totalCoins: Int
    var totalKills: Int

    init(id: String = "main", totalCoins: Int = 0, totalKills: Int = 0) {
        self.id = id
        self.totalCoins = totalCoins
        self.totalKills = totalKills
    }
}

@Model
final class VillageSlotState {
    var slotIndex: Int
    var cost: Int
    var isPurchased: Bool

    init(slotIndex: Int, cost: Int, isPurchased: Bool = false) {
        self.slotIndex = slotIndex
        self.cost = cost
        self.isPurchased = isPurchased
    }
}

@MainActor
final class GameDataStore {

    // MARK: – Tipos públicos

    struct ProgressSnapshot {
        let totalCoins: Int
        let totalKills: Int
    }

    struct SlotSnapshot {
        let index: Int
        let cost: Int
        let isPurchased: Bool
    }

    enum PurchaseResult {
        case purchased(remainingCoins: Int)
        case alreadyOwned
        case insufficientFunds(required: Int, current: Int)
        case unavailable
    }

    // MARK: – Singleton

    static let shared = GameDataStore()
    private init() {}

    private var container: ModelContainer?

    // MARK: – Configuração

    func configure(container: ModelContainer) {
        self.container = container
        bootstrapIfNeeded()
    }

    // MARK: – Custo dinâmico

    func slotCost(for index: Int) -> Int {
        Int(20.0 * pow(1.12, Double(index)))
    }

    // MARK: – Leitura
    func progressSnapshot() -> ProgressSnapshot {
        guard let context else {
            return ProgressSnapshot(totalCoins: 0, totalKills: 0)
        }
        guard let progress = fetchOrCreateProgress(in: context) else {
            return ProgressSnapshot(totalCoins: 0, totalKills: 0)
        }
        return ProgressSnapshot(
            totalCoins: progress.totalCoins,
            totalKills: progress.totalKills
        )
    }

    func slotSnapshots() -> [SlotSnapshot] {
        guard let context else { return [] }
        let descriptor = FetchDescriptor<VillageSlotState>(
            sortBy: [SortDescriptor(\.slotIndex)]
        )
        let slots = (try? context.fetch(descriptor)) ?? []
        return slots.map {
            SlotSnapshot(index: $0.slotIndex, cost: $0.cost, isPurchased: $0.isPurchased)
        }
    }

    func purchasedSlotsCount() -> Int {
        guard let context else { return 0 }
        let descriptor = FetchDescriptor<VillageSlotState>()
        let slots = (try? context.fetch(descriptor)) ?? []
        return slots.filter { $0.isPurchased }.count
    }

    // MARK: – Escrita

    @discardableResult
    func recordRun(collectedCoins: Int, kills: Int) -> ProgressSnapshot {
        guard let context else {
            return ProgressSnapshot(totalCoins: 0, totalKills: 0)
        }
        guard let progress = fetchOrCreateProgress(in: context) else {
            return ProgressSnapshot(totalCoins: 0, totalKills: 0)
        }

        progress.totalCoins += max(0, collectedCoins)
        progress.totalKills += max(0, kills)
        saveContext(context)

        return ProgressSnapshot(
            totalCoins: progress.totalCoins,
            totalKills: progress.totalKills
        )
    }

    func purchaseSlot(index: Int) -> PurchaseResult {
        guard let context else { return .unavailable }

        // Só permite compra em sequência
        let currentCount = purchasedSlotsCount()
        guard index == currentCount else { return .unavailable }

        // Verifica se já existe (proteção contra double-tap)
        let existingDescriptor = FetchDescriptor<VillageSlotState>(
            predicate: #Predicate { $0.slotIndex == index }
        )
        if let existing = try? context.fetch(existingDescriptor).first {
            return existing.isPurchased ? .alreadyOwned : .unavailable
        }

        guard let progress = fetchOrCreateProgress(in: context) else {
            return .unavailable
        }

        let cost = slotCost(for: index)

        guard progress.totalCoins >= cost else {
            return .insufficientFunds(required: cost, current: progress.totalCoins)
        }

        progress.totalCoins -= cost
        context.insert(VillageSlotState(slotIndex: index, cost: cost, isPurchased: true))
        saveContext(context)

        GameCenterManager.shared.submitScore(index + 1)

        return .purchased(remainingCoins: progress.totalCoins)
    }

    // MARK: – Privado

    private var context: ModelContext? {
        container?.mainContext
    }

    private func bootstrapIfNeeded() {
        guard let context else { return }
        _ = fetchOrCreateProgress(in: context)
        saveContext(context)
    }

    private func fetchOrCreateProgress(in context: ModelContext) -> PlayerProgress? {
        let descriptor = FetchDescriptor<PlayerProgress>(
            predicate: #Predicate { $0.id == "main" }
        )
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let created = PlayerProgress()
        context.insert(created)
        saveContext(context)
        return created
    }

    private func saveContext(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            assertionFailure("Falha ao salvar SwiftData: \(error)")
        }
    }
}
