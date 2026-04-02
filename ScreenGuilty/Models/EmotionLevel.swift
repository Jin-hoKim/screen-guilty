import Foundation

/// 캐릭터 감정 단계
enum EmotionLevel: String, CaseIterable, Codable {
    case working        // 업무 중
    case peaceful       // 평화 (딴짓 0~2분)
    case disappointed   // 살짝 실망 (2~5분)
    case sad            // 슬픔 (5~15분)
    case crying         // 울기 (15~30분)
    case angry          // 분노 (30분+)
    case smile          // 미소 (복귀 - 가벼운)
    case excited        // 환호 (복귀 - 딴짓 오래 후)

    /// Lottie 애니메이션 파일명
    var animationName: String { rawValue }

    /// SF Symbols 폴백 아이콘
    var sfSymbol: String {
        switch self {
        case .working: return "laptopcomputer"
        case .peaceful: return "face.smiling"
        case .disappointed: return "face.smiling.inverse"
        case .sad: return "drop.fill"
        case .crying: return "cloud.rain.fill"
        case .angry: return "flame.fill"
        case .smile: return "face.smiling.fill"
        case .excited: return "star.fill"
        }
    }

    /// SF Symbols 아이콘명
    var iconName: String {
        switch self {
        case .working:      return "laptopcomputer"
        case .peaceful:     return "face.smiling"
        case .disappointed: return "face.smiling.inverse"
        case .sad:          return "cloud.drizzle"
        case .crying:       return "cloud.rain"
        case .angry:        return "flame"
        case .smile:        return "hand.thumbsup"
        case .excited:      return "star.fill"
        }
    }

    /// 딴짓 시간(초) → 감정 단계 (설정된 임계값 기반)
    static func from(distractionSeconds: Int) -> EmotionLevel {
        let t = EmotionThresholds.load()
        if distractionSeconds < t.disappointed { return .peaceful }
        if distractionSeconds < t.sad { return .disappointed }
        if distractionSeconds < t.crying { return .sad }
        if distractionSeconds < t.angry { return .crying }
        return .angry
    }

    /// 복귀 시 감정 (이전 딴짓 단계 기반)
    static func returnEmotion(from previous: EmotionLevel) -> EmotionLevel {
        switch previous {
        case .peaceful, .disappointed:
            return .smile
        case .sad, .crying, .angry:
            return .excited
        default:
            return .smile
        }
    }

    /// 재생할 사운드 파일명 (nil이면 사운드 없음)
    var soundName: String? {
        switch self {
        case .working:      return "working"
        case .peaceful:     return "peaceful"
        case .disappointed: return "sigh"
        case .sad:          return "sad"
        case .crying:       return "crying"
        case .angry:        return "angry"
        case .smile:        return "welcome_back"
        case .excited:      return "cheer"
        }
    }
}
