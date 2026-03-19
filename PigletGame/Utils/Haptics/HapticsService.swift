import Foundation
import CoreHaptics
import UIKit
import AudioToolbox

enum HapticFeedbackStrength {
    case light
    case medium
    case heavy
    case soft
    case gameOver

    fileprivate var style: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .light, .soft:
            return .light
        case .medium:
            return .medium
        case .heavy, .gameOver:
            return .heavy
        }
    }
}

final class HapticsService {
    static let shared = HapticsService()

    private var isMuted: Bool = false
    private let supportsHaptics: Bool
    private var engine: CHHapticEngine?
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private init() {
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        prepareHapticsIfNeeded()
        registerLifecycleObservers()
        prepareUIKitGenerators()
    }

    var isEnabled: Bool {
        !isMuted
    }

    func setEnabled(_ enabled: Bool) {
        isMuted = !enabled

        if enabled {
            prepareUIKitGenerators()
            ensureEngineRunningIfNeeded()
        } else {
            stopEngineIfNeeded()
        }
    }

    @discardableResult
    func toggleEnabled() -> Bool {
        let next = !isEnabled
        setEnabled(next)
        return next
    }

    func light() {
        vibrate(with: .light)
    }

    func medium() {
        vibrate(with: .medium)
    }

    func heavy() {
        vibrate(with: .heavy)
    }

    func gameOver() {
        vibrate(with: .gameOver)
    }

    func vibrate(with strength: HapticFeedbackStrength) {
        guard !isMuted else { return }

        if supportsHaptics {
            ensureEngineRunningIfNeeded()
            if playCoreImpact(strength: strength) {
                return
            }
        }

        playUIKitFallback(strength: strength)
    }

    private func prepareHapticsIfNeeded() {
        guard supportsHaptics else { return }
        guard engine == nil else { return }

        do {
            engine = try CHHapticEngine()
            try engine?.start()

            engine?.stoppedHandler = { [weak self] _ in
                self?.ensureEngineRunningIfNeeded()
            }

            engine?.resetHandler = { [weak self] in
                self?.ensureEngineRunningIfNeeded()
            }
        } catch {
            print("[HapticsService] Failed to create haptic engine: \(error)")
            engine = nil
        }
    }

    private func ensureEngineRunningIfNeeded() {
        guard !isMuted, supportsHaptics else { return }

        if engine == nil {
            prepareHapticsIfNeeded()
        }

        do {
            try engine?.start()
        } catch {
            print("[HapticsService] Failed to start haptic engine: \(error)")
        }
    }

    private func stopEngineIfNeeded() {
        guard supportsHaptics else { return }

        engine?.stop(completionHandler: nil)
    }

    private func playPattern(events: [CHHapticEvent], curves: [CHHapticParameterCurve] = []) {
        guard !isMuted, supportsHaptics, let engine else { return }

        do {
            let pattern = try CHHapticPattern(events: events, parameterCurves: curves)
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("[HapticsService] Failed to play haptic pattern: \(error)")
        }
    }

    @discardableResult
    private func playCoreImpact(strength: HapticFeedbackStrength) -> Bool {
        let events: [CHHapticEvent]

        if strength == .heavy {
            let firstPulse = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0),
                ],
                relativeTime: 0
            )

            let rumble = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.45),
                ],
                relativeTime: 0.01,
                duration: 0.22
            )

            let secondPulse = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0),
                ],
                relativeTime: 0.24
            )

            events = [firstPulse, rumble, secondPulse]
        } else if strength == .gameOver {
            events = [
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0),
                    ],
                    relativeTime: 0.0
                ),
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0),
                    ],
                    relativeTime: 0.09
                ),
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0),
                    ],
                    relativeTime: 0.18
                )
            ]
        } else {
            let (intensity, sharpness) = impactParameters(for: strength)
            events = [
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness),
                    ],
                    relativeTime: 0
                )
            ]
        }

        do {
            let pattern = try CHHapticPattern(events: events, parameterCurves: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
            return true
        } catch {
            print("[HapticsService] Core impact failed, using UIKit fallback: \(error)")
            return false
        }
    }

    private func playUIKitFallback(strength: HapticFeedbackStrength) {
        let action = {
            if #available(iOS 10.0, *) {
                if strength == .gameOver {
                    self.notificationGenerator.prepare()
                    self.notificationGenerator.notificationOccurred(.error)
                    return
                }

                let generator: UIImpactFeedbackGenerator
                switch strength {
                case .light, .soft:
                    generator = self.lightGenerator
                case .medium:
                    generator = self.mediumGenerator
                case .heavy, .gameOver:
                    generator = self.heavyGenerator
                }
                generator.prepare()
                generator.impactOccurred()

                if strength == .heavy {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        generator.prepare()
                        generator.impactOccurred()
                    }
                }
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }

        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }

    private func prepareUIKitGenerators() {
        let action = {
            self.lightGenerator.prepare()
            self.mediumGenerator.prepare()
            self.heavyGenerator.prepare()
            self.notificationGenerator.prepare()
        }

        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async(execute: action)
        }
    }

    private func registerLifecycleObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.ensureEngineRunningIfNeeded()
            self?.prepareUIKitGenerators()
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.stopEngineIfNeeded()
        }
    }

    private func impactParameters(for strength: HapticFeedbackStrength) -> (Float, Float) {
        switch strength {
        case .light:
            return (0.45, 0.65)
        case .medium:
            return (0.85, 0.85)
        case .heavy:
            return (1.0, 1.0)
        case .soft:
            return (0.55, 0.35)
        case .gameOver:
            return (1.0, 1.0)
        }
    }
}
