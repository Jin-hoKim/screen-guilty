#!/usr/bin/env python3
"""
ScreenGuilty 뱀파이어 앱 아이콘 생성기
- 1024x1024 메인 아이콘
- 모든 macOS 아이콘 사이즈 자동 생성
"""

from PIL import Image, ImageDraw, ImageFilter
import math
import os

def draw_rounded_rect(draw, bbox, radius, fill, outline=None, outline_width=0):
    """둥근 사각형 그리기"""
    x0, y0, x1, y1 = bbox
    draw.rectangle([x0 + radius, y0, x1 - radius, y1], fill=fill)
    draw.rectangle([x0, y0 + radius, x1, y1 - radius], fill=fill)
    draw.ellipse([x0, y0, x0 + radius*2, y0 + radius*2], fill=fill)
    draw.ellipse([x1 - radius*2, y0, x1, y0 + radius*2], fill=fill)
    draw.ellipse([x0, y1 - radius*2, x0 + radius*2, y1], fill=fill)
    draw.ellipse([x1 - radius*2, y1 - radius*2, x1, y1], fill=fill)
    if outline and outline_width > 0:
        for i in range(outline_width):
            draw.arc([x0+i, y0+i, x0+radius*2-i, y0+radius*2-i], 180, 270, fill=outline)
            draw.arc([x1-radius*2+i, y0+i, x1-i, y0+radius*2-i], 270, 360, fill=outline)
            draw.arc([x0+i, y1-radius*2+i, x0+radius*2-i, y1-i], 90, 180, fill=outline)
            draw.arc([x1-radius*2+i, y1-radius*2+i, x1-i, y1-i], 0, 90, fill=outline)

