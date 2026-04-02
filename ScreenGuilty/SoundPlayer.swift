import AVFoundation
import Foundation

/// AVFoundation 기반 사운드 재생기
class SoundPlayer: NSObject {
    static let shared = SoundPlayer()

    private var audioPlayer: AVAudioPlayer?

    override init() {
        super.init()
    }

    // MARK: - 감정 기반 재생
    func play(emotion: EmotionLevel) {
        guard let soundName = emotion.soundName else { return }
        play(soundName: soundName)
    }

    // MARK: - 이름 기반 재생
    func play(soundName: String) {
        // 번들에서 사운드 파일 찾기 (mp3 또는 wav)
        let extensions = ["mp3", "wav", "aiff"]
        var soundURL: URL? = nil

        for ext in extensions {
            // 앱 번들 리소스에서 사운드 파일 찾기
            if let url = Bundle.main.url(forResource: soundName, withExtension: ext, subdirectory: "Sounds") {
                soundURL = url
                break
            }
            if let url = Bundle.main.url(forResource: soundName, withExtension: ext, subdirectory: "Resources/Sounds") {
                soundURL = url
                break
            }
            if let url = Bundle.main.url(forResource: soundName, withExtension: ext) {
                soundURL = url
                break
            }
        }

        guard let url = soundURL else {
            // 사운드 파일 없으면 시스템 사운드로 대체
            playSystemSound(for: soundName)
            return
        }

        do {
            audioPlayer?.stop()
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 0.7
            audioPlayer?.play()
        } catch {
            playSystemSound(for: soundName)
        }
    }

    // MARK: - 시스템 사운드 폴백
    private func playSystemSound(for soundName: String) {
        let soundId: SystemSoundID
        switch soundName {
        case "sigh":        soundId = 1006  // Tink
        case "sob":         soundId = 1017  // Morse
        case "angry":       soundId = 1005  // Blow
        case "cheer":       soundId = 1016  // Hero
        case "welcome_back": soundId = 1025 // Fanfare
        default:             soundId = 1000  // 기본 소리
        }
        AudioServicesPlaySystemSound(soundId)
    }

    func stop() {
        audioPlayer?.stop()
    }
}
