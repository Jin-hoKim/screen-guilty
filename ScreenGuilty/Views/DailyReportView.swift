import SwiftUI
import UserNotifications

/// 일일 죄책감 리포트 뷰
struct DailyReportView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var report: DailyReport {
        DailyReport(from: appState.statsStore.today)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            headerSection

            Divider()

            ScrollView {
                VStack(spacing: 20) {
                    // 생산성 점수 원형 차트
                    productivityCircle

                    // 시간 통계
                    timeStatsSection

                    // TOP 3 딴짓 앱
                    if !report.topApps.isEmpty {
                        topAppsSection
                    }

                    // 죄책감 메시지
                    guiltyMessageSection
                }
                .padding(20)
            }

            Divider()

            // 하단 버튼
            bottomButtons
        }
        .frame(width: 380, height: 520)
    }

    // MARK: - 헤더
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today's Guilt Report")
                    .font(.headline)
                Text(report.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button("Close") { dismiss() }
        }
        .padding(16)
    }

    // MARK: - 생산성 점수 원형
    private var productivityCircle: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                .frame(width: 120, height: 120)

            Circle()
                .trim(from: 0, to: CGFloat(report.productivityScore) / 100)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.green, .yellow, .orange]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("\(report.productivityScore)%")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Productivity")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - 시간 통계
    private var timeStatsSection: some View {
        HStack(spacing: 16) {
            statCard(
                title: "Productive Time",
                value: report.formattedProductiveTime,
                icon: "laptopcomputer",
                color: .green
            )
            statCard(
                title: "Distraction Time",
                value: report.formattedDistractionTime,
                icon: "gamecontroller.fill",
                color: .red
            )
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }

    // MARK: - TOP 딴짓 앱
    private var topAppsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Top \(report.topApps.count) Distractions")
                .font(.subheadline)
                .fontWeight(.semibold)

            ForEach(Array(report.topApps.enumerated()), id: \.offset) { idx, app in
                HStack {
                    Text("\(idx + 1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                        .background(Circle().fill(rankColor(idx)))

                    Text(app.name)
                        .font(.subheadline)

                    Spacer()

                    Text(app.formattedTime)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
        )
    }

    private func rankColor(_ idx: Int) -> Color {
        switch idx {
        case 0: return .yellow
        case 1: return Color(white: 0.7)
        default: return Color(red: 0.8, green: 0.5, blue: 0.2)
        }
    }

    // MARK: - 죄책감 메시지
    private var guiltyMessageSection: some View {
        Text(report.guiltyMessage)
            .font(.body)
            .multilineTextAlignment(.center)
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.yellow.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
            )
    }

    // MARK: - 하단 버튼
    private var bottomButtons: some View {
        HStack(spacing: 12) {
            Button {
                saveReportAsImage()
            } label: {
                Label("Save as Image", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(.bordered)

            Spacer()

            Button("OK") { dismiss() }
                .buttonStyle(.borderedProminent)
        }
        .padding(16)
    }

    // MARK: - 이미지 저장
    private func saveReportAsImage() {
        // 저장 다이얼로그
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.png]
        panel.nameFieldStringValue = "ScreenGuilty_Report_\(report.formattedDate).png"

        panel.begin { response in
            guard response == .OK, let _ = panel.url else { return }
            // TODO: NSView를 이미지로 렌더링하는 로직 추가
        }
    }
}

// MARK: - 일일 리포트 알림 스케줄러
class DailyReportScheduler {
    static func scheduleNotification() {
        // .app 번들로 실행되지 않은 경우 UNUserNotificationCenter 접근 시
        // bundleProxyForCurrentProcess nil 크래시 발생
        // Bundle.main.bundleURL은 CFBundle 레벨에서 읽으므로 bundleProxy 없이 안전
        guard Bundle.main.bundleURL.pathExtension == "app" else { return }

        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            guard granted else { return }

            let content = UNMutableNotificationContent()
            content.title = "Today's Guilt Report"
            content.body = "Check how you spent your day!"
            content.sound = .default

            // 매일 18:00에 알림
            var components = DateComponents()
            components.hour = 18
            components.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: "daily_report",
                content: content,
                trigger: trigger
            )

            center.add(request)
        }
    }
}
