# ScreenGuilty — macOS 앱 개발 계획

## 프로젝트 개요
**ScreenGuilty** — 딴짓하면 화면이 실망한 표정을 짓는 macOS 유머 앱

## 기술 스택
- Swift 5.9+ / SwiftUI / AppKit / AVFoundation
- macOS 14.0+ (Sonoma)
- Lottie (Swift Package Manager)
- Xcode 16.0+

---

## 구현 단계

### Phase 1: 프로젝트 구조 + 메뉴바 앱 기본
**목표**: Xcode 프로젝트 생성, 메뉴바 앱 동작, 앱 감지 기능

#### 생성할 파일:
1. **ScreenGuilty/ScreenGuiltyApp.swift** — @main 진입점, MenuBarExtra
2. **ScreenGuilty/AppState.swift** — ObservableObject 전역 상태
3. **ScreenGuilty/AppMonitor.swift** — NSWorkspace 앱 감지 서비스
4. **ScreenGuilty/Models/AppCategory.swift** — 앱 분류 모델 (딴짓/업무/무시)
5. **ScreenGuilty/Models/EmotionLevel.swift** — 감정 단계 enum
6. **ScreenGuilty/Views/MenuBarView.swift** — 메뉴바 드롭다운 뷰

#### 핵심 구현:
- `NSWorkspace.shared.notificationCenter`에서 `didActivateApplicationNotification` 구독
- `bundleIdentifier` 기반 앱 분류 (딴짓 9종 / 업무 12종 기본값)
- 분류되지 않은 앱은 "무시" 카테고리 (시간 계측 안 함)
- MenuBarExtra로 메뉴바 아이콘 + 드롭다운 구현
- AppState에서 딴짓 시간, 업무 시간, 현재 감정 상태 관리

### Phase 2: 감정 엔진 + 캐릭터 오버레이
**목표**: 딴짓 시간 → 감정 단계 계산, Dock 위 캐릭터 표시

#### 생성할 파일:
1. **ScreenGuilty/EmotionEngine.swift** — 감정 단계 계산 로직
2. **ScreenGuilty/Views/CharacterOverlay.swift** — NSPanel 기반 오버레이
3. **ScreenGuilty/Resources/Characters/*.json** — Lottie 애니메이션 7종

#### 핵심 구현:
- EmotionEngine: 딴짓 시간(초) → 5단계 감정 (peaceful/disappointed/sad/crying/angry)
- 업무 복귀 시 감정 (smile/excited) — 이전 단계에 따라 결정
- NSPanel (floating, non-activating, borderless) — 항상 위에 표시
- Dock 위치 자동 감지 (visibleFrame vs frame 비교) → 캐릭터 위치 조정
- Lottie 애니메이션 루프 재생, 감정 전환 시 scale+opacity 트랜지션
- 분노 단계 좌우 흔들림 애니메이션
- 드래그로 위치 이동 가능 (isMovableByWindowBackground)
- `didChangeScreenParametersNotification`으로 Dock 변경 감지

### Phase 3: 사운드 + 일일 리포트
**목표**: 감정별 사운드 재생, 사용 통계 수집 및 리포트

#### 생성할 파일:
1. **ScreenGuilty/SoundPlayer.swift** — AVFoundation 사운드 재생
2. **ScreenGuilty/Models/UsageStats.swift** — 사용 통계 모델
3. **ScreenGuilty/Models/DailyReport.swift** — 일일 리포트 모델
4. **ScreenGuilty/Views/DailyReportView.swift** — 일일 리포트 화면
5. **ScreenGuilty/Resources/Sounds/*.mp3** — 사운드 5종

#### 핵심 구현:
- SoundPlayer: AVAudioPlayer로 사운드 재생 (sigh/sob/angry/cheer/welcome_back)
- 감정 변화 시 사운드와 애니메이션 동시 트리거
- UsageStats: 앱별 사용 시간 기록 (UserDefaults + JSON)
- DailyReport: 총 딴짓 시간, TOP 3 딴짓 앱, 생산성 점수 계산
- 매일 18:00 UserNotification으로 리포트 알림
- 리포트 이미지 저장/공유 기능 (SNS 바이럴)

### Phase 4: 설정 + 마무리
**목표**: 설정 화면, 앱 분류 커스텀, 자동 시작, 문서화

#### 생성할 파일:
1. **ScreenGuilty/Views/SettingsView.swift** — 설정 화면
2. **ScreenGuilty/Views/AppClassificationView.swift** — 앱 분류 설정

#### 핵심 구현:
- 설정 화면: 앱 분류 관리, 캐릭터 크기(60/80/120px), 사운드 ON/OFF
- 딴짓 판정 시간 임계값 조절 (기본 2분)
- 로그인 시 자동 시작 (SMAppService)
- 설치된 앱 목록 표시 → 딴짓/업무/무시 분류 설정
- UserDefaults로 설정 영속화

---

## Xcode 프로젝트 구성 (CLI 생성)

Xcode 프로젝트를 CLI에서 생성하기 위해 Swift Package 기반 구조 사용:
- Package.swift에 lottie-ios 의존성 추가
- 또는 .xcodeproj를 xcodegen/tuist로 생성

**권장: Swift Package 기반**
- Package.swift로 의존성 관리
- ScreenGuilty/ 하위에 Sources/Resources 구성

---

## 주의사항
1. Screen Recording / Accessibility 권한 불필요
2. 초기 캐릭터: Lottie 무료 에셋 또는 SF Symbols 대체
3. 사운드: freesound.org 등 무료 효과음
4. 데이터: UserDefaults + JSON (CoreData 불필요)
5. Mac App Store 배포 시 Sandbox 호환 확인 필요
