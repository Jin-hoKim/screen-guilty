import Foundation

/// 앱별 사용 시간 기록
struct AppUsageRecord: Codable, Identifiable {
    let id: String          // bundleIdentifier
    var name: String        // 앱 표시명
    var totalSeconds: Int   // 총 사용 시간(초)

    var formattedTime: String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        if hours > 0 {
            return "\(hours)시간 \(minutes)분"
        } else {
            return "\(minutes)분"
        }
    }
}

/// 하루 사용 통계
struct DailyUsageStats: Codable {
    var date: Date
    var distractionSeconds: Int = 0
    var productiveSeconds: Int = 0
    var appRecords: [AppUsageRecord] = []

    /// 생산성 점수 (0~100)
    var productivityScore: Int {
        let total = distractionSeconds + productiveSeconds
        guard total > 0 else { return 100 }
        return Int(Double(productiveSeconds) / Double(total) * 100)
    }

    /// 딴짓 상위 3개 앱
    var topDistractionApps: [AppUsageRecord] {
        appRecords
            .sorted { $0.totalSeconds > $1.totalSeconds }
            .prefix(3)
            .map { $0 }
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

    /// 앱 사용 시간 업데이트
    mutating func addSeconds(_ seconds: Int, bundleId: String, appName: String) {
        if let idx = appRecords.firstIndex(where: { $0.id == bundleId }) {
            appRecords[idx].totalSeconds += seconds
        } else {
            appRecords.append(AppUsageRecord(id: bundleId, name: appName, totalSeconds: seconds))
        }
    }
}

/// 통계 저장소 (UserDefaults + JSON)
class UsageStatsStore: ObservableObject {
    static let shared = UsageStatsStore()

    @Published var today: DailyUsageStats

    private let userDefaults = UserDefaults.standard
    private let todayKey: String = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "stats_\(formatter.string(from: Date()))"
    }()

    init() {
        // 오늘 날짜 키로 저장된 통계 불러오기
        if let data = UserDefaults.standard.data(forKey: {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return "stats_\(formatter.string(from: Date()))"
        }()),
           let stats = try? JSONDecoder().decode(DailyUsageStats.self, from: data) {
            self.today = stats
        } else {
            self.today = DailyUsageStats(date: Date())
        }
    }

    /// 딴짓 시간 추가
    func addDistractionTime(seconds: Int, bundleId: String, appName: String) {
        today.distractionSeconds += seconds
        today.addSeconds(seconds, bundleId: bundleId, appName: appName)
        save()
    }

    /// 업무 시간 추가
    func addProductiveTime(seconds: Int) {
        today.productiveSeconds += seconds
        save()
    }

    /// 저장
    func save() {
        if let data = try? JSONEncoder().encode(today) {
            userDefaults.set(data, forKey: todayKey)
        }
        objectWillChange.send()
    }

    /// 특정 날짜 통계 불러오기
    func stats(for date: Date) -> DailyUsageStats? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let key = "stats_\(formatter.string(from: date))"
        guard let data = userDefaults.data(forKey: key),
              let stats = try? JSONDecoder().decode(DailyUsageStats.self, from: data) else {
            return nil
        }
        return stats
    }
}
