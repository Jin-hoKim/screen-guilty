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
            return "Almost no slacking today! Perfect day."
        } else if distractionSeconds < 1800 {
            // 30분 미만
            return "You slacked for \(distractionMinutes) minutes today. Not bad!"
        } else if distractionHours < 2 {
            return "You slacked for \(distractionMinutes > 0 ? "\(distractionHours)h \(distractionMinutes)m" : "\(distractionHours)h") today. Try harder tomorrow!"
        } else {
            return "You slacked for \(distractionHours) hours today... Let's try harder tomorrow!"
        }
    }

    /// 날짜 포맷
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US")
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
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }
}
