import SwiftUI
import ServiceManagement

/// 설정 화면
struct SettingsView: View {
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        TabView {
            GeneralSettingsTab(appState: appState)
                .tabItem {
                    Label("일반", systemImage: "gearshape")
                }

            AppClassificationView(appState: appState)
                .tabItem {
                    Label("앱 분류", systemImage: "list.bullet")
                }
        }
        .frame(width: 520, height: 420)
        .navigationTitle("ScreenGuilty 설정")
    }
}

// MARK: - 일반 설정 탭
struct GeneralSettingsTab: View {
    @ObservedObject var appState: AppState

    var body: some View {
        Form {
            // 캐릭터 크기
            Section("캐릭터") {
                Picker("크기", selection: $appState.characterSize) {
                    ForEach(CharacterSize.allCases, id: \.self) { size in
                        Text(size.displayName).tag(size)
                    }
                }
                .pickerStyle(.segmented)

                // 미리보기
                HStack {
                    Spacer()
                    EmojiCharacterView(emotion: appState.currentEmotion)
                        .frame(
                            width: appState.characterSize.pixels,
                            height: appState.characterSize.pixels
                        )
                    Spacer()
                }
                .padding(.vertical, 8)
            }

            // 사운드
            Section("사운드") {
                Toggle("사운드 활성화", isOn: $appState.isSoundEnabled)
            }

            // 딴짓 판정 임계값
            Section("딴짓 판정") {
                HStack {
                    Text("딴짓으로 판정되는 시간")
                    Spacer()
                    Stepper(
                        "\(appState.distractionThresholdMinutes)분",
                        value: $appState.distractionThresholdMinutes,
                        in: 1...30
                    )
                }
                Text("선택한 앱을 이 시간 이상 사용하면 딴짓으로 집계됩니다.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // 감정 변화 임계 시간
            Section("감정 변화 타이밍") {
                HStack {
                    Text("실망")
                    Spacer()
                    Stepper(
                        "\(appState.emotionThresholds.disappointed)초",
                        value: $appState.emotionThresholds.disappointed,
                        in: 5...300, step: 5
                    )
                }
                HStack {
                    Text("슬픔")
                    Spacer()
                    Stepper(
                        "\(appState.emotionThresholds.sad)초",
                        value: $appState.emotionThresholds.sad,
                        in: 10...600, step: 10
                    )
                }
                HStack {
                    Text("울기")
                    Spacer()
                    Stepper(
                        "\(appState.emotionThresholds.crying)초",
                        value: $appState.emotionThresholds.crying,
                        in: 30...1800, step: 30
                    )
                }
                HStack {
                    Text("분노")
                    Spacer()
                    Stepper(
                        "\(appState.emotionThresholds.angry)초",
                        value: $appState.emotionThresholds.angry,
                        in: 60...3600, step: 60
                    )
                }
                Text("딴짓 시작 후 각 감정으로 변하는 시간을 설정합니다.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // 시작 프로그램
            Section("시스템") {
                Toggle("로그인 시 자동 시작", isOn: $appState.launchAtLogin)

                Toggle("캐릭터 표시", isOn: $appState.isCharacterVisible)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
