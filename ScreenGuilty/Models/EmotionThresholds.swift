import Foundation

/// 감정 변화 임계 시간 (초)
struct EmotionThresholds {
    var disappointed: Int  // 실망까지 (기본 120초 = 2분)
    var sad: Int           // 슬픔까지 (기본 300초 = 5분)
    var crying: Int        // 울기까지 (기본 900초 = 15분)
    var angry: Int         // 분노까지 (기본 1800초 = 30분)

    static let defaults = EmotionThresholds(
        disappointed: 120,
        sad: 300,
        crying: 900,
        angry: 1800
    )

    func save() {
        UserDefaults.standard.set(disappointed, forKey: "threshold_disappointed")
        UserDefaults.standard.set(sad, forKey: "threshold_sad")
        UserDefaults.standard.set(crying, forKey: "threshold_crying")
        UserDefaults.standard.set(angry, forKey: "threshold_angry")
    }

    static func load() -> EmotionThresholds {
        let d = UserDefaults.standard
        return EmotionThresholds(
            disappointed: d.integer(forKey: "threshold_disappointed").nonZero ?? 120,
            sad: d.integer(forKey: "threshold_sad").nonZero ?? 300,
            crying: d.integer(forKey: "threshold_crying").nonZero ?? 900,
            angry: d.integer(forKey: "threshold_angry").nonZero ?? 1800
        )
    }
}

private extension Int {
    var nonZero: Int? { self == 0 ? nil : self }
}
