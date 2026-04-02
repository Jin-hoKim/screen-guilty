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
            Button("Quit ScreenGuilty") {
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
                Text(appState.isDistracted ? "Slacking off..." : "Working hard")
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
            statRow(label: "Distraction Time", value: appState.statsStore.today.formattedDistractionTime, color: .red)
            statRow(label: "Productive Time", value: appState.statsStore.today.formattedProductiveTime, color: .green)
            statRow(
                label: "Productivity Score",
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
            menuButton(title: "Settings", icon: "gearshape.fill") {
                openWindow(id: "settings")
            }
        }
    }

    // MARK: - 리포트 섹션
    private var reportSection: some View {
        menuButton(title: "View Daily Report", icon: "chart.bar.fill") {
            openWindow(id: "daily-report")
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
