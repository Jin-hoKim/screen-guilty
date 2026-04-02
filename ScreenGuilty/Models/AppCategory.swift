import Foundation

/// 앱 분류 종류
enum AppCategoryType: String, Codable, CaseIterable {
    case distraction = "distraction"  // 딴짓
    case productive  = "productive"   // 업무
    case ignored     = "ignored"      // 무시

    var displayName: String {
        switch self {
        case .distraction: return "Distraction"
        case .productive:  return "Productive"
        case .ignored:     return "Ignored"
        }
    }
}

/// 앱 분류 항목
struct AppCategory: Codable, Identifiable, Equatable {
    let id: String      // bundleIdentifier
    var name: String    // 앱 표시명
    var category: AppCategoryType

    init(bundleId: String, name: String, category: AppCategoryType) {
        self.id = bundleId
        self.name = name
        self.category = category
    }
}

/// 기본 앱 분류 데이터
enum DefaultAppCategories {
    static let distractionApps: [AppCategory] = [
        AppCategory(bundleId: "com.google.Chrome",         name: "Google Chrome",  category: .distraction),
        AppCategory(bundleId: "com.apple.Safari",          name: "Safari",         category: .distraction),
        AppCategory(bundleId: "com.tinyspeck.slackmacgap", name: "Slack",          category: .distraction),
        AppCategory(bundleId: "tv.twitch.desktop",         name: "Twitch",         category: .distraction),
        AppCategory(bundleId: "com.spotify.client",        name: "Spotify",        category: .distraction),
        AppCategory(bundleId: "com.valvesoftware.steam",   name: "Steam",          category: .distraction),
        AppCategory(bundleId: "com.apple.TV",              name: "Apple TV",       category: .distraction),
        AppCategory(bundleId: "com.apple.Music",           name: "Apple Music",    category: .distraction),
        AppCategory(bundleId: "us.zoom.xos",               name: "Zoom",           category: .distraction),
        AppCategory(bundleId: "com.naver.now",             name: "NAVER NOW",      category: .distraction),
        AppCategory(bundleId: "com.kakao.KakaoTalkMac",    name: "KakaoTalk",      category: .distraction),
    ]

    static let productiveApps: [AppCategory] = [
        AppCategory(bundleId: "com.apple.dt.Xcode",      name: "Xcode",         category: .productive),
        AppCategory(bundleId: "com.microsoft.VSCode",    name: "VS Code",       category: .productive),
        AppCategory(bundleId: "com.sublimetext.4",        name: "Sublime Text",  category: .productive),
        AppCategory(bundleId: "com.apple.Terminal",      name: "Terminal",      category: .productive),
        AppCategory(bundleId: "com.apple.finder",        name: "Finder",        category: .productive),
        AppCategory(bundleId: "com.apple.Notes",         name: "Notes",         category: .productive),
        AppCategory(bundleId: "com.apple.Pages",         name: "Pages",         category: .productive),
        AppCategory(bundleId: "com.apple.Numbers",       name: "Numbers",       category: .productive),
        AppCategory(bundleId: "com.apple.Keynote",       name: "Keynote",       category: .productive),
        AppCategory(bundleId: "com.microsoft.Word",      name: "Microsoft Word",  category: .productive),
        AppCategory(bundleId: "com.microsoft.Excel",     name: "Microsoft Excel", category: .productive),
        AppCategory(bundleId: "com.figma.Desktop",       name: "Figma",         category: .productive),
        AppCategory(bundleId: "com.jetbrains.intellij",  name: "IntelliJ IDEA", category: .productive),
        AppCategory(bundleId: "com.todesktop.230313mzl4w4u92", name: "Cursor",  category: .productive),
    ]

    static var all: [AppCategory] {
        distractionApps + productiveApps
    }
}
