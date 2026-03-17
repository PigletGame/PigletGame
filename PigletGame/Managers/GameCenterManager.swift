//
//  GameCenterManager.swift
//  PigletGame
//
//  Created by Diogo Camargo on 17/03/26.
//


import GameKit
import SwiftUI
import Combine

class GameCenterManager {
    static let shared = GameCenterManager()

    var isAuthenticated = false
    var localPlayer: GKLocalPlayer?
    @Published var currentRank: Int = 0

    private let leaderboardID = "leaders"

    private init() {}

    func authenticatePlayer() {
            print("[GameCenter] Iniciando autenticação...")
            GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
                guard let self = self else { return }

                if let viewController = viewController {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootViewController = windowScene.windows.first?.rootViewController {
                        rootViewController.present(viewController, animated: true)
                    }
                    return
                }

                if let error = error {
                    print("[GameCenter] Erro: \(error.localizedDescription)")
                    self.isAuthenticated = false
                    return
                }

                if GKLocalPlayer.local.isAuthenticated {
                    self.isAuthenticated = true
                    self.localPlayer = GKLocalPlayer.local
                    print("[GameCenter] Autenticado: \(GKLocalPlayer.local.displayName)")
                    self.fetchPlayerRank()
                }
            }
        }

    func submitScore(_ score: Int, completion: ((Bool, Error?) -> Void)? = nil) {
        print("[GameCenter] Tentando enviar score: \(score)")

        guard isAuthenticated else {
            print("[GameCenter] Não autenticado para enviar score")
            completion?(false, nil)
            return
        }

        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [leaderboardID]
        ) { error in
            if let error = error {
                print("[GameCenter] Erro ao enviar score: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion?(false, error)
                }
            } else {
                print("[GameCenter] Score enviado com sucesso: \(score)")

                self.fetchPlayerRank()

                DispatchQueue.main.async {
                    completion?(true, nil)
                }
            }
        }
    }

    func fetchPlayerRank() {
        guard isAuthenticated else { return }

        GKLeaderboard.loadLeaderboards(IDs: [leaderboardID]) { [weak self] leaderboards, error in
            guard let self = self, let leaderboard = leaderboards?.first else { return }

            leaderboard.loadEntries(for: .global, timeScope: .allTime, range: NSRange(location: 1, length: 1)) { localEntry, _, _, _ in
                DispatchQueue.main.async {
                    self.currentRank = localEntry?.rank ?? 0
                    print("[GameCenter] Novo Rank UI: \(self.currentRank)")
                }
            }
        }
    }

    func showLeaderboard() {
        guard isAuthenticated else { return }
        let viewController = GKGameCenterViewController(leaderboardID: leaderboardID, playerScope: .global, timeScope: .allTime)
        viewController.gameCenterDelegate = GameCenterDelegate.shared

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(viewController, animated: true)
        }
    }
}

class GameCenterDelegate: NSObject, GKGameCenterControllerDelegate {
    static let shared = GameCenterDelegate()

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        print("[GameCenter] Leaderboard foi fechada pelo usuário")
        gameCenterViewController.dismiss(animated: true)
    }
}

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let rank: Int
    let playerName: String
    let score: Int
}
