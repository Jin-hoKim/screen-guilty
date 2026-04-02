import Foundation

/// 감정 엔진 — 딴짓 시간 → 감정 단계 계산 및 전환 관리
class EmotionEngine {
    private weak var appState: AppState?
    private weak var characterPanel: CharacterPanel?
    private weak var soundPlayer: SoundPlayer?

    init(appState: AppState) {
        self.appState = appState
    }

    // MARK: - 감정 업데이트
    @MainActor
    func update(distractionSeconds: Int, isDistracted: Bool) {
        guard isDistracted else { return }
        let newEmotion = EmotionLevel.from(distractionSeconds: distractionSeconds)

        // 현재와 다른 감정이 되었을 때만 업데이트
        guard let appState = appState,
              newEmotion != appState.currentEmotion else { return }

        let previous = appState.currentEmotion
        appState.currentEmotion = newEmotion

        onEmotionChanged(from: previous, to: newEmotion)
    }

    // MARK: - 감정 변화 처리
    @MainActor
    private func onEmotionChanged(from previous: EmotionLevel, to new: EmotionLevel) {
        guard let appState = appState else { return }

        // 사운드 재생
        if appState.isSoundEnabled, let soundName = new.soundName {
            SoundPlayer.shared.play(soundName: soundName)
        }

        // 캐릭터 오버레이 업데이트는 AppState 변경으로 자동 처리
    }

    // MARK: - 복귀 감정 처리
    @MainActor
    func handleReturn(from previousEmotion: EmotionLevel) {
        guard let appState = appState else { return }
        let returnEmotion = EmotionLevel.returnEmotion(from: previousEmotion)
        appState.currentEmotion = returnEmotion

        // 복귀 사운드
        if appState.isSoundEnabled {
            SoundPlayer.shared.play(emotion: returnEmotion)
        }
    }
}
