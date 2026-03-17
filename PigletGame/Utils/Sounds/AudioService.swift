//  AudioService.swift
//  PigletGame
//
//

import Foundation
import AVFoundation

final class AudioService {
    static let shared = AudioService()

    private var players: [String: AVAudioPlayer] = [:]
    private let queue = DispatchQueue(label: "AudioServiceQueue")

    private init() {}

    /// Toca um áudio do bundle (nome do arquivo com extensão, ex: "efeito.wav")
    /// Se já estiver tocando, reinicia.
    /// - Parameters:
    ///   - name: Nome do arquivo de áudio no bundle
    ///   - loop: Toca em loop se true
    ///   - volume: Volume entre 0.0 e 1.0
    func play(_ name: String, loop: Bool = false, volume: Float = 1.0) {
        queue.async {
            guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
                print("[AudioService] Arquivo não encontrado: \(name)")
                return
            }
            let player: AVAudioPlayer
            if let existing = self.players[name] {
                player = existing
                player.currentTime = 0
            } else {
                do {
                    player = try AVAudioPlayer(contentsOf: url)
                    self.players[name] = player
                } catch {
                    print("[AudioService] Erro ao criar player: \(error)")
                    return
                }
            }
            player.numberOfLoops = loop ? -1 : 0
            player.volume = volume
            player.prepareToPlay()
            player.play()
        }
    }

    /// Para um áudio específico
    func stop(_ name: String) {
        queue.async {
            if let player = self.players[name] {
                player.stop()
                self.players.removeValue(forKey: name)
            }
        }
    }

    /// Para todos os áudios
    func stopAll() {
        queue.async {
            for player in self.players.values {
                player.stop()
            }
            self.players.removeAll()
        }
    }
}
