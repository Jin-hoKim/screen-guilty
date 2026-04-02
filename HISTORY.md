# ScreenGuilty 변경 이력

## 2026-04-02

### 프로젝트 초기화 및 기획
- `PLANNING.md` 작성 — 4단계 구현 계획 수립
- `HISTORY.md` 생성
- Phase 1~4 개발 단계 정의

### bundleProxyForCurrentProcess 런타임 크래시 수정 (4차)

**문제**: `Thread 1 Queue : com.apple.main-thread (serial)` 런타임 크래시 재발
- **근본 원인**: `applicationDidFinishLaunching` 동기 실행 중 `monitor.start()` → `NSWorkspace.shared` 접근 시 bundleProxyForCurrentProcess 미초기화
  - `.app` 번들로 실행 중임에도 Xcode 디버그 실행 환경에서는 bundleProxy가 비동기적으로 초기화됨
  - `applicationDidFinishLaunching` 동기 콜백 시점에는 아직 bundleProxy 초기화 미완료
- **해결**: `monitor.start()` 호출을 `DispatchQueue.main.async { }` 로 감싸서 다음 런루프 사이클로 지연
  - 첫 런루프 이벤트 처리 이후에는 bundleProxy가 반드시 초기화됨
  - `applicationDidFinishLaunching` → 런루프 시작 → 이벤트 처리 → `monitor.start()` 순서 보장
- **수정 파일**: `ScreenGuilty/ScreenGuiltyApp.swift`
- **검증**: `xcodebuild` 빌드 성공 (에러 0, 경고 0)

### bundleProxyForCurrentProcess 런타임 크래시 최종 수정 (3차)

**문제**: `bundleProxyForCurrentProcess is nil` 런타임 NSException 재발
- **진짜 근본 원인**: `Package.swift`가 `executableTarget`으로 정의되어 있어, Xcode에서 `Package.swift`를 직접 열거나 `swift run` 실행 시 `.app` 번들 없이 실행됨
  - 이전 DerivedData 경로: `screen-guilty-clqtusirbesoomhjyfzueiyxnjya` (Package.swift 기반)
  - 새 DerivedData 경로: `ScreenGuilty-fnversieinzmqwaseakpywljdzfq` (xcodeproj 기반)
- **해결**:
  1. `Package.swift` 완전 삭제 — `ScreenGuilty.xcodeproj`가 모든 의존성(Lottie) 직접 관리
  2. `project.pbxproj` Debug 빌드 설정에 `CODE_SIGN_IDENTITY = "-"`, `CODE_SIGN_STYLE = Manual` 추가 → "Sign to Run Locally" 서명 보장
  3. `AppMonitor.start()` 번들 검증 가드 추가 — `.app` 번들이 아닌 경우 NSWorkspace 접근 전 조기 반환
- **수정 파일**: `Package.swift` (삭제), `ScreenGuilty.xcodeproj/project.pbxproj`, `ScreenGuilty/AppMonitor.swift`
- **검증**: `xcodebuild` 빌드 성공 (에러 0, 경고 0), `ScreenGuilty.app` 번들 정상 생성, "Sign to Run Locally" 코드 서명 확인

### bundleProxyForCurrentProcess 런타임 크래시 근본 수정 (2차)

**문제**: `bundleProxyForCurrentProcess is nil` 런타임 NSException
- **원인**: `ScreenGuiltyApp.init()`에서 `NSWorkspace.shared`를 직접 호출 → NSApplication이 완전히 초기화되기 전 접근
- **해결**: `@NSApplicationDelegateAdaptor(AppDelegate.self)` 도입
  - `AppDelegate.applicationDidFinishLaunching()`으로 `AppMonitor.start()`, 타이머, 캐릭터 패널, DailyReportScheduler 초기화 지연
  - `ScreenGuiltyApp.init()`에서 모든 AppKit-의존 코드 제거
- **수정 파일**: `ScreenGuilty/ScreenGuiltyApp.swift`
- **검증**: `xcodebuild` 클린빌드 성공 (에러 0, 경고 0)

### Xcode 프로젝트 생성 + bundleProxyForCurrentProcess 에러 수정 (1차)

**문제**: `bundleProxyForCurrentProcess is nil` 런타임 에러
- **원인**: SPM `executableTarget`은 macOS `.app` 번들을 생성하지 않아 `NSWorkspace` 등 AppKit API가 정상 동작 불가
- **해결**:
  - `ScreenGuilty.xcodeproj/project.pbxproj` 생성 — 진짜 Xcode 프로젝트로 `.app` 번들 생성
  - `ScreenGuilty/SoundPlayer.swift` 수정 — `Bundle.module` (SPM 전용) 제거, `Bundle.main` 통일
