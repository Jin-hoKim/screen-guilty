import SwiftUI

/// 메뉴바 드롭다운 뷰
struct MenuBarView: View {
    @ObservedObject var appState: AppState
    @Environment(\.openWindow) var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 상단 상태 요약
            statusSection

            Divider().padding(.vertical, 4)

            // 통계
            statsSection

            Divider().padding(.vertical, 4)

            // 설정 메뉴
            settingsSection

            Divider().padding(.vertical, 4)

            // 리포트
            reportSection

            Divider().padding(.vertical, 4)

            // 종료
            Button("ScreenGuilty 종료") {
                NSApplication.shared.terminate(nil)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .frame(minWidth: 220)
        .padding(.vertical, 6)
    }

    // MARK: - 상태 섹션
    private var statusSection: some View {
        HStack(spacing: 10) {
            Text(appState.currentEmotion.emoji)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(appState.isDistracted ? "딴짓 중..." : "열심히 일하는 중")
                    .font(.headline)
                    .foregroundColor(appState.isDistracted ? .red : .green)

                if !appState.currentAppName.isEmpty {
                    Text(appState.currentAppName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - 통계 섹션
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            statRow(label: "오늘의 딴짓 시간", value: appState.statsStore.today.formattedDistractionTime, color: .red)
            statRow(label: "오늘의 업무 시간", value: appState.statsStore.today.formattedProductiveTime, color: .green)
            statRow(
                label: "생산성 점수",
                value: "\(appState.statsStore.today.productivityScore)%",
                color: productivityColor
            )
        }
        .padding(.horizontal, 12)
    }

    private func statRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding(.vertical, 2)
    }

    private var productivityColor: Color {
        let score = appState.statsStore.today.productivityScore
        if score >= 70 { return .green }
        if score >= 40 { return .orange }
        return .red
    }

    // MARK: - 설정 섹션
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            menuButton(title: "앱 분류 설정", icon: "list.bullet") {
                appState.showSettings = true
            }

            // 사운드 토글
            Button {
                appState.isSoundEnabled.toggle()
            } label: {
                HStack {
                    Image(systemName: appState.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .frame(width: 18)
                    Text(appState.isSoundEnabled ? "사운드 ON" : "사운드 OFF")
                    Spacer()
                    if appState.isSoundEnabled {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            menuButton(title: "캐릭터 크기 설정", icon: "slider.horizontal.3") {
                appState.showSettings = true
            }
        }
    }

    // MARK: - 리포트 섹션
    private var reportSection: some View {
        menuButton(title: "일일 리포트 보기", icon: "chart.bar.fill") {
            appState.showDailyReport = true
        }
    }

    // MARK: - 공통 메뉴 버튼
    private func menuButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 18)
                Text(title)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
