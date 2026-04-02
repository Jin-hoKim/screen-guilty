#!/usr/bin/env python3
"""
ScreenGuilty - Mac App Store 스크린샷 생성기
해상도: 1280x800 (Mac App Store 필수 해상도)
"""

from PIL import Image, ImageDraw, ImageFont
import math
import os

# 출력 디렉토리
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "screenshots")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# 해상도 설정 (1280x800)
W, H = 1280, 800

# 색상 팔레트 (macOS 다크 테마 기반)
BG_DARK = (30, 30, 30)
BG_SIDEBAR = (45, 45, 45)
BG_CARD = (50, 50, 50)
BG_LIGHTER = (60, 60, 60)
BG_WINDOW = (40, 40, 40)

ACCENT_RED = (255, 69, 58)
ACCENT_ORANGE = (255, 159, 10)
ACCENT_GREEN = (50, 215, 75)
ACCENT_BLUE = (10, 132, 255)
ACCENT_PURPLE = (191, 90, 242)

TEXT_PRIMARY = (255, 255, 255)
TEXT_SECONDARY = (180, 180, 180)
TEXT_TERTIARY = (120, 120, 120)

# 폰트 경로
SF_FONT = "/System/Library/Fonts/SFNS.ttf"
SF_MONO = "/System/Library/Fonts/SFNSMono.ttf"
SF_ROUNDED = "/System/Library/Fonts/SFNSRounded.ttf"


def load_font(path, size):
    try:
        return ImageFont.truetype(path, size)
    except Exception:
        try:
            return ImageFont.truetype("/Library/Fonts/Arial Unicode.ttf", size)
        except Exception:
            return ImageFont.load_default()


def draw_rounded_rect(draw, xy, radius, fill=None, outline=None, width=1):
    """둥근 모서리 사각형 그리기"""
    x0, y0, x1, y1 = xy
    if fill:
        draw.rounded_rectangle([x0, y0, x1, y1], radius=radius, fill=fill, outline=outline, width=width)
    else:
        draw.rounded_rectangle([x0, y0, x1, y1], radius=radius, outline=outline, width=width)


def draw_macos_menubar(draw, width, title="ScreenGuilty"):
    """macOS 메뉴바 그리기"""
    # 메뉴바 배경
    draw.rectangle([0, 0, width, 28], fill=(25, 25, 25))

    # Apple 로고
    font_apple = load_font(SF_FONT, 14)
    draw.text((12, 5), "", font=font_apple, fill=TEXT_PRIMARY)

    # 메뉴 항목들
    font_menu = load_font(SF_FONT, 13)
    menu_items = ["  Finder", "  File", "  Edit", "  View", "  Go", "  Window", "  Help"]
    x = 40
    for item in menu_items:
        draw.text((x, 6), item, font=font_menu, fill=TEXT_PRIMARY)
        x += len(item) * 7 + 5

    # 우측 상태바 아이콘들
    right_items = ["👻", "🔋", "📶", "🔊", "14:32"]
    rx = width - 10
    for item in reversed(right_items):
        w = len(item) * 8 + 15
        rx -= w
        draw.text((rx, 5), item, font=font_menu, fill=TEXT_PRIMARY)


