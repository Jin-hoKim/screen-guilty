import Foundation
import AppKit
import Combine

/// 앱 전역 상태 (ObservableObject)
@MainActor
class AppState: ObservableObject {
    static let shared = AppState()

    // MARK: - 감정/딴짓 상태
    @Published var currentEmotion: EmotionLevel = .peaceful
    @Published var distractionSeconds: Int = 0      // 현재 세션 딴짓 시간(초)
    @Published var productiveSeconds: Int = 0       // 오늘 업무 시간(초)
    @Published var isDistracted: Bool = false        // 현재 딴짓 중 여부
    @Published var currentAppName: String = ""       // 현재 활성 앱 이름
    @Published var currentBundleId: String = ""      // 현재 활성 앱 bundleId

    // MARK: - 설정
    @Published var isSoundEnabled: Bool {
        didSet { UserDefaults.standard.set(isSoundEnabled, forKey: "soundEnabled") }
    }
    @Published var characterSize: CharacterSize {
        didSet { UserDefaults.standard.set(characterSize.rawValue, forKey: "characterSize") }
    }
    @Published var distractionThresholdMinutes: Int {
        didSet { UserDefaults.standard.set(distractionThresholdMinutes, forKey: "distractionThreshold") }
    }
    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin")
            updateLoginItem()
        }
    }
    @Published var customCategories: [AppCategory] = []

    // MARK: - UI 상태
    @Published var showSettings: Bool = false
    @Published var showDailyReport: Bool = false
    @Published var isCharacterVisible: Bool = true

    // MARK: - 타이머
    private var timer: Timer?
    private var returnEmotionTimer: Timer?

    // MARK: - 통계
    let statsStore = UsageStatsStore.shared

    // MARK: - 앱 카테고리 맵
    private(set) var categoryMap: [String: AppCategoryType] = [:]

    init() {
        // 설정 불러오기
        self.isSoundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        let sizeRaw = UserDefaults.standard.string(forKey: "characterSize") ?? CharacterSize.medium.rawValue
        self.characterSize = CharacterSize(rawValue: sizeRaw) ?? .medium
        self.distractionThresholdMinutes = UserDefaults.standard.integer(forKey: "distractionThreshold").nonZero
        self.launchAtLogin = UserDefaults.standard.bool(forKey: "launchAtLogin")

        // 커스텀 카테고리 불러오기
        loadCustomCategories()
        buildCategoryMap()
    }

    // MARK: - 앱 분류 맵 빌드
    func buildCategoryMap() {
        var map: [String: AppCategoryType] = [:]

        // 기본 분류
        for app in DefaultAppCategories.all {
            map[app.id] = app.category
        }

        // 커스텀 분류 덮어쓰기
        for app in customCategories {
            map[app.id] = app.category
        }

        categoryMap = map
    }

    // MARK: - 앱 카테고리 조회
    func category(for bundleId: String) -> AppCategoryType {
        return categoryMap[bundleId] ?? .ignored
    }

    // MARK: - 타이머 시작/정지
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - 1초마다 시간 누적
    private func tick() {
        if isDistracted {
            distractionSeconds += 1
            statsStore.addDistractionTime(seconds: 1, bundleId: currentBundleId, appName: currentAppName)

            // 감정 업데이트
            let newEmotion = EmotionLevel.from(distractionSeconds: distractionSeconds)
            if newEmotion != currentEmotion && !isReturnEmotion(currentEmotion) {
                let previous = currentEmotion
                currentEmotion = newEmotion
                onEmotionChanged(from: previous, to: newEmotion)
            }
        } else {
            productiveSeconds += 1
            statsStore.addProductiveTime(seconds: 1)
        }
    }

    // MARK: - 앱 전환 처리
    func handleAppActivated(bundleId: String, appName: String) {
        let cat = category(for: bundleId)
        currentBundleId = bundleId
        currentAppName = appName

        let previousEmotion = currentEmotion

        switch cat {
        case .distraction:
            if !isDistracted {
                // 딴짓 시작
                isDistracted = true
            }
        case .productive:
            if isDistracted {
                // 업무 복귀
                isDistracted = false
                let returnEmotion = EmotionLevel.returnEmotion(from: previousEmotion)
                currentEmotion = returnEmotion

                // 복귀 감정은 3초 후 평화로운 상태로 돌아가기
                returnEmotionTimer?.invalidate()
                returnEmotionTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                    Task { @MainActor [weak self] in
                        self?.currentEmotion = .peaceful
                        self?.distractionSeconds = 0
                    }
                }

                // 복귀 사운드
                if isSoundEnabled {
                    SoundPlayer.shared.play(emotion: returnEmotion)
                }
            }
        case .ignored:
            break
        }
    }

    // MARK: - 감정 변화 처리
    private func onEmotionChanged(from previous: EmotionLevel, to new: EmotionLevel) {
        // 사운드 재생
        if isSoundEnabled {
            SoundPlayer.shared.play(emotion: new)
        }
    }

    private func isReturnEmotion(_ emotion: EmotionLevel) -> Bool {
        emotion == .smile || emotion == .excited
    }

    // MARK: - 커스텀 카테고리
    func updateCategory(bundleId: String, appName: String, category: AppCategoryType) {
        if let idx = customCategories.firstIndex(where: { $0.id == bundleId }) {
            customCategories[idx].category = category
        } else {
            customCategories.append(AppCategory(bundleId: bundleId, name: appName, category: category))
        }
        saveCustomCategories()
        buildCategoryMap()
    }

    private func saveCustomCategories() {
        if let data = try? JSONEncoder().encode(customCategories) {
            UserDefaults.standard.set(data, forKey: "customCategories")
        }
    }

    private func loadCustomCategories() {
        if let data = UserDefaults.standard.data(forKey: "customCategories"),
           let categories = try? JSONDecoder().decode([AppCategory].self, from: data) {
            customCategories = categories
        }
    }

    // MARK: - 로그인 시 자동 시작
    private func updateLoginItem() {
        // SMAppService는 macOS 13+에서 사용
        // 실제 구현은 SMAppService.mainApp.register() 사용
    }
}

// MARK: - 캐릭터 크기 설정
enum CharacterSize: String, CaseIterable {
    case small  = "small"   // 60px
    case medium = "medium"  // 80px
    case large  = "large"   // 120px

    var pixels: CGFloat {
        switch self {
        case .small:  return 60
        case .medium: return 80
        case .large:  return 120
        }
    }

    var displayName: String {
        switch self {
        case .small:  return "작게 (60px)"
        case .medium: return "보통 (80px)"
        case .large:  return "크게 (120px)"
        }
    }
}

// MARK: - Int 헬퍼
private extension Int {
    var nonZero: Int { self == 0 ? 2 : self }
}
