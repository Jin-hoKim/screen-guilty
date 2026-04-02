import SwiftUI
import AppKit

/// 앱 분류 설정 화면
struct AppClassificationView: View {
    @ObservedObject var appState: AppState
    @State private var searchText = ""
    @State private var selectedFilter: AppCategoryType? = nil
    @State private var installedApps: [InstalledApp] = []
    @State private var isLoadingApps = false

    var body: some View {
        VStack(spacing: 0) {
            // 검색 + 필터
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("앱 검색...", text: $searchText)
                    .textFieldStyle(.plain)

                Picker("필터", selection: $selectedFilter) {
                    Text("전체").tag(AppCategoryType?.none)
                    ForEach(AppCategoryType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(AppCategoryType?.some(type))
                    }
                }
                .labelsHidden()
                .frame(width: 80)
            }
            .padding(10)
            .background(Color(NSColor.textBackgroundColor))

            Divider()

            if isLoadingApps {
                ProgressView("앱 목록 로딩 중...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredApps) { item in
                        AppClassificationRow(
                            app: item,
                            currentCategory: appState.category(for: item.bundleId),
                            onCategoryChange: { newCategory in
                                appState.updateCategory(
                                    bundleId: item.bundleId,
                                    appName: item.name,
                                    category: newCategory
                                )
                            }
                        )
                    }
                }
                .listStyle(.plain)
            }
        }
        .onAppear {
            loadInstalledApps()
        }
    }

    // MARK: - 필터된 앱 목록
    private var filteredApps: [InstalledApp] {
        var apps = installedApps

        // 텍스트 검색
        if !searchText.isEmpty {
            apps = apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        // 카테고리 필터
        if let filter = selectedFilter {
            apps = apps.filter { appState.category(for: $0.bundleId) == filter }
        }

        return apps.sorted { $0.name < $1.name }
    }

    // MARK: - 설치된 앱 로드
    private func loadInstalledApps() {
        isLoadingApps = true

        Task.detached(priority: .background) {
            var apps: [InstalledApp] = []

            // /Applications 및 ~/Applications에서 앱 찾기
            let directories = [
                URL(fileURLWithPath: "/Applications"),
                URL(fileURLWithPath: NSHomeDirectory() + "/Applications")
            ]

            for dir in directories {
                guard let contents = try? FileManager.default.contentsOfDirectory(
                    at: dir,
                    includingPropertiesForKeys: [.isApplicationKey],
                    options: [.skipsHiddenFiles]
                ) else { continue }

                for url in contents where url.pathExtension == "app" {
                    if let bundle = Bundle(url: url),
                       let bundleId = bundle.bundleIdentifier {
                        let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
                               ?? url.deletingPathExtension().lastPathComponent
                        apps.append(InstalledApp(bundleId: bundleId, name: name, url: url))
                    }
                }
            }

            // 기본 분류 앱도 추가
            let defaultApps = DefaultAppCategories.all
            for app in defaultApps {
                if !apps.contains(where: { $0.bundleId == app.id }) {
                    apps.append(InstalledApp(bundleId: app.id, name: app.name, url: nil))
                }
            }

            await MainActor.run {
                self.installedApps = apps
                self.isLoadingApps = false
            }
        }
    }
}

// MARK: - 앱 분류 행
struct AppClassificationRow: View {
    let app: InstalledApp
    let currentCategory: AppCategoryType
    let onCategoryChange: (AppCategoryType) -> Void

    var body: some View {
        HStack(spacing: 12) {
            // 앱 아이콘
            if let url = app.url, let icon = NSWorkspace.shared.icon(forFile: url.path) as NSImage? {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 32, height: 32)
            } else {
                Image(systemName: "app.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.secondary)
            }

            // 앱 이름
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.body)
                Text(app.bundleId)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // 분류 선택
            Picker("", selection: Binding(
                get: { currentCategory },
                set: { onCategoryChange($0) }
            )) {
                ForEach(AppCategoryType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .labelsHidden()
            .frame(width: 70)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 설치된 앱 모델
struct InstalledApp: Identifiable {
    var id: String { bundleId }
    let bundleId: String
    let name: String
    let url: URL?

    init(bundleId: String, name: String, url: URL?) {
        self.id = bundleId
        self.bundleId = bundleId
        self.name = name
        self.url = url
    }
}
