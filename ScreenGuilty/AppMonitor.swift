import AppKit
import Foundation

/// NSWorkspace를 이용한 앱 활성화 감지
@MainActor
class AppMonitor {
    private weak var appState: AppState?
    private var observer: Any?

    init(appState: AppState) {
        self.appState = appState
    }

    /// 감지 시작
    func start() {
        // .app 번들로 실행되지 않은 경우 (Xcode 디버그 직접 실행 등) NSWorkspace 접근 시
        // bundleProxyForCurrentProcess가 nil이어서 NSException 크래시 발생
        // Bundle.main.bundleURL은 CFBundle 레벨에서 직접 읽으므로 bundleProxy 없이 안전
        let bundleURL = Bundle.main.bundleURL
        guard bundleURL.pathExtension == "app" else {
            print("[AppMonitor] .app 번들로 실행되지 않음 (bundleURL: \(bundleURL.path)). NSWorkspace 모니터링 비활성화.")
            return
        }

        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor [weak self] in
                self?.handleNotification(notification)
            }
        }

        // Dock 위치 변경 감지
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { _ in
            NotificationCenter.default.post(
                name: .dockPositionChanged,
                object: nil
            )
        }
    }

    /// 감지 중지
    func stop() {
        if let observer {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
        observer = nil
    }

    private func handleNotification(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
            return
        }

        let bundleId = app.bundleIdentifier ?? ""
        let appName = app.localizedName ?? bundleId

        // ScreenGuilty 자신은 무시
        guard bundleId != Bundle.main.bundleIdentifier else { return }

        appState?.handleAppActivated(bundleId: bundleId, appName: appName)
    }
}

// MARK: - Notification 이름 확장
extension Notification.Name {
    static let dockPositionChanged = Notification.Name("dockPositionChanged")
}