def create_vampire_icon(size=1024):
    """뱀파이어 캐릭터 아이콘 생성"""
    S = size
    img = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 스케일 팩터
    sc = S / 1024

    def s(v):
        return int(v * sc)

    # ── 배경: 진한 보라 그라데이션 ──
    bg_layer = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    bg_draw = ImageDraw.Draw(bg_layer)

    # macOS 스타일 둥근 모서리 배경
    corner_r = s(180)
    # 어두운 보라 배경
    bg_draw.rounded_rectangle([0, 0, S-1, S-1], radius=corner_r,
                               fill=(25, 8, 45, 255))

    # 상단 보라빛 글로우
    for i in range(s(300), 0, -s(10)):
        alpha = int(30 * (1 - i / s(300)))
        r = s(300) - i
        cx, cy = S//2, s(200)
        bg_draw.ellipse([cx-r, cy-r, cx+r, cy+r],
                        fill=(80, 20, 120, alpha))

    img = Image.alpha_composite(img, bg_layer)
    draw = ImageDraw.Draw(img)

    # ── 망토 (배경처럼 넓게) ──
    cape_color = (15, 5, 35, 255)
    cape_highlight = (45, 10, 80, 255)

    # 망토 메인 - 넓은 삼각형 형태
    cape_points = [
        (s(512), s(620)),  # 목 중앙
        (s(80), s(950)),   # 왼쪽 하단
        (s(200), s(780)),
        (s(512), s(850)),  # 중앙 하단
        (s(824), s(780)),
        (s(944), s(950)),  # 오른쪽 하단
    ]
    draw.polygon(cape_points, fill=cape_color)

    # 망토 왼쪽 날개
    left_wing = [
        (s(300), s(580)),
        (s(80), s(700)),
        (s(60), s(900)),
        (s(180), s(820)),
        (s(420), s(650)),
    ]
    draw.polygon(left_wing, fill=(20, 5, 50, 255))

    # 망토 오른쪽 날개
    right_wing = [
        (s(724), s(580)),
        (s(944), s(700)),
        (s(964), s(900)),
        (s(844), s(820)),
        (s(604), s(650)),
    ]
    draw.polygon(right_wing, fill=(20, 5, 50, 255))

    # 망토 하이라이트 라인
    draw.line([(s(512), s(620)), (s(512), s(850))], fill=cape_highlight, width=s(3))
    draw.line([(s(512), s(620)), (s(120), s(870))], fill=(35, 8, 65, 255), width=s(2))
    draw.line([(s(512), s(620)), (s(904), s(870))], fill=(35, 8, 65, 255), width=s(2))

    # ── 셔츠 / 가슴 ──
    # 하얀 셔츠 앞면
    shirt_points = [
        (s(420), s(590)),
        (s(604), s(590)),
        (s(620), s(680)),
        (s(512), s(700)),
        (s(404), s(680)),
    ]
    draw.polygon(shirt_points, fill=(230, 220, 240, 255))

    # 셔츠 주름
    draw.line([(s(512), s(590)), (s(512), s(700))], fill=(180, 170, 195, 255), width=s(2))
    draw.line([(s(470), s(595)), (s(460), s(690))], fill=(180, 170, 195, 255), width=s(1))
    draw.line([(s(554), s(595)), (s(564), s(690))], fill=(180, 170, 195, 255), width=s(1))

    # 리본/넥타이
    ribbon_points = [
        (s(490), s(575)),
        (s(534), s(575)),
        (s(525), s(615)),
        (s(512), s(625)),
        (s(499), s(615)),
    ]
    draw.polygon(ribbon_points, fill=(180, 20, 20, 255))

    # 망토 칼라 (빨간 안쪽)
    collar_l = [(s(380), s(560)), (s(250), s(520)), (s(320), s(580)), (s(430), s(600))]
    collar_r = [(s(644), s(560)), (s(774), s(520)), (s(704), s(580)), (s(594), s(600))]
    draw.polygon(collar_l, fill=(160, 15, 15, 255))
    draw.polygon(collar_r, fill=(160, 15, 15, 255))

    # ── 얼굴 (동그란 이모지 스타일) ──
    # 얼굴 그림자/깊이
    face_cx, face_cy = S//2, s(390)
    face_r = s(220)

    # 얼굴 그림자 레이어
    shadow_layer = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow_layer)
    shadow_draw.ellipse([face_cx - face_r + s(8), face_cy - face_r + s(8),
                         face_cx + face_r + s(8), face_cy + face_r + s(8)],
                        fill=(10, 0, 30, 120))
    shadow_layer = shadow_layer.filter(ImageFilter.GaussianBlur(s(12)))
    img = Image.alpha_composite(img, shadow_layer)
    draw = ImageDraw.Draw(img)

    # 얼굴 메인 (창백한 피부)
    face_color = (235, 220, 245, 255)
    draw.ellipse([face_cx - face_r, face_cy - face_r,
                  face_cx + face_r, face_cy + face_r],
                 fill=face_color)

    # 얼굴 하이라이트 (왼쪽 상단 빛)
    highlight_layer = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    hl_draw = ImageDraw.Draw(highlight_layer)
    hl_draw.ellipse([face_cx - face_r + s(30), face_cy - face_r + s(20),
                     face_cx + s(40), face_cy + s(60)],
                    fill=(255, 250, 255, 60))
    highlight_layer = highlight_layer.filter(ImageFilter.GaussianBlur(s(25)))
    img = Image.alpha_composite(img, highlight_layer)
    draw = ImageDraw.Draw(img)

    # 얼굴 외곽선
    draw.ellipse([face_cx - face_r, face_cy - face_r,
                  face_cx + face_r, face_cy + face_r],
                 outline=(180, 150, 200, 255), width=s(3))

    # ── 머리카락 ──
    # 검은 머리 - 상단
    hair_color = (20, 10, 35, 255)
    hair_highlight = (60, 30, 90, 255)

    # 머리카락 메인 (얼굴 상단 덮기)
    draw.ellipse([face_cx - face_r - s(10), face_cy - face_r - s(15),
                  face_cx + face_r + s(10), face_cy - s(40)],
                 fill=hair_color)

    # 앞머리 - 중앙 가르마
    hair_top = [
        (face_cx - face_r - s(5), face_cy - face_r + s(30)),
        (face_cx - s(80), face_cy - face_r + s(80)),
        (face_cx - s(20), face_cy - face_r + s(105)),
        (face_cx, face_cy - face_r + s(110)),
        (face_cx + s(20), face_cy - face_r + s(105)),
        (face_cx + s(80), face_cy - face_r + s(80)),
        (face_cx + face_r + s(5), face_cy - face_r + s(30)),
        (face_cx + face_r + s(10), face_cy - face_r - s(10)),
        (face_cx - face_r - s(10), face_cy - face_r - s(10)),
    ]
    draw.polygon(hair_top, fill=hair_color)

    # 머리카락 하이라이트
    draw.arc([face_cx - face_r + s(30), face_cy - face_r - s(10),
              face_cx - s(20), face_cy - face_r + s(60)],
             start=200, end=310, fill=hair_highlight, width=s(4))

    # 옆머리 (귀 옆)
    draw.ellipse([face_cx - face_r - s(30), face_cy - s(80),
                  face_cx - face_r + s(30), face_cy + s(60)],
                 fill=hair_color)
    draw.ellipse([face_cx + face_r - s(30), face_cy - s(80),
                  face_cx + face_r + s(30), face_cy + s(60)],
                 fill=hair_color)

    # ── 귀 ──
    ear_color = (225, 210, 235, 255)
    ear_inner = (200, 180, 215, 255)
    # 왼쪽 귀
    draw.ellipse([face_cx - face_r - s(20), face_cy - s(30),
                  face_cx - face_r + s(30), face_cy + s(40)],
                 fill=ear_color)
    draw.ellipse([face_cx - face_r - s(10), face_cy - s(18),
                  face_cx - face_r + s(18), face_cy + s(28)],
                 fill=ear_inner)
    # 오른쪽 귀
    draw.ellipse([face_cx + face_r - s(30), face_cy - s(30),
                  face_cx + face_r + s(20), face_cy + s(40)],
                 fill=ear_color)
    draw.ellipse([face_cx + face_r - s(18), face_cy - s(18),
                  face_cx + face_r + s(10), face_cy + s(28)],
                 fill=ear_inner)

    # ── 눈썹 (굵고 짙은) ──
    brow_color = (25, 10, 40, 255)
    # 왼쪽 눈썹 (약간 찡그린)
    for i in range(s(6)):
        draw.arc([face_cx - s(150), face_cy - s(90) + i,
                  face_cx - s(30), face_cy - s(30) + i],
                 start=200, end=330, fill=brow_color, width=s(3))
    # 오른쪽 눈썹
    for i in range(s(6)):
        draw.arc([face_cx + s(30), face_cy - s(90) + i,
                  face_cx + s(150), face_cy - s(30) + i],
                 start=210, end=340, fill=brow_color, width=s(3))

    # ── 눈 (빨간 눈) ──
    eye_white = (255, 248, 255, 255)
    eye_iris = (200, 20, 20, 255)
    eye_pupil = (80, 0, 0, 255)
    eye_glow = (255, 80, 80, 160)

    # 왼쪽 눈
    left_eye_cx = face_cx - s(85)
    left_eye_cy = face_cy - s(20)
    eye_w, eye_h = s(75), s(55)

    # 눈 흰자
    draw.ellipse([left_eye_cx - eye_w//2, left_eye_cy - eye_h//2,
                  left_eye_cx + eye_w//2, left_eye_cy + eye_h//2],
                 fill=eye_white)
    # 홍채 (빨간)
    iris_r = s(28)
    draw.ellipse([left_eye_cx - iris_r, left_eye_cy - iris_r,
                  left_eye_cx + iris_r, left_eye_cy + iris_r],
                 fill=eye_iris)
    # 동공
    pupil_r = s(14)
    draw.ellipse([left_eye_cx - pupil_r, left_eye_cy - pupil_r,
                  left_eye_cx + pupil_r, left_eye_cy + pupil_r],
                 fill=eye_pupil)
    # 눈 하이라이트
    draw.ellipse([left_eye_cx - s(7), left_eye_cy - s(12),
                  left_eye_cx - s(1), left_eye_cy - s(6)],
                 fill=(255, 200, 200, 220))
    # 눈꺼풀 라인
    draw.arc([left_eye_cx - eye_w//2, left_eye_cy - eye_h//2,
              left_eye_cx + eye_w//2, left_eye_cy + eye_h//2],
             start=200, end=340, fill=(30, 10, 50, 200), width=s(3))

    # 눈 글로우
    glow_layer = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow_layer)
    glow_r = s(35)
    glow_draw.ellipse([left_eye_cx - glow_r, left_eye_cy - glow_r,
                       left_eye_cx + glow_r, left_eye_cy + glow_r],
                      fill=eye_glow)
    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(s(8)))
    # 글로우를 눈 아래 레이어로

    # 오른쪽 눈
    right_eye_cx = face_cx + s(85)
    right_eye_cy = face_cy - s(20)

    draw.ellipse([right_eye_cx - eye_w//2, right_eye_cy - eye_h//2,
                  right_eye_cx + eye_w//2, right_eye_cy + eye_h//2],
                 fill=eye_white)
    draw.ellipse([right_eye_cx - iris_r, right_eye_cy - iris_r,
                  right_eye_cx + iris_r, right_eye_cy + iris_r],
                 fill=eye_iris)
    draw.ellipse([right_eye_cx - pupil_r, right_eye_cy - pupil_r,
                  right_eye_cx + pupil_r, right_eye_cy + pupil_r],
                 fill=eye_pupil)
    draw.ellipse([right_eye_cx - s(7), right_eye_cy - s(12),
                  right_eye_cx - s(1), right_eye_cy - s(6)],
                 fill=(255, 200, 200, 220))
    draw.arc([right_eye_cx - eye_w//2, right_eye_cy - eye_h//2,
              right_eye_cx + eye_w//2, right_eye_cy + eye_h//2],
             start=200, end=340, fill=(30, 10, 50, 200), width=s(3))

    # ── 코 ──
    nose_color = (200, 185, 215, 255)
    draw.ellipse([face_cx - s(15), face_cy + s(30),
                  face_cx + s(15), face_cy + s(55)],
                 fill=nose_color)
    draw.ellipse([face_cx - s(28), face_cy + s(38),
                  face_cx - s(10), face_cy + s(55)],
                 fill=(185, 168, 200, 255))
    draw.ellipse([face_cx + s(10), face_cy + s(38),
                  face_cx + s(28), face_cy + s(55)],
                 fill=(185, 168, 200, 255))

    # ── 입 (미소 + 송곳니) ──
    mouth_cx, mouth_cy = face_cx, face_cy + s(100)

    # 입술
    # 윗입술
    upper_lip = [
        (face_cx - s(70), mouth_cy),
        (face_cx - s(35), mouth_cy - s(15)),
        (face_cx - s(10), mouth_cy - s(5)),
        (face_cx, mouth_cy - s(8)),
        (face_cx + s(10), mouth_cy - s(5)),
        (face_cx + s(35), mouth_cy - s(15)),
        (face_cx + s(70), mouth_cy),
        (face_cx + s(55), mouth_cy + s(5)),
        (face_cx, mouth_cy + s(8)),
        (face_cx - s(55), mouth_cy + s(5)),
    ]
    draw.polygon(upper_lip, fill=(180, 60, 80, 255))

    # 아래입술
    lower_lip = [
        (face_cx - s(70), mouth_cy),
        (face_cx - s(55), mouth_cy + s(5)),
        (face_cx, mouth_cy + s(8)),
        (face_cx + s(55), mouth_cy + s(5)),
        (face_cx + s(70), mouth_cy),
        (face_cx + s(60), mouth_cy + s(30)),
        (face_cx, mouth_cy + s(38)),
        (face_cx - s(60), mouth_cy + s(30)),
    ]
    draw.polygon(lower_lip, fill=(200, 80, 100, 255))

    # 입 내부 (어두운)
    mouth_inner = [
        (face_cx - s(58), mouth_cy + s(5)),
        (face_cx + s(58), mouth_cy + s(5)),
        (face_cx + s(50), mouth_cy + s(28)),
        (face_cx, mouth_cy + s(35)),
        (face_cx - s(50), mouth_cy + s(28)),
    ]
    draw.polygon(mouth_inner, fill=(60, 10, 20, 255))

    # 송곳니 (왼쪽)
    fang_l = [
        (face_cx - s(38), mouth_cy + s(5)),
        (face_cx - s(22), mouth_cy + s(5)),
        (face_cx - s(25), mouth_cy + s(38)),
        (face_cx - s(38), mouth_cy + s(42)),
    ]
    draw.polygon(fang_l, fill=(245, 238, 250, 255))
    # 송곳니 하이라이트
    draw.line([(face_cx - s(34), mouth_cy + s(7)),
               (face_cx - s(34), mouth_cy + s(36))],
              fill=(255, 255, 255, 180), width=s(2))

    # 송곳니 (오른쪽)
    fang_r = [
        (face_cx + s(22), mouth_cy + s(5)),
        (face_cx + s(38), mouth_cy + s(5)),
        (face_cx + s(38), mouth_cy + s(42)),
        (face_cx + s(25), mouth_cy + s(38)),
    ]
    draw.polygon(fang_r, fill=(245, 238, 250, 255))
    draw.line([(face_cx + s(34), mouth_cy + s(7)),
               (face_cx + s(34), mouth_cy + s(36))],
              fill=(255, 255, 255, 180), width=s(2))

    # 피 흘리는 효과 (왼쪽 송곳니)
    blood_color = (180, 10, 20, 255)
    draw.line([(face_cx - s(30), mouth_cy + s(42)),
               (face_cx - s(32), mouth_cy + s(65)),
               (face_cx - s(28), mouth_cy + s(80))],
              fill=blood_color, width=s(4))
    draw.ellipse([face_cx - s(34), mouth_cy + s(76),
                  face_cx - s(24), mouth_cy + s(86)],
                 fill=blood_color)

    # ── 눈 글로우 효과 (후처리) ──
    glow_layer2 = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow_layer2)
    # 왼쪽 눈 글로우
    gd.ellipse([left_eye_cx - s(40), left_eye_cy - s(40),
                left_eye_cx + s(40), left_eye_cy + s(40)],
               fill=(255, 30, 30, 80))
    # 오른쪽 눈 글로우
    gd.ellipse([right_eye_cx - s(40), right_eye_cy - s(40),
                right_eye_cx + s(40), right_eye_cy + s(40)],
               fill=(255, 30, 30, 80))
    glow_layer2 = glow_layer2.filter(ImageFilter.GaussianBlur(s(15)))
    img = Image.alpha_composite(img, glow_layer2)
    draw = ImageDraw.Draw(img)

    # ── 박쥐 (장식) - 작은 배경 박쥐들 ──
    def draw_bat(draw, cx, cy, size, color):
        """작은 박쥐 그리기"""
        # 몸통
        draw.ellipse([cx - size//4, cy - size//4, cx + size//4, cy + size//4],
                     fill=color)
        # 왼쪽 날개
        wing_l = [
            (cx, cy - size//8),
            (cx - size, cy - size//3),
            (cx - size*3//4, cy + size//6),
            (cx - size//2, cy),
            (cx - size//4, cy + size//8),
        ]
        draw.polygon(wing_l, fill=color)
        # 오른쪽 날개
        wing_r = [
            (cx, cy - size//8),
            (cx + size, cy - size//3),
            (cx + size*3//4, cy + size//6),
            (cx + size//2, cy),
            (cx + size//4, cy + size//8),
        ]
        draw.polygon(wing_r, fill=color)
        # 귀
        draw.polygon([(cx - size//6, cy - size//4),
                      (cx - size//3, cy - size//2),
                      (cx - size//12, cy - size//5)], fill=color)
        draw.polygon([(cx + size//6, cy - size//4),
                      (cx + size//3, cy - size//2),
                      (cx + size//12, cy - size//5)], fill=color)

    bat_color = (60, 20, 90, 180)
    draw_bat(draw, s(150), s(200), s(55), bat_color)
    draw_bat(draw, s(870), s(180), s(45), bat_color)
    draw_bat(draw, s(100), s(500), s(35), (50, 15, 75, 120))
    draw_bat(draw, s(920), s(450), s(40), (50, 15, 75, 120))

    # ── 별/달빛 파티클 ──
    star_color = (200, 180, 255, 150)
    stars = [
        (s(80), s(100)), (s(200), s(60)), (s(800), s(80)),
        (s(950), s(120)), (s(50), s(350)), (s(970), s(300)),
        (s(150), s(750)), (s(900), s(700)),
    ]
    for sx, sy in stars:
        r = s(4)
        draw.ellipse([sx-r, sy-r, sx+r, sy+r], fill=star_color)

    # ── 최종 테두리 효과 ──
    border_layer = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    bd = ImageDraw.Draw(border_layer)
    corner_r2 = s(180)
    bd.rounded_rectangle([0, 0, S-1, S-1], radius=corner_r2,
                          fill=None, outline=(120, 60, 180, 80), width=s(4))
    img = Image.alpha_composite(img, border_layer)

    return img


def generate_all_icons():
    """모든 사이즈 아이콘 생성"""
    base_dir = '/Users/jhkim/Desktop/workspace/screen-guilty/ScreenGuilty/Assets.xcassets/AppIcon.appiconset'

    sizes = {
        'icon_16x16.png': 16,
        'icon_16x16@2x.png': 32,
        'icon_32x32.png': 32,
        'icon_32x32@2x.png': 64,
        'icon_128x128.png': 128,
        'icon_128x128@2x.png': 256,
        'icon_256x256.png': 256,
        'icon_256x256@2x.png': 512,
        'icon_512x512.png': 512,
        'icon_512x512@2x.png': 1024,
        'icon_1024x1024.png': 1024,
        'AppIcon.png': 1024,
    }

    print("🧛 뱀파이어 아이콘 생성 시작...")

    # 1024px 마스터 이미지 생성
    print("  마스터 이미지 (1024px) 생성 중...")
    master = create_vampire_icon(1024)
    master.save(os.path.join(base_dir, 'icon_1024x1024.png'))
    master.save(os.path.join(base_dir, 'AppIcon.png'))
    print("  ✓ 1024px 저장 완료")

    # 나머지 사이즈 리샘플링
    for filename, size in sizes.items():
        if filename in ('icon_1024x1024.png', 'AppIcon.png'):
            continue
        print(f"  {size}px → {filename}")
        if size >= 256:
            # 큰 사이즈는 마스터에서 직접 리샘플
            icon = master.resize((size, size), Image.LANCZOS)
        else:
            # 작은 사이즈는 중간 사이즈에서 단계적으로
            intermediate = master.resize((size * 4, size * 4), Image.LANCZOS)
            icon = intermediate.resize((size, size), Image.LANCZOS)
        icon.save(os.path.join(base_dir, filename))

    # icns 파일 업데이트 (iconutil 사용)
    print("\n  icns 파일 생성 시도...")
    icns_dir = '/tmp/vampire_icon.iconset'
    os.makedirs(icns_dir, exist_ok=True)

    icns_sizes = {
        'icon_16x16.png': 16,
        'icon_16x16@2x.png': 32,
        'icon_32x32.png': 32,
        'icon_32x32@2x.png': 64,
        'icon_128x128.png': 128,
        'icon_128x128@2x.png': 256,
        'icon_256x256.png': 256,
        'icon_256x256@2x.png': 512,
        'icon_512x512.png': 512,
        'icon_512x512@2x.png': 1024,
    }

    for filename, size in icns_sizes.items():
        src = os.path.join(base_dir, filename)
        dst = os.path.join(icns_dir, filename)
        import shutil
        shutil.copy2(src, dst)

    print("✅ 모든 아이콘 생성 완료!")


if __name__ == '__main__':
    generate_all_icons()
