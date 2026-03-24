//  AudioService.swift
//  PigletGame
//
//

import Foundation
import AVFoundation

@Observable
final class AudioService {
    static let shared = AudioService()

    private var players: [String: AVAudioPlayer] = [:]
    private var isMuted: Bool = false
    private var pausedByMute: Set<String> = []
    private let queue = DispatchQueue(label: "AudioServiceQueue")

    private init() {
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            print("[AudioService] Failed to configure audio session: \(error)")
        }
    }
    
    /// Toca um áudio do bundle (nome do arquivo com extensão, ex: "efeito.wav")
    /// Se já estiver tocando, reinicia.
    /// - Parameters:
    ///   - name: Nome do arquivo de áudio no bundle
    ///   - loop: Toca em loop se true
    ///   - volume: Volume entre 0.0 e 1.0
    func play(_ name: String, loop: Bool = false, volume: Float = 1.0) {
        queue.async {
            if self.isMuted { return }
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

    /// Pausa um áudio específico mantendo a posição
    func pause(_ name: String) {
        queue.async {
            self.players[name]?.pause()
        }
    }

    /// Retoma um áudio pausado
    func resume(_ name: String) {
        queue.async {
            if self.isMuted { return }
            self.players[name]?.play()
        }
    }

    /// Ativa ou desativa o mute global
    func setMuted(_ muted: Bool) {
        queue.async {
            self.isMuted = muted
            if muted {
                self.pausedByMute.removeAll()
                for (name, player) in self.players {
                    if player.isPlaying {
                        player.pause()
                        self.pausedByMute.insert(name)
                    }
                }
            } else {
                for name in self.pausedByMute {
                    self.players[name]?.play()
                }
                self.pausedByMute.removeAll()
            }
        }
    }

    /// Alterna entre mute e som
    func toggleMute() {
        setMuted(!isMuted)
    }

    /// Retorna o estado atual do mute
    var isAudioMuted: Bool {
        queue.sync { isMuted }
    }
}
