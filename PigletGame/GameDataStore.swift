import Foundation
import SwiftData

@Model
final class PlayerProgress {
    @Attribute(.unique) var id: String
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
    @Attribute(.unique) var slotIndex: Int
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

    static let shared = GameDataStore()

    private init() {}

    private var container: ModelContainer?

    private let defaultSlots: [(index: Int, cost: Int)] = [
        (0, 20),
        (1, 35),
        (2, 55),
        (3, 80),
        (4, 120),
        (5, 170)
    ]

    func configure(container: ModelContainer) {
        self.container = container
        bootstrapIfNeeded()
    }

    func progressSnapshot() -> ProgressSnapshot {
        guard let context else { return ProgressSnapshot(totalCoins: 0, totalKills: 0) }
        bootstrapIfNeeded()
        guard let progress = fetchOrCreateProgress(in: context) else {
            return ProgressSnapshot(totalCoins: 0, totalKills: 0)
        }
        return ProgressSnapshot(totalCoins: progress.totalCoins, totalKills: progress.totalKills)
    }

    func slotSnapshots() -> [SlotSnapshot] {
        guard let context else { return [] }
        bootstrapIfNeeded()
        let descriptor = FetchDescriptor<VillageSlotState>(sortBy: [SortDescriptor(\.slotIndex)])
        let slots = (try? context.fetch(descriptor)) ?? []
        return slots.map { SlotSnapshot(index: $0.slotIndex, cost: $0.cost, isPurchased: $0.isPurchased) }
    }

    @discardableResult
    func recordRun(collectedCoins: Int, kills: Int) -> ProgressSnapshot {
        guard let context else { return ProgressSnapshot(totalCoins: 0, totalKills: 0) }
        bootstrapIfNeeded()
        guard let progress = fetchOrCreateProgress(in: context) else {
            return ProgressSnapshot(totalCoins: 0, totalKills: 0)
        }

        progress.totalCoins += max(0, collectedCoins)
        progress.totalKills += max(0, kills)
        saveContext(context)

        return ProgressSnapshot(totalCoins: progress.totalCoins, totalKills: progress.totalKills)
    }

    func purchaseSlot(index: Int) -> PurchaseResult {
        guard let context else { return .unavailable }
        bootstrapIfNeeded()

        let slotDescriptor = FetchDescriptor<VillageSlotState>(predicate: #Predicate { $0.slotIndex == index })
        guard let slot = try? context.fetch(slotDescriptor).first else { return .unavailable }
        if slot.isPurchased { return .alreadyOwned }

        guard let progress = fetchOrCreateProgress(in: context) else { return .unavailable }
        if progress.totalCoins < slot.cost {
            return .insufficientFunds(required: slot.cost, current: progress.totalCoins)
        }

        progress.totalCoins -= slot.cost
        slot.isPurchased = true
        saveContext(context)
        return .purchased(remainingCoins: progress.totalCoins)
    }

    private var context: ModelContext? {
        container?.mainContext
    }

    private func bootstrapIfNeeded() {
        guard let context else { return }

        _ = fetchOrCreateProgress(in: context)

        let descriptor = FetchDescriptor<VillageSlotState>()
        let existingSlots = (try? context.fetch(descriptor)) ?? []
        let existingIndexes = Set(existingSlots.map(\.slotIndex))

        for item in defaultSlots where !existingIndexes.contains(item.index) {
            context.insert(VillageSlotState(slotIndex: item.index, cost: item.cost, isPurchased: false))
        }

        saveContext(context)
    }

    private func fetchOrCreateProgress(in context: ModelContext) -> PlayerProgress? {
        let descriptor = FetchDescriptor<PlayerProgress>(predicate: #Predicate { $0.id == "main" })
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
