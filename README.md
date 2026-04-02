# ScreenGuilty 🫣

> 딴짓하면 화면이 실망한 표정을 짓는 macOS 유머 앱

현재 활성 앱을 감지하여, 유튜브/SNS/게임 등 "딴짓" 앱을 사용하면 화면 구석에 실망한 캐릭터가 나타나고, 업무용 앱으로 돌아오면 기뻐합니다.

---

## 주요 기능

- **앱 감지**: NSWorkspace로 현재 활성 앱을 실시간 감지 (별도 권한 불필요)
- **감정 5단계**: 딴짓 시간에 따라 평화 → 실망 → 슬픔 → 울기 → 분노
- **화면 오버레이**: Dock 위에 항상 표시되는 캐릭터 (드래그 이동 가능)
- **메뉴바 앱**: 딴짓 시간, 업무 시간, 생산성 점수 실시간 표시
- **일일 리포트**: 매일 18:00 죄책감 리포트 알림
- **앱 분류 커스텀**: 딴짓/업무/무시 분류를 직접 설정

---

## 기술 스택

| 항목 | 기술 |
|------|------|
| 언어 | Swift 5.9+ |
| UI | SwiftUI |
| 프레임워크 | AppKit (NSWorkspace), AVFoundation |
| 최소 OS | macOS 14.0 (Sonoma) |
| 빌드 도구 | Xcode Project (.xcodeproj) |
| 애니메이션 | Lottie (lottie-ios) |

---

## 프로젝트 구조

```
screen-guilty/
├── Package.swift                          # SPM 프로젝트 설정
├── ScreenGuilty/
│   ├── ScreenGuiltyApp.swift              # 앱 진입점 (@main, MenuBarExtra)
│   ├── AppState.swift                     # 전역 상태 (ObservableObject)
│   ├── AppMonitor.swift                   # NSWorkspace 앱 감지
│   ├── EmotionEngine.swift                # 감정 단계 계산
│   ├── SoundPlayer.swift                  # 사운드 재생 (AVFoundation)
│   ├── Views/
│   │   ├── CharacterOverlay.swift         # 캐릭터 오버레이 (NSPanel)
│   │   ├── MenuBarView.swift              # 메뉴바 드롭다운
│   │   ├── SettingsView.swift             # 설정 화면
│   │   ├── DailyReportView.swift          # 일일 리포트
│   │   └── AppClassificationView.swift    # 앱 분류 설정
│   ├── Models/
│   │   ├── AppCategory.swift              # 앱 분류 모델
│   │   ├── EmotionLevel.swift             # 감정 단계 enum
│   │   ├── UsageStats.swift               # 사용 통계
│   │   └── DailyReport.swift              # 일일 리포트 모델
│   └── Resources/
│       ├── Sounds/                        # 사운드 파일 (추가 필요)
│       └── Characters/                    # Lottie JSON (추가 필요)
```

---

## 감정 단계

| 단계 | 딴짓 시간 | 캐릭터 표정 | 사운드 |
|------|----------|-----------|--------|
| 1 | 0~2분 | 😊 평화로운 얼굴 | 없음 |
| 2 | 2~5분 | 😔 살짝 실망 | 가벼운 한숨 |
| 3 | 5~15분 | 😢 슬픈 얼굴 | 에이... |
| 4 | 15~30분 | 😭 울기 | 훌쩍거림 |
| 5 | 30분+ | 😡 분노 | 일 안 할 거야?! |

---

## 설치 및 실행

### 요구사항
- macOS 14.0 (Sonoma) 이상
- Xcode 16.0 이상

### Xcode에서 열기
```bash
git clone https://github.com/Jin-hoKim/screen-guilty.git
cd screen-guilty
open ScreenGuilty.xcodeproj
```

### 리소스 추가
1. `ScreenGuilty/Resources/Sounds/` — 사운드 파일 5종 추가 (freesound.org)
2. `ScreenGuilty/Resources/Characters/` — Lottie JSON 7종 추가 (lottiefiles.com)
   - 없으면 이모지 기반 폴백 캐릭터로 자동 표시

---

## 기본 분류 앱

**딴짓 앱**: Chrome, Safari, Slack, Twitch, Spotify, Steam, Apple TV, Apple Music, Zoom, KakaoTalk

**업무 앱**: Xcode, VS Code, Sublime Text, Terminal, Finder, Notes, Pages, Numbers, Keynote, Word, Excel, Figma, IntelliJ, Cursor

---

## 가격
- $4.99 ~ $7.99 (일회성 구매)
- Mac App Store + 자체 웹사이트 배포 예정

---

## 라이선스
Copyright © 2026 ScreenGuilty. All rights reserved.
