//
//  PigletGameApp.swift
//  PigletGame
//
//  Created by Adriel de Souza on 13/03/26.
//

import SwiftUI
import SwiftData

@main
struct PigletGameApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        GameCenterManager.shared.authenticatePlayer()
    }

    private let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PlayerProgress.self,
            VillageSlotState.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            GameDataStore.shared.configure(container: container)
            return container
        } catch {
            fatalError("Erro ao criar ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainMenu()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        .landscape
    }
}

#Preview{
    MainMenu()
}
