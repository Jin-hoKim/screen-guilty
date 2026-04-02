import SwiftUI
import AppKit

/// ScreenGuilty 앱 진입점
@main
struct ScreenGuiltyApp: App {
    @StateObject private var appState = AppState.shared
    private var appMonitor: AppMonitor

    // NSPanel 기반 캐릭터 오버레이
    private var characterPanel: CharacterPanel?

    init() {
        let state = AppState.shared
        self.appMonitor = AppMonitor(appState: state)

        // 앱 감지 시작
        appMonitor.start()

        // 타이머 시작
        Task { @MainActor in
            state.startTimer()
        }

        // 일일 리포트 알림 스케줄
        DailyReportScheduler.scheduleNotification()

        // 캐릭터 패널 초기화
        Task { @MainActor in
            self.characterPanel = CharacterPanel(appState: state)
            self.characterPanel?.orderFront(nil)
        }
    }

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
