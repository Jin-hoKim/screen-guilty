import Foundation

/// 일일 죄책감 리포트
struct DailyReport: Codable, Identifiable {
    let id: UUID
    let date: Date
    let distractionSeconds: Int
    let productiveSeconds: Int
    let topApps: [AppUsageRecord]
    let productivityScore: Int

    init(from stats: DailyUsageStats) {
        self.id = UUID()
        self.date = stats.date
        self.distractionSeconds = stats.distractionSeconds
        self.productiveSeconds = stats.productiveSeconds
        self.topApps = stats.topDistractionApps
        self.productivityScore = stats.productivityScore
    }

    /// 격려/죄책감 메시지
    var guiltyMessage: String {
        let distractionHours = distractionSeconds / 3600
        let distractionMinutes = (distractionSeconds % 3600) / 60

        if distractionSeconds < 60 {
            return "오늘 거의 딴짓을 안 했어요! 완벽한 하루였습니다. 👏"
        } else if distractionSeconds < 1800 {
            // 30분 미만
            return "오늘 \(distractionMinutes)분 딴짓했습니다. 꽤 집중했네요!"
        } else if distractionHours < 2 {
            return "오늘 \(distractionMinutes > 0 ? "\(distractionHours)시간 \(distractionMinutes)분" : "\(distractionHours)시간") 딴짓했습니다. 내일은 더 열심히! 💪"
        } else {
            return "오늘 \(distractionHours)시간 딴짓했습니다... 내일은 진짜로 열심히 해봐요! 😅"
        }
    }

    /// 날짜 포맷
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

    /// 딴짓 시간 포맷
    var formattedDistractionTime: String {
        formatSeconds(distractionSeconds)
    }

    /// 업무 시간 포맷
    var formattedProductiveTime: String {
        formatSeconds(productiveSeconds)
    }

    private func formatSeconds(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        } else if minutes > 0 {
            return "\(minutes)분"
        } else {
            return "\(seconds)초"
        }
    }
}
