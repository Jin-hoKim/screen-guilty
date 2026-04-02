# ScreenGuilty

> A humorous macOS app — your screen gets disappointed when you slack off

ScreenGuilty detects your active app in real time. When you switch to "slacking" apps like YouTube, social media, or games, a disappointed character appears on your screen. Return to work apps, and it cheers up!

[한국어](README.ko.md)

---

## Features

- **App Detection**: Real-time active app monitoring via NSWorkspace (no special permissions required)
- **5 Emotion Stages**: Peaceful → Disappointed → Sad → Crying → Angry (based on slacking duration)
- **Screen Overlay**: Always-on-top character above the Dock (draggable)
- **Menu Bar App**: Live display of slacking time, work time, and productivity score
- **Daily Report**: Guilt report notification every day at 6:00 PM
- **Custom App Classification**: Categorize apps as slacking / work / ignore

---

## Tech Stack

| Category | Technology |
|----------|-----------|
| Language | Swift 5.9+ |
| UI | SwiftUI |
| Frameworks | AppKit (NSWorkspace), AVFoundation |
| Minimum OS | macOS 14.0 (Sonoma) |
| Build | Xcode Project (.xcodeproj) |
| Animation | Lottie (lottie-ios) |

---

## Project Structure

```
screen-guilty/
├── ScreenGuilty.xcodeproj                 # Xcode project
├── ScreenGuilty/
│   ├── ScreenGuiltyApp.swift              # App entry point (@main, MenuBarExtra)
│   ├── AppState.swift                     # Global state (ObservableObject)
│   ├── AppMonitor.swift                   # NSWorkspace app detection
│   ├── EmotionEngine.swift                # Emotion stage calculation
│   ├── SoundPlayer.swift                  # Sound playback (AVFoundation)
│   ├── Views/
│   │   ├── CharacterOverlay.swift         # Character overlay (NSPanel)
│   │   ├── MenuBarView.swift              # Menu bar dropdown
│   │   ├── SettingsView.swift             # Settings
│   │   ├── DailyReportView.swift          # Daily report
│   │   └── AppClassificationView.swift    # App classification settings
│   ├── Models/
│   │   ├── AppCategory.swift              # App classification model
│   │   ├── EmotionLevel.swift             # Emotion level enum
│   │   ├── UsageStats.swift               # Usage statistics
│   │   └── DailyReport.swift              # Daily report model
│   └── Resources/
│       ├── Sounds/                        # Sound files
│       └── Characters/                    # Lottie JSON animations
```

---

## Emotion Stages

| Stage | Slacking Time | Expression | Sound |
|-------|--------------|------------|-------|
| 1 | 0–2 min | Peaceful | None |
| 2 | 2–5 min | Slightly disappointed | Light sigh |
| 3 | 5–15 min | Sad | "Come on..." |
| 4 | 15–30 min | Crying | Sobbing |
| 5 | 30+ min | Angry | "Are you gonna work or not?!" |

---

## Getting Started

### Requirements
- macOS 14.0 (Sonoma) or later
- Xcode 16.0 or later

### Open in Xcode
```bash
git clone https://github.com/Jin-hoKim/screen-guilty.git
cd screen-guilty
open ScreenGuilty.xcodeproj
```

---

## Default App Classification

**Slacking**: Chrome, Safari, Slack, Twitch, Spotify, Steam, Apple TV, Apple Music, Zoom, KakaoTalk

**Work**: Xcode, VS Code, Sublime Text, Terminal, Finder, Notes, Pages, Numbers, Keynote, Word, Excel, Figma, IntelliJ, Cursor

---

## Pricing
- $4.99 – $7.99 (one-time purchase)
- Available on the Mac App Store

---

## License
Copyright © 2026 ScreenGuilty. All rights reserved.
