import AppKit
import SwiftUI
import Lottie

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
        let panelWidth = size + 80  // 말풍선 좌우 여백
        let panelHeight = size + 80  // 말풍선 위쪽 공간

        // Dock 위치 감지
        let dockOnBottom = visibleFrame.origin.y > fullFrame.origin.y + 5
        let dockOnLeft   = visibleFrame.origin.x > fullFrame.origin.x + 5
        let dockOnRight  = visibleFrame.maxX < fullFrame.maxX - 5

        var x: CGFloat
        var y: CGFloat

        if dockOnBottom {
            x = visibleFrame.midX - panelWidth / 2
            y = visibleFrame.origin.y - 10
        } else if dockOnLeft {
            x = visibleFrame.origin.x + 5
            y = visibleFrame.midY - panelHeight / 2
        } else if dockOnRight {
            x = visibleFrame.maxX - panelWidth - 5
            y = visibleFrame.midY - panelHeight / 2
        } else {
            x = fullFrame.midX - panelWidth / 2
            y = fullFrame.origin.y - 10
        }

        self.setFrame(NSRect(x: x, y: y, width: panelWidth, height: panelHeight), display: true)
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
                    if appState.isSoundEnabled {
                        SoundPlayer.shared.play(emotion: appState.currentEmotion)
                    }
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
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 10)
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
            Text(tooltipMessage)
                .font(.caption)
                .fontWeight(.medium)
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

    private var tooltipMessage: String {
        if appState.isDistracted {
            let time = formatSeconds(appState.distractionSeconds)
            switch appState.currentEmotion {
            case .peaceful:     return "hmm.. \(time)"
            case .disappointed: return "seriously..? \(time)"
            case .sad:          return "i'm sad.. \(time)"
            case .crying:       return "please stop.. \(time)"
            case .angry:        return "GET BACK TO WORK! \(time)"
            default:            return "slacking.. \(time)"
            }
        } else {
            switch appState.currentEmotion {
            case .working:  return "i'm working.."
            case .smile:    return "welcome back!"
            case .excited:  return "finally! you're back!"
            default:        return "i'm here.."
            }
        }
    }

    private func formatSeconds(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m \(s)s" }
        return "\(s)s"
    }
}

// MARK: - Lottie 캐릭터 뷰
struct LottieCharacterView: View {
    let emotionLevel: EmotionLevel

    var body: some View {
        // Swift Package의 리소스는 Bundle.module에서 로드
        if let url = Bundle.main.url(forResource: emotionLevel.animationName, withExtension: "json", subdirectory: "Resources/Characters") {
            LottieView(animation: .filepath(url.path))
                .playbackMode(.playing(.toProgress(1, loopMode: .loop)))
                .animationSpeed(emotionLevel == .angry ? 1.5 : 1.0)
        } else {
            // JSON 파일 없으면 이모지 폴백
            EmojiCharacterView(emotion: emotionLevel)
        }
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
            Image(systemName: emotion.iconName)
                .font(.system(size: 36))
                .foregroundColor(.white)
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
        case .working:      return Color.green.opacity(0.15)
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
