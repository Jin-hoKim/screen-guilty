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

        // NSWorkspace는 applicationDidFinishLaunching 이후에만 접근 가능
        // init()에서 접근 시 "bundleProxyForCurrentProcess is nil" 크래시 발생
        let monitor = AppMonitor(appState: state)
        self.appMonitor = monitor
        monitor.start()

        // 타이머 시작
        state.startTimer()

        // 일일 리포트 알림 스케줄
        DailyReportScheduler.scheduleNotification()

        // 캐릭터 패널 초기화 (NSPanel은 NSApplication 초기화 이후 생성)
        let panel = CharacterPanel(appState: state)
        panelHolder.panel = panel
        panel.orderFront(nil)
    }

    func applicationWillTerminate(_ notification: Notification) {
        // 앱 종료 시 오늘 통계 저장
        AppState.shared.statsStore.save()
    }
}

/// ScreenGuilty 앱 진입점
@main
struct ScreenGuiltyApp: App {
    @StateObject private var appState = AppState.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // 메뉴바 앱
        MenuBarExtra {
            MenuBarView(appState: appState)
        } label: {
            // 메뉴바 아이콘: 현재 감정 이모지
            Text(appState.currentEmotion.emoji)
                .font(.body)
        }
        .menuBarExtraStyle(.window)

        // 설정 창
        Window("설정", id: "settings") {
            SettingsView(appState: appState)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 520, height: 420)
        .keyboardShortcut(",", modifiers: .command)

        // 일일 리포트 창
        Window("일일 리포트", id: "daily-report") {
            DailyReportView(appState: appState)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 380, height: 520)
    }
}
