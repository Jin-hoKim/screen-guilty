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
                    Label("General", systemImage: "gearshape")
                }

            AppClassificationView(appState: appState)
                .tabItem {
                    Label("App Classification", systemImage: "list.bullet")
                }
        }
        .frame(width: 520, height: 420)
        .navigationTitle("ScreenGuilty Settings")
    }
}

// MARK: - 일반 설정 탭
struct GeneralSettingsTab: View {
    @ObservedObject var appState: AppState

    var body: some View {
        Form {
            // 캐릭터 크기
            Section("Character") {
                Picker("Size", selection: $appState.characterSize) {
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
            Section("Sound") {
                Toggle("Enable Sound", isOn: $appState.isSoundEnabled)
            }

            // 딴짓 판정 임계값
            Section("Distraction Detection") {
                HStack {
                    Text("Time before counting as distraction")
                    Spacer()
                    Stepper(
                        "\(appState.distractionThresholdMinutes) min",
                        value: $appState.distractionThresholdMinutes,
                        in: 1...30
                    )
                }
                Text("Usage exceeding this time will be counted as distraction.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // 감정 변화 임계 시간
            Section("Emotion Timing") {
                HStack {
                    Text("Disappointed")
                    Spacer()
                    Stepper(
                        "\(appState.emotionThresholds.disappointed)s",
                        value: $appState.emotionThresholds.disappointed,
                        in: 5...300, step: 5
                    )
                }
                HStack {
                    Text("Sad")
                    Spacer()
                    Stepper(
                        "\(appState.emotionThresholds.sad)s",
                        value: $appState.emotionThresholds.sad,
                        in: 10...600, step: 10
                    )
                }
                HStack {
                    Text("Crying")
                    Spacer()
                    Stepper(
                        "\(appState.emotionThresholds.crying)s",
                        value: $appState.emotionThresholds.crying,
                        in: 30...1800, step: 30
                    )
                }
                HStack {
                    Text("Angry")
                    Spacer()
                    Stepper(
                        "\(appState.emotionThresholds.angry)s",
                        value: $appState.emotionThresholds.angry,
                        in: 60...3600, step: 60
                    )
                }
                Text("Set the time for each emotion change after distraction starts.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // 시작 프로그램
            Section("System") {
                Toggle("Launch at Login", isOn: $appState.launchAtLogin)

                Toggle("Show Character", isOn: $appState.isCharacterVisible)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
