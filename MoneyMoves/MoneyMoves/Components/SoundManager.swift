import Foundation
import AVFoundation
import UIKit

// Plays interaction sounds + haptics for the buddy.
// Tries to load a bundled .wav file first; falls back to a system sound + haptic
// so the demo works out of the box without shipping copyrighted Animal Crossing audio.
//
// To drop in real Animal Crossing-style sounds:
//   1. Add the files to the Xcode project (drag into MoneyMoves group)
//   2. Name them: buddy_pet.wav, buddy_feed.wav, buddy_catch.wav
//   3. Make sure "Add to target: MoneyMoves" is checked
// They'll be picked up automatically the next time the buddy interacts.

@MainActor
final class SoundManager {
    static let shared = SoundManager()

    private var players: [String: AVAudioPlayer] = [:]
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    private let softHaptic  = UIImpactFeedbackGenerator(style: .soft)
    private let notif       = UINotificationFeedbackGenerator()

    enum Cue: String {
        case pet   = "buddy_pet"
        case feed  = "buddy_feed"
        case catchFood = "buddy_catch"
        case happy = "buddy_happy"

        // iOS system sound IDs as fallback. They're built-in and free of copyright.
        var systemFallback: SystemSoundID {
            switch self {
            case .pet:       return 1104   // Tink (light)
            case .feed:      return 1306   // Tweet (sent)
            case .catchFood: return 1054   // Tritone (happy)
            case .happy:     return 1305   // Tweet (happy)
            }
        }
    }

    private init() {
        configureSession()
        lightHaptic.prepare()
        softHaptic.prepare()
        notif.prepare()
    }

    private func configureSession() {
        // .ambient = mix with other audio, don't interrupt music/Spotify
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func play(_ cue: Cue) {
        // Haptic first — instant tactile feedback
        switch cue {
        case .pet:        lightHaptic.impactOccurred()
        case .feed:       softHaptic.impactOccurred()
        case .catchFood:  notif.notificationOccurred(.success)
        case .happy:      notif.notificationOccurred(.success)
        }

        // Try bundled .wav, fall back to system sound
        if let url = Bundle.main.url(forResource: cue.rawValue, withExtension: "wav") {
            playFile(url: url, key: cue.rawValue)
        } else {
            AudioServicesPlaySystemSound(cue.systemFallback)
        }
    }

    private func playFile(url: URL, key: String) {
        do {
            // Reuse the player if we already loaded this file
            let player: AVAudioPlayer
            if let existing = players[key] {
                player = existing
                player.currentTime = 0
            } else {
                player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                players[key] = player
            }
            player.play()
        } catch {
            // If decode fails (corrupt file, unsupported codec), fall back
            AudioServicesPlaySystemSound(1104)
        }
    }
}
