import AppKit
import SwiftUI

/// NSPanel 기반 캐릭터 오버레이 (Dock 위에 항상 표시)
class CharacterPanel: NSPanel {
    private var hostingView: NSHostingView<CharacterOverlayView>?
    private weak var appState: AppState?

    init(appState: AppState) {
        self.appState = appState
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 100, height: 100),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        self.level = .floating
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isMovableByWindowBackground = true
        self.acceptsMouseMovedEvents = true

        setupContent(appState: appState)
        positionAboveDock()
        setupDockObserver()
    }

    // MARK: - SwiftUI 컨텐츠 설정
    private func setupContent(appState: AppState) {
        let view = CharacterOverlayView(appState: appState)
        let hosting = NSHostingView(rootView: view)
        hosting.frame = self.contentView?.bounds ?? NSRect(x: 0, y: 0, width: 100, height: 100)
        hosting.autoresizingMask = [.width, .height]
        self.contentView = hosting
        self.hostingView = hosting
    }

    // MARK: - Dock 위치 감지 + 캐릭터 배치
    func positionAboveDock() {
        guard let screen = NSScreen.main else { return }
        let visibleFrame = screen.visibleFrame
        let fullFrame = screen.frame

        let size = appState?.characterSize.pixels ?? 80
        let panelSize = size + 20  // 여백 포함

        // Dock 위치 감지
        let dockOnBottom = visibleFrame.origin.y > fullFrame.origin.y + 5
        let dockOnLeft   = visibleFrame.origin.x > fullFrame.origin.x + 5
        let dockOnRight  = visibleFrame.maxX < fullFrame.maxX - 5

        var x: CGFloat
        var y: CGFloat

        if dockOnBottom {
            x = visibleFrame.midX - panelSize / 2
            y = visibleFrame.origin.y + 5
        } else if dockOnLeft {
            x = visibleFrame.origin.x + 5
            y = visibleFrame.midY - panelSize / 2
        } else if dockOnRight {
            x = visibleFrame.maxX - panelSize - 5
            y = visibleFrame.midY - panelSize / 2
        } else {
            // Dock 자동숨기기 → 화면 하단 중앙
            x = fullFrame.midX - panelSize / 2
            y = fullFrame.origin.y + 5
        }

        self.setFrame(NSRect(x: x, y: y, width: panelSize, height: panelSize), display: true)
    }

    // MARK: - Dock 위치 변경 감지
    private func setupDockObserver() {
        NotificationCenter.default.addObserver(
            forName: .dockPositionChanged,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.positionAboveDock()
        }
    }

    // MARK: - 창 클릭 가능하게
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}

// MARK: - 캐릭터 오버레이 SwiftUI 뷰
struct CharacterOverlayView: View {
    @ObservedObject var appState: AppState
    @State private var showTooltip: Bool = false
    @State private var isAngryShaking: Bool = false

    var body: some View {
        ZStack {
            characterView
                .frame(
                    width: appState.characterSize.pixels,
                    height: appState.characterSize.pixels
                )
                // 분노 단계 흔들기
                .rotationEffect(.degrees(isAngryShaking ? 5 : -5))
                .animation(
                    appState.currentEmotion == .angry
                        ? .easeInOut(duration: 0.1).repeatForever(autoreverses: true)
                        : .default,
                    value: isAngryShaking
                )
                // 감정 전환 애니메이션
                .transition(.scale.combined(with: .opacity))
                .animation(.easeInOut(duration: 0.5), value: appState.currentEmotion)
                .onTapGesture {
                    withAnimation { showTooltip.toggle() }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation { showTooltip = false }
                    }
                }

            if showTooltip {
                tooltipView
                    .transition(.opacity.combined(with: .scale))
                    .offset(y: -appState.characterSize.pixels / 2 - 30)
            }
        }
        .padding(10)
        .onChange(of: appState.currentEmotion) { _, newEmotion in
            isAngryShaking = (newEmotion == .angry)
        }
        .onAppear {
            isAngryShaking = (appState.currentEmotion == .angry)
        }
    }

    // MARK: - 캐릭터 뷰 (Lottie 또는 SF Symbols 폴백)
    @ViewBuilder
    private var characterView: some View {
        LottieCharacterView(emotionLevel: appState.currentEmotion)
    }

    // MARK: - 툴팁 (딴짓 시간 표시)
    private var tooltipView: some View {
        VStack(spacing: 2) {
            if appState.isDistracted {
                Text("딴짓 중: \(formatSeconds(appState.distractionSeconds))")
                    .font(.caption)
                    .fontWeight(.medium)
            } else {
                Text("업무 중 👍")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            Text(appState.currentAppName)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.regularMaterial)
                .shadow(radius: 3)
        )
        .frame(maxWidth: 160)
    }

    private func formatSeconds(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 { return "\(h)시간 \(m)분" }
        if m > 0 { return "\(m)분 \(s)초" }
        return "\(s)초"
    }
}

// MARK: - Lottie 캐릭터 뷰 (Lottie 없으면 SF Symbols로 폴백)
struct LottieCharacterView: View {
    let emotionLevel: EmotionLevel

    var body: some View {
        // Lottie 임포트가 가능하면 LottieView 사용, 없으면 SF Symbols 폴백
        EmojiCharacterView(emotion: emotionLevel)
    }
}

// MARK: - 이모지 기반 캐릭터 뷰 (폴백)
struct EmojiCharacterView: View {
    let emotion: EmotionLevel
    @State private var bouncing = false

    var body: some View {
        ZStack {
            // 배경 원
            Circle()
                .fill(backgroundColor)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

            // 이모지 표정
            Text(emotion.emoji)
                .font(.system(size: 40))
                .scaleEffect(bouncing ? 1.2 : 1.0)
                .animation(
                    emotion == .excited
                        ? .easeInOut(duration: 0.3).repeatForever(autoreverses: true)
                        : .easeInOut(duration: 0.5),
                    value: bouncing
                )
        }
        .onAppear {
            if emotion == .excited {
                bouncing = true
            }
        }
        .onChange(of: emotion) { _, newEmotion in
            bouncing = (newEmotion == .excited)
        }
    }

    private var backgroundColor: Color {
        switch emotion {
        case .peaceful:     return Color.yellow.opacity(0.2)
        case .disappointed: return Color.blue.opacity(0.15)
        case .sad:          return Color.blue.opacity(0.25)
        case .crying:       return Color.blue.opacity(0.35)
        case .angry:        return Color.red.opacity(0.3)
        case .smile:        return Color.green.opacity(0.2)
        case .excited:      return Color.yellow.opacity(0.3)
        }
    }
}
