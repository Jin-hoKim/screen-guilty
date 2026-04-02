import SwiftUI
import AppKit

/// 캐릭터 패널 홀더 (참조 타입)
private class CharacterPanelHolder {
    var panel: CharacterPanel?
}

/// 앱 델리게이트 — NSApplication 완전 초기화 이후 NSWorkspace 접근 보장
@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private let panelHolder = CharacterPanelHolder()
    private var appMonitor: AppMonitor?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let state = AppState.shared

        let monitor = AppMonitor(appState: state)
        self.appMonitor = monitor

        // 타이머 시작
        state.startTimer()

        // 일일 리포트 알림 스케줄
        DailyReportScheduler.scheduleNotification()

        // 캐릭터 패널 초기화 (NSPanel은 NSApplication 초기화 이후 생성)
        let panel = CharacterPanel(appState: state)
        panelHolder.panel = panel
        panel.orderFront(nil)

        // NSWorkspace.shared 접근은 다음 런루프 사이클로 반드시 지연해야 한다.
        // applicationDidFinishLaunching 동기 실행 중에는 Xcode 디버그 실행 환경에서
        // bundleProxyForCurrentProcess 초기화가 완료되지 않아 NSException이 발생한다.
        // DispatchQueue.main.async로 감싸면 첫 런루프 이벤트 처리 후 실행되어 안전하다.
        DispatchQueue.main.async {
            monitor.start()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        // 앱 종료 시 오늘 통계 저장
        AppState.shared.statsStore.save()
    }
}

/// ScreenGuilty 앱 진입점 (@main은 main.swift에서 호출)
struct ScreenGuiltyApp: App {
    @StateObject private var appState = AppState.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // 메뉴바 앱
        MenuBarExtra {
            MenuBarView(appState: appState)
        } label: {
            Image(systemName: "sunglasses.fill")
        }
        .menuBarExtraStyle(.window)

        // 설정 창
        Window("Settings", id: "settings") {
            SettingsView(appState: appState)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 520, height: 580)
        .keyboardShortcut(",", modifiers: .command)

        // 일일 리포트 창
        Window("Daily Report", id: "daily-report") {
            DailyReportView(appState: appState)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 380, height: 520)
    }
}