def draw_macos_window(draw, img, x, y, w, h, title, bg_color=BG_WINDOW):
    """macOS 스타일 윈도우 그리기"""
    # 윈도우 그림자
    shadow = Image.new("RGBA", (w + 20, h + 20), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle([10, 10, w + 10, h + 10], radius=12, fill=(0, 0, 0, 80))
    img.paste(shadow, (x - 10, y - 10), shadow)

    # 윈도우 배경
    draw.rounded_rectangle([x, y, x + w, y + h], radius=12, fill=bg_color)

    # 타이틀바
    draw.rounded_rectangle([x, y, x + w, y + 36], radius=12, fill=(55, 55, 55))
    draw.rectangle([x, y + 24, x + w, y + 36], fill=(55, 55, 55))

    # 트래픽 신호등
    for i, color in enumerate([ACCENT_RED, ACCENT_ORANGE, ACCENT_GREEN]):
        cx = x + 16 + i * 20
        cy = y + 18
        draw.ellipse([cx - 6, cy - 6, cx + 6, cy + 6], fill=color)

    # 타이틀
    font_title = load_font(SF_FONT, 13)
    bbox = draw.textbbox((0, 0), title, font=font_title)
    tw = bbox[2] - bbox[0]
    draw.text((x + w // 2 - tw // 2, y + 10), title, font=font_title, fill=TEXT_PRIMARY)


def draw_character_emoji(draw, x, y, size, emotion="working"):
    """뱀파이어 캐릭터 이모지 그리기"""
    font = load_font(SF_ROUNDED, size)
    emotions = {
        "working": "🧛",
        "angry": "🧛",
        "happy": "🧛",
        "sad": "🧛",
    }
    emoji = emotions.get(emotion, "🧛")
    draw.text((x, y), emoji, font=font, fill=TEXT_PRIMARY)


def draw_gradient_bg(img, color1, color2):
    """그라데이션 배경 그리기"""
    draw = ImageDraw.Draw(img)
    for y in range(H):
        r = int(color1[0] + (color2[0] - color1[0]) * y / H)
        g = int(color1[1] + (color2[1] - color1[1]) * y / H)
        b = int(color1[2] + (color2[2] - color1[2]) * y / H)
        draw.line([(0, y), (W, y)], fill=(r, g, b))


# ============================================================
# 스크린샷 1: 업무 중 화면 (Dock 위 뱀파이어 + 코딩 화면)
# ============================================================
def create_screenshot_1():
    img = Image.new("RGB", (W, H), BG_DARK)
    draw = ImageDraw.Draw(img)

    # 배경 그라데이션
    draw_gradient_bg(img, (22, 22, 35), (15, 15, 25))
    draw = ImageDraw.Draw(img)

    # 메뉴바
    draw_macos_menubar(draw, W, "Xcode")

    # Xcode 스타일 창
    draw_macos_window(draw, img, 30, 40, 820, 680, "ScreenGuilty — AppMonitor.swift")

    # Xcode 에디터 내용
    font_mono = load_font(SF_MONO, 13)
    font_line = load_font(SF_MONO, 12)

    # 사이드바 (파일 트리)
    draw.rectangle([31, 76, 200, 719], fill=(35, 35, 40))
    sidebar_items = [
        ("📁 ScreenGuilty", 14, TEXT_PRIMARY),
        ("  📄 AppMonitor.swift", 12, ACCENT_BLUE),
        ("  📄 AppState.swift", 12, TEXT_SECONDARY),
        ("  📄 EmotionEngine.swift", 12, TEXT_SECONDARY),
        ("📁 Views", 12, TEXT_PRIMARY),
        ("  📄 MenuBarView.swift", 12, TEXT_SECONDARY),
        ("  📄 SettingsView.swift", 12, TEXT_SECONDARY),
        ("  📄 DailyReportView.swift", 12, TEXT_SECONDARY),
    ]
    sy = 85
    for text, fsize, color in sidebar_items:
        f = load_font(SF_FONT, fsize)
        draw.text((35, sy), text, font=f, fill=color)
        sy += 22

    # 코드 에디터 영역
    code_x = 210
    code_lines = [
        ("1 ", TEXT_TERTIARY, "import Foundation"),
        ("2 ", TEXT_TERTIARY, "import AppKit"),
        ("3 ", TEXT_TERTIARY, ""),
        ("4 ", TEXT_TERTIARY, "/// 활성 앱 모니터링 클래스"),
        ("5 ", TEXT_TERTIARY, "class AppMonitor: ObservableObject {"),
        ("6 ", TEXT_TERTIARY, "    private var timer: Timer?"),
        ("7 ", TEXT_TERTIARY, "    private let checkInterval: TimeInterval = 1.0"),
        ("8 ", TEXT_TERTIARY, ""),
        ("9 ", TEXT_TERTIARY, "    func startMonitoring() {"),
        ("10", TEXT_TERTIARY, "        timer = Timer.scheduledTimer("),
        ("11", TEXT_TERTIARY, "            withTimeInterval: checkInterval,"),
        ("12", TEXT_TERTIARY, "            repeats: true") ,
        ("13", TEXT_TERTIARY, "        ) { [weak self] _ in"),
        ("14", TEXT_TERTIARY, "            self?.checkActiveApp()"),
        ("15", TEXT_TERTIARY, "        }"),
        ("16", TEXT_TERTIARY, "    }"),
        ("17", TEXT_TERTIARY, ""),
        ("18", TEXT_TERTIARY, "    private func checkActiveApp() {"),
        ("19", TEXT_TERTIARY, "        guard let app = NSWorkspace.shared"),
        ("20", TEXT_TERTIARY, "            .frontmostApplication else { return }"),
        ("21", TEXT_TERTIARY, ""),
        ("22", TEXT_TERTIARY, "        let bundleID = app.bundleIdentifier ?? \"\""),
        ("23", TEXT_TERTIARY, "        updateEmotion(for: bundleID)"),
        ("24", TEXT_TERTIARY, "    }"),
        ("25", TEXT_TERTIARY, "}"),
    ]

    syntax_colors = {
        "import": ACCENT_PURPLE,
        "class": ACCENT_PURPLE,
        "func": ACCENT_PURPLE,
        "let": ACCENT_ORANGE,
        "var": ACCENT_ORANGE,
        "private": ACCENT_PURPLE,
        "guard": ACCENT_PURPLE,
        "return": ACCENT_PURPLE,
        "self": ACCENT_ORANGE,
        "true": ACCENT_ORANGE,
    }

    cy = 82
    for line_num, _, code in code_lines:
        # 줄 번호
        draw.text((code_x, cy), line_num, font=font_line, fill=TEXT_TERTIARY)

        # 코드 (간단한 하이라이팅)
        first_word = code.strip().split()[0] if code.strip() else ""
        color = syntax_colors.get(first_word, TEXT_PRIMARY)
        if code.startswith("    ///") or code.startswith("///"):
            color = ACCENT_GREEN
        draw.text((code_x + 30, cy), code, font=font_line, fill=color)
        cy += 22

    # 하단 상태바
    draw.rectangle([31, 710, 850, 720], fill=(40, 40, 45))
    font_status = load_font(SF_FONT, 11)
    draw.text((40, 712), "AppMonitor.swift  Line 23, Col 18  UTF-8  Swift", font=font_status, fill=TEXT_TERTIARY)

    # 터미널 창 (작은 창)
    draw_macos_window(draw, img, 870, 40, 380, 300, "Terminal")
    font_term = load_font(SF_MONO, 12)
    term_lines = [
        ("$ ", ACCENT_GREEN, "xcodebuild -scheme ScreenGuilty"),
        ("", TEXT_SECONDARY, "Build Succeeded ✓"),
        ("$ ", ACCENT_GREEN, "swift run"),
        ("", ACCENT_BLUE, "Starting ScreenGuilty..."),
        ("", TEXT_SECONDARY, "[AppMonitor] Started monitoring"),
        ("", TEXT_SECONDARY, "[Emotion] Working mode active"),
        ("$ ", ACCENT_GREEN, "▌"),
    ]
    ty = 80
    for prefix, color, text in term_lines:
        draw.text((878, ty), prefix + text, font=font_term, fill=color)
        ty += 20

    # 우측 패널 - 캐릭터 표시
    panel_x = 870
    panel_y = 360
    draw_macos_window(draw, img, panel_x, panel_y, 380, 360, "ScreenGuilty")

    # 캐릭터 상태 표시
    font_char = load_font(SF_ROUNDED, 80)
    draw.text((panel_x + 130, panel_y + 50), "🧛", font=font_char, fill=TEXT_PRIMARY)

    font_status_big = load_font(SF_FONT, 18)
    font_status_sm = load_font(SF_FONT, 13)
    draw.text((panel_x + 80, panel_y + 160), "Focused & Productive", font=font_status_big, fill=ACCENT_GREEN)
    draw.text((panel_x + 105, panel_y + 188), "Keep up the great work!", font=font_status_sm, fill=TEXT_SECONDARY)

    # 작업 시간 바
    draw.text((panel_x + 20, panel_y + 225), "Work Time Today", font=font_status_sm, fill=TEXT_SECONDARY)
    draw.rounded_rectangle([panel_x + 20, panel_y + 245, panel_x + 360, panel_y + 260], radius=5, fill=BG_LIGHTER)
    draw.rounded_rectangle([panel_x + 20, panel_y + 245, panel_x + 250, panel_y + 260], radius=5, fill=ACCENT_GREEN)
    draw.text((panel_x + 20, panel_y + 268), "4h 23m productive  /  6h 15m total", font=font_status_sm, fill=TEXT_SECONDARY)

    # Dock 시뮬레이션
    dock_y = H - 75
    dock_w = 500
    dock_x = W // 2 - dock_w // 2

    # Dock 배경 (블러 효과 시뮬레이션)
    dock_img = Image.new("RGBA", (dock_w + 20, 70), (50, 50, 60, 180))
    img.paste(dock_img, (dock_x - 10, dock_y - 5))
    draw = ImageDraw.Draw(img)
    draw.rounded_rectangle([dock_x, dock_y, dock_x + dock_w, dock_y + 60], radius=16, fill=(55, 55, 65), outline=(80, 80, 90), width=1)

    # Dock 아이콘들
    dock_icons = ["🖥️", "📁", "🌐", "📧", "⚙️"]
    icon_x = dock_x + 30
    font_dock = load_font(SF_ROUNDED, 32)
    for icon in dock_icons:
        draw.text((icon_x, dock_y + 10), icon, font=font_dock, fill=TEXT_PRIMARY)
        icon_x += 80

    # 텍스트 오버레이 (하단)
    overlay_y = 740
    font_overlay = load_font(SF_FONT, 22)
    font_overlay_sm = load_font(SF_FONT, 15)

    draw.text((W // 2 - 200, overlay_y), "Stay Focused with Your Vampire", font=font_overlay, fill=TEXT_PRIMARY)
    draw.text((W // 2 - 160, overlay_y + 30), "Real-time productivity monitoring for macOS", font=font_overlay_sm, fill=TEXT_SECONDARY)

    img.save(os.path.join(OUTPUT_DIR, "01_working_mode.png"))
    print("✓ Screenshot 1: Working mode")


# ============================================================
# 스크린샷 2: 딴짓 감지 중 (유튜브 + 화난 캐릭터)
# ============================================================
def create_screenshot_2():
    img = Image.new("RGB", (W, H), BG_DARK)

    # 배경
    draw_gradient_bg(img, (35, 15, 15), (20, 10, 10))
    draw = ImageDraw.Draw(img)

    # 메뉴바
    draw_macos_menubar(draw, W, "YouTube")

    # YouTube 스타일 창
    draw_macos_window(draw, img, 20, 40, 900, 680, "YouTube - Interesting Cat Videos - Google Chrome")

    # YouTube 인터페이스 시뮬레이션
    # 헤더
    draw.rectangle([21, 76, 919, 120], fill=(15, 15, 15))
    font_yt = load_font(SF_FONT, 20)
    draw.text((30, 88), "▶ YouTube", font=font_yt, fill=(255, 0, 0))

    # 검색창
    draw.rounded_rectangle([350, 85, 700, 108], radius=20, fill=(40, 40, 40), outline=(80, 80, 80), width=1)
    font_search = load_font(SF_FONT, 13)
    draw.text((365, 90), "고양이 재밌는 영상 모음 🐱", font=font_search, fill=TEXT_SECONDARY)

    # 비디오 플레이어
    draw.rectangle([21, 121, 620, 420], fill=(0, 0, 0))
    # 썸네일 시뮬레이션
    draw.rectangle([21, 121, 620, 420], fill=(20, 20, 30))

    # 플레이어 컨트롤
    draw.rectangle([21, 390, 620, 420], fill=(20, 20, 20))
    font_ctrl = load_font(SF_FONT, 12)
    draw.text((30, 398), "▶  0:47 / 5:32", font=font_ctrl, fill=TEXT_SECONDARY)
    # 진행바
    draw.rounded_rectangle([90, 403, 580, 410], radius=3, fill=(60, 60, 60))
    draw.rounded_rectangle([90, 403, 215, 410], radius=3, fill=(255, 0, 0))

    # 동영상 제목
    font_title = load_font(SF_FONT, 16)
    font_desc = load_font(SF_FONT, 12)
    draw.text((25, 425), "고양이 6시간 연속 웃긴 영상 모음 🐱 - Cat Funny Compilation", font=font_title, fill=TEXT_PRIMARY)
    draw.text((25, 450), "CatLover TV  •  조회수 2.4M회  •  3일 전", font=font_desc, fill=TEXT_SECONDARY)

    # 추천 비디오 사이드바
    side_videos = [
        ("강아지 vs 고양이 최종보스", "DogCatTV", "1.2M views"),
        ("직장인이 유튜브 보는 이유", "WorkLifeBalance", "892K views"),
        ("10분만 보려다 3시간이...", "TimeWaster", "3.1M views"),
        ("야근하는 직장인 브이로그", "OfficeLife", "445K views"),
    ]
    vx, vy = 630, 130
    for title, channel, views in side_videos:
        # 썸네일
        draw.rounded_rectangle([vx, vy, vx + 160, vy + 90], radius=4, fill=(30, 30, 40))
        draw.text((vx + 10, vy + 10), "▶", font=load_font(SF_FONT, 30), fill=(100, 100, 110))
        # 정보
        font_v = load_font(SF_FONT, 11)
        # 텍스트 줄바꿈 시뮬레이션
        words = title.split()
        line1 = " ".join(words[:3])
        line2 = " ".join(words[3:]) if len(words) > 3 else ""
        draw.text((vx + 170, vy + 5), line1, font=font_v, fill=TEXT_PRIMARY)
        if line2:
            draw.text((vx + 170, vy + 20), line2, font=font_v, fill=TEXT_PRIMARY)
        draw.text((vx + 170, vy + 38), channel, font=font_v, fill=TEXT_TERTIARY)
        draw.text((vx + 170, vy + 52), views, font=font_v, fill=TEXT_TERTIARY)
        vy += 110

    # ===== 캐릭터 오버레이 (화난 뱀파이어) =====
    char_x, char_y = 900, 200

    # 캐릭터 창 배경 (반투명 느낌)
    char_panel = Image.new("RGBA", (320, 340), (40, 10, 10, 230))
    img.paste(char_panel, (char_x, char_y))
    draw = ImageDraw.Draw(img)

    draw.rounded_rectangle([char_x, char_y, char_x + 320, char_y + 340], radius=16,
                           fill=(50, 15, 15), outline=(200, 50, 50), width=2)

    # 화난 뱀파이어
    font_big = load_font(SF_ROUNDED, 90)
    draw.text((char_x + 100, char_y + 20), "🧛", font=font_big, fill=TEXT_PRIMARY)

    # 분노 효과
    font_anger = load_font(SF_FONT, 20)
    draw.text((char_x + 30, char_y + 18), "💢", font=load_font(SF_ROUNDED, 24), fill=ACCENT_RED)
    draw.text((char_x + 250, char_y + 18), "💢", font=load_font(SF_ROUNDED, 24), fill=ACCENT_RED)

    # 말풍선
    bubble_y = char_y + 130
    draw.rounded_rectangle([char_x + 10, bubble_y, char_x + 310, bubble_y + 120],
                           radius=12, fill=(255, 50, 50), outline=(255, 100, 100), width=1)

    font_bubble = load_font(SF_FONT, 14)
    font_bubble_bold = load_font(SF_ROUNDED, 16)
    draw.text((char_x + 20, bubble_y + 10), "😤 You're Slacking Off!", font=font_bubble_bold, fill=(255, 255, 255))
    draw.text((char_x + 20, bubble_y + 35), "YouTube is not work.", font=font_bubble, fill=(255, 220, 220))
    draw.text((char_x + 20, bubble_y + 55), "You've been distracted", font=font_bubble, fill=(255, 220, 220))
    draw.text((char_x + 20, bubble_y + 75), "for 23 minutes! 🕐", font=font_bubble, fill=(255, 220, 220))
    draw.text((char_x + 20, bubble_y + 95), "Get back to work NOW!", font=font_bubble_bold, fill=(255, 255, 255))

    # 경고 배너
    draw.rounded_rectangle([char_x + 10, char_y + 270, char_x + 310, char_y + 310],
                           radius=8, fill=(200, 30, 30))
    font_warn = load_font(SF_FONT, 13)
    draw.text((char_x + 25, char_y + 278), "⚠️  Distraction detected!", font=font_warn, fill=TEXT_PRIMARY)
    draw.text((char_x + 25, char_y + 296), "YouTube • 23 min 14 sec", font=font_warn, fill=(255, 200, 200))

    # 하단 텍스트 오버레이
    font_overlay = load_font(SF_FONT, 24)
    font_overlay_sm = load_font(SF_FONT, 15)
    draw.text((30, 730), "🧛 Caught Red-Handed!", font=font_overlay, fill=ACCENT_RED)
    draw.text((30, 762), "Your vampire watches you — and judges you when you slack off", font=font_overlay_sm, fill=TEXT_SECONDARY)

    img.save(os.path.join(OUTPUT_DIR, "02_distraction_detected.png"))
    print("✓ Screenshot 2: Distraction detected")


# ============================================================
# 스크린샷 3: 설정 화면
# ============================================================
def create_screenshot_3():
    img = Image.new("RGB", (W, H), (20, 20, 30))

    draw_gradient_bg(img, (18, 18, 28), (25, 20, 35))
    draw = ImageDraw.Draw(img)

    # 메뉴바
    draw_macos_menubar(draw, W)

    # 설정 창 (가운데)
    win_w, win_h = 560, 520
    win_x = W // 2 - win_w // 2
    win_y = 80
    draw_macos_window(draw, img, win_x, win_y, win_w, win_h, "ScreenGuilty Settings")
    draw = ImageDraw.Draw(img)

    # 탭바
    tab_y = win_y + 42
    tabs = [("⚙️  General", True), ("📋  App Classification", False)]
    tx = win_x + 10
    for tab, active in tabs:
        tw = 170
        if active:
            draw.rounded_rectangle([tx, tab_y, tx + tw, tab_y + 28], radius=6, fill=ACCENT_BLUE)
            draw.text((tx + 15, tab_y + 6), tab, font=load_font(SF_FONT, 13), fill=TEXT_PRIMARY)
        else:
            draw.text((tx + 15, tab_y + 6), tab, font=load_font(SF_FONT, 13), fill=TEXT_SECONDARY)
        tx += tw + 5

    # 구분선
    draw.line([(win_x, tab_y + 32), (win_x + win_w, tab_y + 32)], fill=(70, 70, 70), width=1)

    # 설정 내용
    content_y = tab_y + 50
    font_label = load_font(SF_FONT, 14)
    font_value = load_font(SF_FONT, 13)
    font_section = load_font(SF_ROUNDED, 12)
    font_desc = load_font(SF_FONT, 12)

    def draw_section(title, y):
        draw.text((win_x + 20, y), title.upper(), font=font_section, fill=TEXT_TERTIARY)
        return y + 22

    def draw_setting_row(label, value_widget_fn, y, desc=None):
        draw.text((win_x + 20, y + 3), label, font=font_label, fill=TEXT_PRIMARY)
        value_widget_fn(y)
        if desc:
            draw.text((win_x + 20, y + 22), desc, font=font_desc, fill=TEXT_TERTIARY)
            return y + 50
        return y + 38

    # --- Character 섹션 ---
    content_y = draw_section("Character", content_y)

    # 크기 선택 (Segmented Control)
    seg_x = win_x + win_w - 230
    seg_y = content_y

    def draw_char_size(y):
        sizes = ["Small", "Medium", "Large"]
        sx = seg_x
        draw.rounded_rectangle([sx - 2, y - 2, sx + 228, y + 28], radius=7, fill=(40, 40, 45), outline=(70, 70, 70))
        for i, s in enumerate(sizes):
            sw = 74
            if i == 1:  # Medium selected
                draw.rounded_rectangle([sx + i * sw + 1, y, sx + (i + 1) * sw - 1, y + 26], radius=6, fill=ACCENT_BLUE)
                draw.text((sx + i * sw + 20, y + 6), s, font=font_value, fill=TEXT_PRIMARY)
            else:
                draw.text((sx + i * sw + 20, y + 6), s, font=font_value, fill=TEXT_SECONDARY)

    content_y = draw_setting_row("Character Size", draw_char_size, content_y, "Size of the vampire character overlay")

    # 캐릭터 미리보기
    preview_x = win_x + win_w // 2 - 40
    draw.rounded_rectangle([preview_x - 10, content_y, preview_x + 90, content_y + 80], radius=8, fill=(35, 35, 40))
    font_preview = load_font(SF_ROUNDED, 60)
    draw.text((preview_x, content_y + 5), "🧛", font=font_preview, fill=TEXT_PRIMARY)
    content_y += 95

    # --- Emotion 섹션 ---
    draw.line([(win_x + 15, content_y), (win_x + win_w - 15, content_y)], fill=(60, 60, 60))
    content_y += 15
    content_y = draw_section("Emotion Sensitivity", content_y)

    # 슬라이더들
    sliders = [
        ("Work Threshold", 0.7, ACCENT_GREEN, "Confidence level to detect productive work"),
        ("Distraction Alert", 0.5, ACCENT_RED, "Confidence level to trigger distraction alert"),
        ("Calm Mode", 0.3, ACCENT_BLUE, "Sensitivity for peaceful state detection"),
    ]

    for slider_label, value, color, desc in sliders:
        draw.text((win_x + 20, content_y + 3), slider_label, font=font_label, fill=TEXT_PRIMARY)

        # 슬라이더
        sl_x = win_x + win_w - 230
        sl_w = 210
        draw.rounded_rectangle([sl_x, content_y + 8, sl_x + sl_w, content_y + 16], radius=4, fill=(50, 50, 55))
        draw.rounded_rectangle([sl_x, content_y + 8, sl_x + int(sl_w * value), content_y + 16], radius=4, fill=color)
        # 슬라이더 핸들
        handle_x = sl_x + int(sl_w * value)
        draw.ellipse([handle_x - 8, content_y + 4, handle_x + 8, content_y + 20], fill=TEXT_PRIMARY, outline=(150, 150, 150))

        # 값 표시
        val_text = f"{int(value * 100)}%"
        draw.text((sl_x + sl_w + 8, content_y + 4), val_text, font=font_value, fill=TEXT_SECONDARY)

        # 설명
        draw.text((win_x + 20, content_y + 20), desc, font=font_desc, fill=TEXT_TERTIARY)
        content_y += 52

    # --- Launch at Login ---
    draw.line([(win_x + 15, content_y), (win_x + win_w - 15, content_y)], fill=(60, 60, 60))
    content_y += 15
    content_y = draw_section("System", content_y)

    draw.text((win_x + 20, content_y + 3), "Launch at Login", font=font_label, fill=TEXT_PRIMARY)
    # 토글 스위치 (ON)
    tog_x = win_x + win_w - 60
    draw.rounded_rectangle([tog_x, content_y, tog_x + 44, content_y + 24], radius=12, fill=ACCENT_GREEN)
    draw.ellipse([tog_x + 22, content_y + 2, tog_x + 42, content_y + 22], fill=TEXT_PRIMARY)

    # 텍스트 오버레이
    draw = ImageDraw.Draw(img)
    font_overlay = load_font(SF_FONT, 22)
    font_overlay_sm = load_font(SF_FONT, 15)
    draw.text((W // 2 - 200, 660), "Fully Customizable to Your Workflow", font=font_overlay, fill=TEXT_PRIMARY)
    draw.text((W // 2 - 220, 690), "Adjust character size, emotion sensitivity, and startup preferences", font=font_overlay_sm, fill=TEXT_SECONDARY)

    img.save(os.path.join(OUTPUT_DIR, "03_settings.png"))
    print("✓ Screenshot 3: Settings")


# ============================================================
# 스크린샷 4: 메뉴바 드롭다운 (딴짓 시간 통계)
# ============================================================
def create_screenshot_4():
    img = Image.new("RGB", (W, H), (20, 20, 30))
    draw_gradient_bg(img, (15, 15, 25), (20, 18, 30))
    draw = ImageDraw.Draw(img)

    # 배경 - 데스크탑 느낌
    draw_macos_menubar(draw, W)

    # 배경 앱들 (흐릿하게)
    draw_macos_window(draw, img, 50, 50, 700, 650, "Xcode — AppState.swift")
    draw = ImageDraw.Draw(img)

    # 배경 코드 (희미하게)
    font_bg = load_font(SF_MONO, 11)
    bg_lines = [
        "class AppState: ObservableObject {",
        "    @Published var currentEmotion: Emotion = .peaceful",
        "    @Published var isDistracted: Bool = false",
        "    @Published var workingTime: TimeInterval = 0",
        "    @Published var distractedTime: TimeInterval = 0",
        "    ",
        "    func updateStats() {",
        "        // Update daily statistics",
        "    }",
    ]
    by = 85
    for line in bg_lines:
        draw.text((60, by), line, font=font_bg, fill=(70, 70, 80))
        by += 18

    # ===== 메뉴바 드롭다운 =====
    dropdown_x = W - 370
    dropdown_y = 28
    dropdown_w = 340
    dropdown_h = 420

    # 드롭다운 그림자
    shadow = Image.new("RGBA", (dropdown_w + 20, dropdown_h + 20), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    sdraw.rounded_rectangle([10, 10, dropdown_w + 10, dropdown_h + 10], radius=12, fill=(0, 0, 0, 100))
    img.paste(shadow, (dropdown_x - 10, dropdown_y - 10), shadow)
    draw = ImageDraw.Draw(img)

    # 드롭다운 배경
    draw.rounded_rectangle([dropdown_x, dropdown_y, dropdown_x + dropdown_w, dropdown_y + dropdown_h],
                           radius=12, fill=(45, 45, 50), outline=(70, 70, 75), width=1)

    # 헤더 - 캐릭터 및 상태
    dy = dropdown_y + 15

    # 뱀파이어 아이콘
    font_char = load_font(SF_ROUNDED, 48)
    draw.text((dropdown_x + 15, dy), "🧛", font=font_char, fill=TEXT_PRIMARY)

    # 상태 텍스트
    font_name = load_font(SF_ROUNDED, 16)
    font_status = load_font(SF_FONT, 13)
    draw.text((dropdown_x + 75, dy + 2), "ScreenGuilty", font=font_name, fill=TEXT_PRIMARY)
    draw.text((dropdown_x + 75, dy + 22), "😤 You're distracted!", font=font_status, fill=ACCENT_RED)
    draw.text((dropdown_x + 75, dy + 40), "YouTube • 18 min 32 sec", font=font_status, fill=TEXT_SECONDARY)

    dy += 65
    draw.line([(dropdown_x + 10, dy), (dropdown_x + dropdown_w - 10, dy)], fill=(65, 65, 70), width=1)
    dy += 12

    # 오늘 통계 섹션
    font_section = load_font(SF_ROUNDED, 12)
    font_stat = load_font(SF_FONT, 13)
    font_stat_val = load_font(SF_ROUNDED, 13)

    draw.text((dropdown_x + 15, dy), "TODAY'S STATS", font=font_section, fill=TEXT_TERTIARY)
    dy += 20

    # 통계 항목들
    stats = [
        ("⏰", "Total Work Time", "6h 42m", TEXT_PRIMARY),
        ("✅", "Productive Time", "4h 58m", ACCENT_GREEN),
        ("😈", "Distracted Time", "1h 44m", ACCENT_RED),
        ("📊", "Productivity Score", "74%", ACCENT_ORANGE),
    ]

    for icon, label, value, color in stats:
        draw.text((dropdown_x + 15, dy), icon, font=font_stat, fill=color)
        draw.text((dropdown_x + 40, dy), label, font=font_stat, fill=TEXT_SECONDARY)
        # 값 우측 정렬
        val_bbox = draw.textbbox((0, 0), value, font=font_stat_val)
        val_w = val_bbox[2] - val_bbox[0]
        draw.text((dropdown_x + dropdown_w - val_w - 15, dy), value, font=font_stat_val, fill=color)
        dy += 28

    dy += 5
    draw.line([(dropdown_x + 10, dy), (dropdown_x + dropdown_w - 10, dy)], fill=(65, 65, 70), width=1)
    dy += 12

    # 딴짓 TOP 앱
    draw.text((dropdown_x + 15, dy), "TOP DISTRACTIONS TODAY", font=font_section, fill=TEXT_TERTIARY)
    dy += 20

    distractions = [
        ("▶️", "YouTube", "1h 02m", 0.60),
        ("🎮", "Valorant", "28m", 0.27),
        ("📱", "KakaoTalk", "14m", 0.13),
    ]

    for icon, app, time, ratio in distractions:
        draw.text((dropdown_x + 15, dy), f"{icon} {app}", font=font_stat, fill=TEXT_PRIMARY)
        time_bbox = draw.textbbox((0, 0), time, font=font_stat)
        time_w = time_bbox[2] - time_bbox[0]
        draw.text((dropdown_x + dropdown_w - time_w - 15, dy), time, font=font_stat, fill=TEXT_SECONDARY)
        dy += 18
        # 진행바
        bar_w = int((dropdown_w - 30) * ratio)
        draw.rounded_rectangle([dropdown_x + 15, dy, dropdown_x + dropdown_w - 15, dy + 5], radius=3, fill=(55, 55, 60))
        draw.rounded_rectangle([dropdown_x + 15, dy, dropdown_x + 15 + bar_w, dy + 5], radius=3, fill=ACCENT_RED)
        dy += 12

    dy += 8
    draw.line([(dropdown_x + 10, dy), (dropdown_x + dropdown_w - 10, dy)], fill=(65, 65, 70), width=1)
    dy += 10

    # 액션 버튼
    buttons = [
        ("📋  Daily Report", ACCENT_BLUE),
        ("⚙️  Settings", (65, 65, 70)),
        ("🚪  Quit ScreenGuilty", (65, 65, 70)),
    ]

    for btn_text, btn_color in buttons:
        if btn_color == ACCENT_BLUE:
            draw.rounded_rectangle([dropdown_x + 10, dy, dropdown_x + dropdown_w - 10, dy + 28],
                                   radius=6, fill=btn_color)
            draw.text((dropdown_x + 25, dy + 7), btn_text, font=font_stat, fill=TEXT_PRIMARY)
        else:
            draw.rounded_rectangle([dropdown_x + 10, dy, dropdown_x + dropdown_w - 10, dy + 28],
                                   radius=6, fill=btn_color)
            draw.text((dropdown_x + 25, dy + 7), btn_text, font=font_stat, fill=TEXT_PRIMARY)
        dy += 33

    # 메뉴바에 아이콘 표시 (하이라이트)
    draw.rounded_rectangle([W - 85, 2, W - 10, 26], radius=5, fill=(60, 60, 70))
    font_menubar = load_font(SF_ROUNDED, 14)
    draw.text((W - 80, 4), "🧛 1h 44m", font=font_menubar, fill=ACCENT_RED)

    # 텍스트 오버레이
    font_overlay = load_font(SF_FONT, 22)
    font_overlay_sm = load_font(SF_FONT, 15)
    draw.text((60, 720), "Always in Your Menu Bar", font=font_overlay, fill=TEXT_PRIMARY)
    draw.text((60, 752), "Quick access to stats, daily report and settings — right from the menu bar", font=font_overlay_sm, fill=TEXT_SECONDARY)

    img.save(os.path.join(OUTPUT_DIR, "04_menubar_dropdown.png"))
    print("✓ Screenshot 4: Menubar dropdown")


# ============================================================
# 스크린샷 5: 일일 리포트 화면
# ============================================================
def create_screenshot_5():
    img = Image.new("RGB", (W, H), (20, 20, 30))
    draw_gradient_bg(img, (18, 18, 30), (22, 18, 32))
    draw = ImageDraw.Draw(img)

    # 메뉴바
    draw_macos_menubar(draw, W)

    # 배경 데스크탑
    draw_macos_window(draw, img, 50, 50, 500, 400, "Terminal")
    draw = ImageDraw.Draw(img)

    # 일일 리포트 창 (가운데)
    rep_w, rep_h = 400, 620
    rep_x = W // 2 - rep_w // 2 + 100
    rep_y = 45

    draw_macos_window(draw, img, rep_x, rep_y, rep_w, rep_h, "Daily Guilt Report")
    draw = ImageDraw.Draw(img)

    # ===== 리포트 내용 =====
    ry = rep_y + 55

    # 헤더
    font_header = load_font(SF_ROUNDED, 18)
    font_date = load_font(SF_FONT, 13)
    draw.text((rep_x + 20, ry), "📊 Daily Report", font=font_header, fill=TEXT_PRIMARY)
    draw.text((rep_x + 20, ry + 26), "Wednesday, April 2, 2026", font=font_date, fill=TEXT_SECONDARY)
    ry += 55

    draw.line([(rep_x + 15, ry), (rep_x + rep_w - 15, ry)], fill=(65, 65, 70))
    ry += 15

    # 생산성 원형 차트 (중앙)
    circle_cx = rep_x + rep_w // 2
    circle_cy = ry + 70
    circle_r = 60

    # 배경 원
    draw.ellipse([circle_cx - circle_r, circle_cy - circle_r,
                  circle_cx + circle_r, circle_cy + circle_r],
                 outline=(55, 55, 60), width=10)

    # 생산성 호 (74%)
    import math
    angle_start = -90
    angle_end = -90 + int(360 * 0.74)

    # 호 그리기 (여러 조각으로)
    for angle in range(angle_start, angle_end, 5):
        rad = math.radians(angle)
        rad_end = math.radians(angle + 5)
        x1 = circle_cx + (circle_r - 5) * math.cos(rad)
        y1 = circle_cy + (circle_r - 5) * math.sin(rad)
        x2 = circle_cx + (circle_r + 5) * math.cos(rad)
        y2 = circle_cy + (circle_r + 5) * math.sin(rad)
        draw.line([(x1, y1), (x2, y2)], fill=ACCENT_GREEN, width=3)

    # 원형 진행바 (더 깔끔하게)
    draw.arc([circle_cx - circle_r, circle_cy - circle_r,
              circle_cx + circle_r, circle_cy + circle_r],
             start=-90, end=-90 + int(360 * 0.74), fill=ACCENT_GREEN, width=10)

    # 중앙 텍스트
    font_score = load_font(SF_ROUNDED, 28)
    font_score_label = load_font(SF_FONT, 11)
    draw.text((circle_cx - 22, circle_cy - 20), "74%", font=font_score, fill=TEXT_PRIMARY)
    draw.text((circle_cx - 22, circle_cy + 12), "Productive", font=font_score_label, fill=TEXT_SECONDARY)

    ry = circle_cy + circle_r + 20

    # 시간 통계 카드
    time_items = [
        ("✅ Productive", "4h 58m", ACCENT_GREEN),
        ("😈 Distracted", "1h 44m", ACCENT_RED),
        ("🌙 Idle", "0h 42m", TEXT_TERTIARY),
    ]

    card_w = (rep_w - 30) // 3 - 5
    cx = rep_x + 15
    for label, time, color in time_items:
        draw.rounded_rectangle([cx, ry, cx + card_w, ry + 60], radius=8, fill=(40, 40, 48))
        font_card_val = load_font(SF_ROUNDED, 16)
        font_card_label = load_font(SF_FONT, 11)
        draw.text((cx + 10, ry + 8), time, font=font_card_val, fill=color)
        draw.text((cx + 10, ry + 30), label, font=font_card_label, fill=TEXT_SECONDARY)
        cx += card_w + 7

    ry += 75
    draw.line([(rep_x + 15, ry), (rep_x + rep_w - 15, ry)], fill=(65, 65, 70))
    ry += 15

    # TOP 딴짓 앱
    font_section = load_font(SF_ROUNDED, 12)
    font_app = load_font(SF_FONT, 13)

    draw.text((rep_x + 15, ry), "TOP DISTRACTING APPS", font=font_section, fill=TEXT_TERTIARY)
    ry += 22

    top_apps = [
        ("▶️", "YouTube", "1h 02m", 0.60, ACCENT_RED),
        ("🎮", "Valorant", "28m", 0.27, ACCENT_ORANGE),
        ("📱", "KakaoTalk", "14m", 0.13, ACCENT_ORANGE),
    ]

    for i, (icon, app, time, ratio, color) in enumerate(top_apps, 1):
        medal = ["🥇", "🥈", "🥉"][i-1]
        draw.text((rep_x + 15, ry), f"{medal} {icon} {app}", font=font_app, fill=TEXT_PRIMARY)
        bbox = draw.textbbox((0, 0), time, font=font_app)
        tw = bbox[2] - bbox[0]
        draw.text((rep_x + rep_w - tw - 15, ry), time, font=font_app, fill=color)
        ry += 18
        # 진행바
        bar_full = rep_w - 30
        draw.rounded_rectangle([rep_x + 15, ry, rep_x + rep_w - 15, ry + 6], radius=3, fill=(50, 50, 55))
        draw.rounded_rectangle([rep_x + 15, ry, rep_x + 15 + int(bar_full * ratio), ry + 6], radius=3, fill=color)
        ry += 14

    ry += 10
    draw.line([(rep_x + 15, ry), (rep_x + rep_w - 15, ry)], fill=(65, 65, 70))
    ry += 15

    # 죄책감 메시지
    font_msg_title = load_font(SF_ROUNDED, 14)
    font_msg = load_font(SF_FONT, 12)

    # 메시지 박스
    draw.rounded_rectangle([rep_x + 15, ry, rep_x + rep_w - 15, ry + 85], radius=8, fill=(45, 30, 30))
    draw.text((rep_x + 25, ry + 10), "🧛 Vampire's Verdict", font=font_msg_title, fill=ACCENT_RED)
    msg = "Not bad, but your YouTube habit is\nsuspicious. Your future self will thank\nyou for watching less cat videos."
    for i, line in enumerate(msg.split('\n')):
        draw.text((rep_x + 25, ry + 32 + i * 17), line, font=font_msg, fill=(220, 180, 180))
    ry += 95

    # 버튼들
    btn_w = (rep_w - 30) // 2 - 5
    draw.rounded_rectangle([rep_x + 15, ry, rep_x + 15 + btn_w, ry + 32], radius=6, fill=ACCENT_BLUE)
    draw.text((rep_x + 35, ry + 9), "🔔 Remind Tomorrow", font=load_font(SF_FONT, 12), fill=TEXT_PRIMARY)

    draw.rounded_rectangle([rep_x + 20 + btn_w, ry, rep_x + rep_w - 15, ry + 32], radius=6, fill=(55, 55, 60))
    draw.text((rep_x + 30 + btn_w, ry + 9), "✕  Close", font=load_font(SF_FONT, 12), fill=TEXT_PRIMARY)

    # 텍스트 오버레이
    font_overlay = load_font(SF_FONT, 22)
    font_overlay_sm = load_font(SF_FONT, 15)
    draw.text((60, 710), "Your Daily Guilt Report", font=font_overlay, fill=TEXT_PRIMARY)
    draw.text((60, 742), "See exactly how your day went — and face the vampire's honest verdict", font=font_overlay_sm, fill=TEXT_SECONDARY)

    img.save(os.path.join(OUTPUT_DIR, "05_daily_report.png"))
    print("✓ Screenshot 5: Daily report")


if __name__ == "__main__":
    print("Generating App Store screenshots...")
    create_screenshot_1()
    create_screenshot_2()
    create_screenshot_3()
    create_screenshot_4()
    create_screenshot_5()
    print(f"\nAll screenshots saved to: {OUTPUT_DIR}")
    print("Resolution: 1280x800 (Mac App Store compatible)")
