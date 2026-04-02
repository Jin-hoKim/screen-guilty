# ScreenGuilty — Change Log

## 2026-04-02 (5차)

### 뱀파이어 캐릭터 앱 아이콘 제작

- **generate_icon.py**: Python + Pillow로 뱀파이어 아이콘 생성 스크립트 신규 작성
- **아이콘 디자인**:
  - 배경: macOS 둥근 모서리 + 진한 보라(#19082D) 그라데이션
  - 캐릭터: 창백한 얼굴, 검은 머리, 빨간 눈(글로우), 송곳니, 피 한 방울
  - 장식: 배경 박쥐 4마리, 별빛 파티클, 빨간 망토 칼라, 흰 셔츠
- **생성된 파일** (AppIcon.appiconset):
  - icon_16x16.png (16px)
  - icon_16x16@2x.png (32px)
  - icon_32x32.png (32px)
  - icon_32x32@2x.png (64px)
  - icon_128x128.png (128px)
  - icon_128x128@2x.png (256px)
  - icon_256x256.png (256px)
  - icon_256x256@2x.png (512px)
  - icon_512x512.png (512px)
  - icon_512x512@2x.png (1024px)
  - icon_1024x1024.png (1024px)
  - AppIcon.png (1024px)
- **Resources/AppIcon.icns**: iconutil로 macOS icns 파일 재생성

## 2026-04-02 (4차)

### 앱 완성도 마무리 검증

- **사운드 파일 확인**: working.mp3, peaceful.mp3, sad.mp3, crying.mp3 모두 Resources/Sounds/에 존재 확인
- **캐릭터 파일 확인**: working.json이 Resources/Characters/에 존재 확인 (Lottie 5.12.1 포맷)
- **감정 임계값 확인**: EmotionThresholds.swift — disappointed: 120초, sad: 300초, crying: 900초, angry: 1800초 (정상)
- **번들 포함 확인**: Resources 폴더 레퍼런스로 프로젝트에 포함, 빌드 결과물에 모든 파일 정상 복사됨
- **빌드 성공**: xcodebuild Debug 빌드 오류/경고 없음

## 2026-04-02 (3차)

### 코드 서명 설정 완료

- **Debug config**:
  - `ASSETCATALOG_COMPILER_APPICON_NAME = ""` → `AppIcon` 수정 (디버그 빌드에서도 앱 아이콘 포함)
- **Release config**:
  - `CODE_SIGNING_ALLOWED = YES` 추가
  - `CODE_SIGNING_REQUIRED = YES` 추가
  - `CODE_SIGN_IDENTITY = "Apple Distribution"` 추가 (App Store 배포용 인증서)
  - `PROVISIONING_PROFILE_SPECIFIER = ""` 추가 (자동 프로비저닝)
- **공통 설정** (이미 존재): `CODE_SIGN_STYLE = Automatic`, `DEVELOPMENT_TEAM = 5376EHCG2P`, `PRODUCT_BUNDLE_IDENTIFIER = com.jworks.ScreenGuilty`
- **파일**: `ScreenGuilty.xcodeproj/project.pbxproj`

## 2026-04-02 (2차)

### App Store 메타데이터 작성

- **파일 생성**: `APP_STORE_METADATA.md`
  - 앱 이름 및 서브타이틀
  - 앱 설명 한국어 / 영어 (4000자 이내)
  - 키워드: productivity, fun, dock, character, distraction, focus, work, timer, emoji, vampire
  - 지원 URL / 개인정보 처리방침 URL
  - 심사 메모 (한국어 + 영어)
  - 연령 등급 (4+), 카테고리 (Productivity / Utilities), 버전 정보
- **기존 파일 확인**: `docs/privacy-policy.html` 이미 작성 완료 (영문, GitHub Pages 배포용)

## 2026-04-02

### App icon & build settings fix for App Store submission

**Issue**: App Store Connect upload failed with "Missing required icon. The application bundle does not have an icon in ICNS format containing a 512pt x 512pt @2x image"
- **Cause**: `ASSETCATALOG_COMPILER_APPICON_NAME` was set to empty string (`""`) in Release build settings — icons were not included in the app bundle
- **Fix**:
  - Changed `ASSETCATALOG_COMPILER_APPICON_NAME = ""` → `AppIcon` (Release config)
  - Verified standard macOS icon set in `Contents.json` (10 icons: 16–512pt, 1x/2x)
  - Confirmed all icon pixel sizes (icon_512x512@2x.png = 1024x1024)
  - Bumped build number 1 → 2
- **Files**: `ScreenGuilty.xcodeproj/project.pbxproj`, `ScreenGuilty/Assets.xcassets/AppIcon.appiconset/Contents.json`
- **Result**: Build 1.0.0 (10) uploaded to App Store Connect successfully

### Project initialization & planning
- Created `PLANNING.md` — 4-phase implementation plan
- Created `HISTORY.md`
- Defined Phase 1–4 development stages

### bundleProxyForCurrentProcess crash fix (5th attempt)

**Issue**: `Thread 1 Queue : com.apple.main-thread (serial)` runtime crash recurrence
- **Cause 1**: `.app` bundle guard removed from `AppMonitor.swift` — `NSWorkspace.shared` access caused bundleProxy nil crash
- **Cause 2**: `DailyReportView.swift`'s `DailyReportScheduler.scheduleNotification()` checked `Bundle.main.bundleIdentifier` directly — but `bundleIdentifier` itself uses bundleProxy, triggering crash
- **Fix**:
  - `AppMonitor.swift`: Restored `.app` bundle guard (`Bundle.main.bundleURL.pathExtension == "app"`)
  - `DailyReportView.swift`: Replaced `Bundle.main.bundleIdentifier != nil` → `Bundle.main.bundleURL.pathExtension == "app"`, removed unnecessary `do {}` block
  - `bundleURL` reads from CFBundle C-level directly, safe without bundleProxy
- **Files**: `ScreenGuilty/AppMonitor.swift`, `ScreenGuilty/Views/DailyReportView.swift`
- **Verified**: `xcodebuild` build succeeded (0 errors, 0 warnings)

### bundleProxyForCurrentProcess runtime crash fix (4th attempt)

**Issue**: `Thread 1 Queue : com.apple.main-thread (serial)` runtime crash recurrence
- **Root cause**: `applicationDidFinishLaunching` synchronous execution called `monitor.start()` → `NSWorkspace.shared` access while bundleProxyForCurrentProcess not yet initialized
  - Even running as `.app` bundle, Xcode debug environment initializes bundleProxy asynchronously
  - `applicationDidFinishLaunching` callback fires before bundleProxy initialization completes
- **Fix**: Wrapped `monitor.start()` in `DispatchQueue.main.async { }` to defer to next run loop cycle
  - bundleProxy guaranteed to be initialized after first run loop event processing
  - Sequence: `applicationDidFinishLaunching` → run loop start → event processing → `monitor.start()`
- **Additional**:
  - Removed `@main` → introduced `main.swift` for explicit app entry point
  - Created `ScreenGuilty.xcscheme` to force Xcode to always run `.app` bundle target
  - Added `main.swift` source file to `project.pbxproj`
- **Files**: `ScreenGuiltyApp.swift`, `main.swift` (new), `project.pbxproj`, `ScreenGuilty.xcscheme` (new)
- **Verified**: `xcodebuild` build succeeded (0 errors, 0 warnings)

### bundleProxyForCurrentProcess runtime crash fix (3rd attempt)

**Issue**: `bundleProxyForCurrentProcess is nil` runtime NSException recurrence
- **True root cause**: `Package.swift` defined as `executableTarget` — opening `Package.swift` directly or running `swift run` launches without `.app` bundle
- **Fix**:
  1. Deleted `Package.swift` entirely — `ScreenGuilty.xcodeproj` manages all dependencies (Lottie) directly
  2. Added `CODE_SIGN_IDENTITY = "-"`, `CODE_SIGN_STYLE = Manual` to Debug build settings → ensures "Sign to Run Locally"
  3. Added bundle validation guard to `AppMonitor.start()` — early return before NSWorkspace access if not `.app` bundle
- **Files**: `Package.swift` (deleted), `project.pbxproj`, `AppMonitor.swift`
- **Verified**: `xcodebuild` build succeeded, `ScreenGuilty.app` bundle generated, code signing confirmed

### bundleProxyForCurrentProcess runtime crash fix (2nd attempt)

**Issue**: `bundleProxyForCurrentProcess is nil` runtime NSException
- **Cause**: `ScreenGuiltyApp.init()` called `NSWorkspace.shared` directly — accessed before NSApplication fully initialized
- **Fix**: Introduced `@NSApplicationDelegateAdaptor(AppDelegate.self)`
  - Deferred `AppMonitor.start()`, timer, character panel, DailyReportScheduler to `applicationDidFinishLaunching()`
  - Removed all AppKit-dependent code from `ScreenGuiltyApp.init()`
- **Files**: `ScreenGuilty/ScreenGuiltyApp.swift`
- **Verified**: `xcodebuild` clean build succeeded (0 errors, 0 warnings)

### Xcode project creation + bundleProxyForCurrentProcess fix (1st attempt)

**Issue**: `bundleProxyForCurrentProcess is nil` runtime error
- **Cause**: SPM `executableTarget` doesn't generate macOS `.app` bundle — AppKit APIs like `NSWorkspace` fail
- **Fix**:
  - Created `ScreenGuilty.xcodeproj/project.pbxproj` — proper Xcode project for `.app` bundle generation
  - Modified `SoundPlayer.swift` — removed `Bundle.module` (SPM-only), unified to `Bundle.main`
- **Verified**: `xcodebuild` clean build succeeded, `ScreenGuilty.app` bundle generated

### Initial implementation (Phase 1–4)

**Files created**:

- `Package.swift` — SPM project config (macOS 14.0+, lottie-ios dependency)
- `ScreenGuiltyApp.swift` — @main entry point, MenuBarExtra, character panel init
- `AppState.swift` — ObservableObject global state (slacking time, work time, emotion, settings)
- `AppMonitor.swift` — NSWorkspace.didActivateApplicationNotification-based app detection
- `EmotionEngine.swift` — Slacking seconds → emotion stage calculation
- `SoundPlayer.swift` — AVFoundation sound playback (system sound fallback)
- `EmotionLevel.swift` — 7-stage emotion enum
- `AppCategory.swift` — App classification model + defaults (11 slacking, 14 work apps)
- `UsageStats.swift` — Per-app usage time tracking, UserDefaults persistence
- `DailyReport.swift` — Daily report model + guilt message generation
- `CharacterOverlay.swift` — NSPanel-based Dock overlay character
- `MenuBarView.swift` — Menu bar dropdown
- `SettingsView.swift` — Settings screen
- `AppClassificationView.swift` — App classification settings
- `DailyReportView.swift` — Daily report screen
- `Info.plist` — Bundle configuration
- `README.md` — Project overview

**Implementation highlights**:
- NSWorkspace-based app detection (no Screen Recording/Accessibility permissions required)
- 5 emotion stages: 0–2min peaceful, 2–5min disappointed, 5–15min sad, 15–30min crying, 30min+ angry
- Auto-detect Dock position (visibleFrame vs frame comparison)
- Character: Lottie JSON with emoji-based fallback
- UserDefaults + JSON for daily statistics persistence
- Daily 18:00 UserNotification report scheduling

### Build error fixes (1st round)

- `ScreenGuiltyApp.swift` — Fixed escaping closure capturing mutating self (introduced CharacterPanelHolder class)
- `AppClassificationView.swift` — Fixed missing id parameter in InstalledApp init (added custom init)
- `Resources/Characters/README.md`, `Sounds/README.md` — Resolved same-name resource conflict (renamed files)
- **Build result**: `Build complete!`

### Build error fixes (2nd round — QA feedback)

- `AppClassificationView.swift`
  - `InstalledApp` struct: Fixed stored property `id` conflicting with `Identifiable` — removed custom init, changed to `var id: String { bundleId }` computed property
  - Fixed concurrent capture warning: local copy `apps` → `finalApps` before `MainActor.run`
- **Build result**: `Build complete!` (0 errors, 0 warnings)

### Final QA verification & warning fixes

- `AppState.swift` — Removed unnecessary `.nonZero ?? 2` nil coalescing, removed unused `wasDistracted` variable
- `DailyReportView.swift` — Replaced unused `url` variable with `_`
- **Final build result**: 0 errors, 0 warnings