- **검증**: `xcodebuild` 클린빌드 성공, `ScreenGuilty.app` 번들 정상 생성 확인

### 초기 구현 완료 (Phase 1~4)

**생성된 파일**:

- `Package.swift` — SPM 프로젝트 설정 (macOS 14.0+, lottie-ios 의존성)
- `ScreenGuilty/ScreenGuiltyApp.swift` — @main 진입점, MenuBarExtra, 캐릭터 패널 초기화
- `ScreenGuilty/AppState.swift` — ObservableObject 전역 상태 (딴짓시간, 업무시간, 감정, 설정)
- `ScreenGuilty/AppMonitor.swift` — NSWorkspace.didActivateApplicationNotification 기반 앱 감지
- `ScreenGuilty/EmotionEngine.swift` — 딴짓시간(초) → 감정단계 계산
- `ScreenGuilty/SoundPlayer.swift` — AVFoundation 사운드 재생 (시스템 사운드 폴백)
- `ScreenGuilty/Models/EmotionLevel.swift` — 감정 7단계 enum
- `ScreenGuilty/Models/AppCategory.swift` — 앱 분류 모델 + 기본 분류 데이터 (딴짓 11종, 업무 14종)
- `ScreenGuilty/Models/UsageStats.swift` — 앱별 사용시간 기록, UserDefaults 저장
- `ScreenGuilty/Models/DailyReport.swift` — 일일 리포트 모델 + 죄책감 메시지 생성
- `ScreenGuilty/Views/CharacterOverlay.swift` — NSPanel 기반 Dock 위 캐릭터 오버레이
- `ScreenGuilty/Views/MenuBarView.swift` — 메뉴바 드롭다운
- `ScreenGuilty/Views/SettingsView.swift` — 설정 화면
- `ScreenGuilty/Views/AppClassificationView.swift` — 앱 분류 설정
- `ScreenGuilty/Views/DailyReportView.swift` — 일일 리포트 화면
- `ScreenGuilty/Info.plist` — 번들 설정
- `README.md` — 프로젝트 개요

**구현 핵심**:
- NSWorkspace 기반 앱 감지 (Screen Recording/Accessibility 권한 불필요)
- 딴짓 5단계: 0~2분 평화, 2~5분 실망, 5~15분 슬픔, 15~30분 울기, 30분+ 분노
- Dock 위치 자동감지 (visibleFrame vs frame 비교)
- 캐릭터: Lottie JSON 없으면 이모지 기반 폴백
- UserDefaults + JSON으로 일별 통계 영속화
- 매일 18:00 UserNotification 리포트 알림 스케줄

### 빌드 오류 수정 (1차)

- `ScreenGuilty/ScreenGuiltyApp.swift` — escaping closure가 struct의 mutating self를 캡처하는 문제 수정 (CharacterPanelHolder 클래스 도입)
- `ScreenGuilty/Views/AppClassificationView.swift` — InstalledApp init에 id 파라미터 누락 오류 수정 (커스텀 init 추가)
- `ScreenGuilty/Resources/Characters/README.md`, `Sounds/README.md` — 동일 이름 리소스 충돌 해결 (파일명 변경)
- **빌드 결과**: `Build complete!`

### 빌드 오류 수정 (2차 — QA 피드백 반영)

- `ScreenGuilty/Views/AppClassificationView.swift`
  - `InstalledApp` 구조체: 저장 프로퍼티 `id`와 `Identifiable` 요구사항 충돌 수정 → 커스텀 init 제거하고 `var id: String { bundleId }` 연산 프로퍼티로 변경
  - concurrent capture 경고 수정: `apps` → `finalApps` 로컬 복사 후 `MainActor.run` 전달
- **클린 빌드 결과**: `Build complete!` (에러 0, 경고 0)

### QA 최종 검증 및 경고 수정

- `ScreenGuilty/AppState.swift` — `.nonZero ?? 2` 불필요한 nil coalescing 제거, `wasDistracted` 미사용 변수 제거
- `ScreenGuilty/Views/DailyReportView.swift` — 미사용 `url` 변수를 `_`로 교체
- **최종 빌드 결과**: 에러 0건, 경고 0건
