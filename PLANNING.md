# ScreenGuilty — macOS App Development Plan

## Project Overview
**ScreenGuilty** — A humorous macOS app where your screen gets disappointed when you slack off

## Tech Stack
- Swift 5.9+ / SwiftUI / AppKit / AVFoundation
- macOS 14.0+ (Sonoma)
- Lottie (lottie-ios)
- Xcode 16.0+

---

## Implementation Phases

### Phase 1: Project Structure + Menu Bar App Basics
**Goal**: Xcode project setup, menu bar app functionality, app detection

#### Files:
1. **ScreenGuiltyApp.swift** — @main entry point, MenuBarExtra
2. **AppState.swift** — ObservableObject global state
3. **AppMonitor.swift** — NSWorkspace app detection service
4. **Models/AppCategory.swift** — App classification model (slacking/work/ignore)
5. **Models/EmotionLevel.swift** — Emotion stage enum
6. **Views/MenuBarView.swift** — Menu bar dropdown view

#### Key Implementation:
- Subscribe to `didActivateApplicationNotification` from `NSWorkspace.shared.notificationCenter`
- `bundleIdentifier`-based app classification (9 slacking / 12 work apps default)
- Unclassified apps default to "ignore" (no time tracking)
- MenuBarExtra for menu bar icon + dropdown
- AppState manages slacking time, work time, current emotion state

### Phase 2: Emotion Engine + Character Overlay
**Goal**: Slacking time → emotion stage calculation, character display above Dock

#### Files:
1. **EmotionEngine.swift** — Emotion stage calculation logic
2. **Views/CharacterOverlay.swift** — NSPanel-based overlay
3. **Resources/Characters/*.json** — 7 Lottie animations

#### Key Implementation:
- EmotionEngine: Slacking seconds → 5 stages (peaceful/disappointed/sad/crying/angry)
- Return-to-work emotions (smile/excited) — determined by previous stage
- NSPanel (floating, non-activating, borderless) — always on top
- Auto-detect Dock position (visibleFrame vs frame comparison) → adjust character position
- Lottie animation loop, scale+opacity transition on emotion change
- Angry stage: horizontal shake animation
- Draggable position (isMovableByWindowBackground)
- `didChangeScreenParametersNotification` for Dock change detection

### Phase 3: Sound + Daily Report
**Goal**: Emotion-based sound playback, usage stats collection & reporting

#### Files:
1. **SoundPlayer.swift** — AVFoundation sound playback
2. **Models/UsageStats.swift** — Usage statistics model
3. **Models/DailyReport.swift** — Daily report model
4. **Views/DailyReportView.swift** — Daily report screen
5. **Resources/Sounds/*.mp3** — 5 sound files

#### Key Implementation:
- SoundPlayer: AVAudioPlayer playback (sigh/sob/angry/cheer/welcome_back)
- Trigger sound + animation simultaneously on emotion change
- UsageStats: Per-app usage time tracking (UserDefaults + JSON)
- DailyReport: Total slacking time, TOP 3 slacking apps, productivity score
- Daily 18:00 UserNotification report
- Report image save/share (social media viral potential)

### Phase 4: Settings + Polish
**Goal**: Settings screen, custom app classification, auto-start, documentation

#### Files:
1. **Views/SettingsView.swift** — Settings screen
2. **Views/AppClassificationView.swift** — App classification settings

#### Key Implementation:
- Settings: App classification management, character size (60/80/120px), sound ON/OFF
- Adjustable slacking detection threshold (default 2 min)
- Launch at login (SMAppService)
- Display installed app list → classify as slacking/work/ignore
- UserDefaults settings persistence

---

## Notes
1. No Screen Recording / Accessibility permissions required
2. Initial character: Lottie free assets or SF Symbols fallback
3. Sound: Free sound effects (freesound.org)
4. Data: UserDefaults + JSON (no CoreData needed)
5. App Sandbox compatibility verified for Mac App Store distribution
