# ScreenGuilty 변경 이력

## 2026-04-02

### 프로젝트 초기화 및 기획
- `PLANNING.md` 작성 — 4단계 구현 계획 수립
- `HISTORY.md` 생성
- Phase 1~4 개발 단계 정의

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

### 빌드 오류 수정

- `ScreenGuilty/ScreenGuiltyApp.swift` — escaping closure가 struct의 mutating self를 캡처하는 문제 수정 (CharacterPanelHolder 클래스 도입)
- `ScreenGuilty/Views/AppClassificationView.swift` — InstalledApp init에 id 파라미터 누락 오류 수정 (커스텀 init 추가)
- `ScreenGuilty/Resources/Characters/README.md`, `Sounds/README.md` — 동일 이름 리소스 충돌 해결 (파일명 변경)
- **빌드 결과**: `Build complete!`
