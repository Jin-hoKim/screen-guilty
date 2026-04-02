import Foundation

/// 캐릭터 감정 단계
enum EmotionLevel: String, CaseIterable, Codable {
    case peaceful       // 평화 (0~2분)
    case disappointed   // 살짝 실망 (2~5분)
    case sad            // 슬픔 (5~15분)
    case crying         // 울기 (15~30분)
    case angry          // 분노 (30분+)
    case smile          // 미소 (복귀 - 1~2단계에서)
    case excited        // 환호 (복귀 - 3~5단계에서)

    /// Lottie 애니메이션 파일명
    var animationName: String { rawValue }

    /// SF Symbols 폴백 아이콘
    var sfSymbol: String {
        switch self {
        case .peaceful: return "face.smiling"
        case .disappointed: return "face.smiling.inverse"
        case .sad: return "drop.fill"
        case .crying: return "cloud.rain.fill"
        case .angry: return "flame.fill"
        case .smile: return "face.smiling.fill"
        case .excited: return "star.fill"
        }
    }

    /// 메뉴바 이모지 표정
    var emoji: String {
        switch self {
        case .peaceful: return "😊"
        case .disappointed: return "😔"
        case .sad: return "😢"
        case .crying: return "😭"
        case .angry: return "😡"
        case .smile: return "😄"
        case .excited: return "🎉"
        }
    }

    /// 딴짓 시간(초) → 감정 단계
    static func from(distractionSeconds: Int) -> EmotionLevel {
        switch distractionSeconds {
        case 0..<120:    return .peaceful       // 0~2분
        case 120..<300:  return .disappointed   // 2~5분
        case 300..<900:  return .sad            // 5~15분
        case 900..<1800: return .crying         // 15~30분
        default:          return .angry          // 30분+
        }
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
        case .peaceful: return nil
        case .disappointed: return "sigh"
        case .sad: return "sob"
        case .crying: return "sob"
        case .angry: return "angry"
        case .smile: return nil
        case .excited: return "cheer"
        }
    }
}
