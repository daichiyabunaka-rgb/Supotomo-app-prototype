"""スポとも！配布用アプリアイコン（1024px）を作るスクリプト。
Pillow でフラットデザインのサッカーボール（白ボディ + 黒五角形パッチ + スピード線）を描く。生成物:
  - app/assets/icon/app_icon.png      （flutter_launcher_icons のソース）
"""
from PIL import Image, ImageDraw

SIZE = 1024
BG = (232, 236, 242)        # ライトグレー（シリーズ共通の落ち着いた背景色）
BALL = (46, 58, 74)          # ボールの縁（ダークネイビー）
PATCH = (46, 58, 74)         # 中央の五角形パッチ
WHITE = (250, 250, 250)      # ボール本体
ACCENT = (245, 158, 11)     # 走行のスピード線（オレンジ）


def rounded(im: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", im.size, 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=radius, fill=255)
    out = Image.new("RGBA", im.size, (0, 0, 0, 0))
    out.paste(im, (0, 0), mask)
    return out


def _pentagon(cx, cy, r):
    import math
    pts = []
    for i in range(5):
        a = -math.pi / 2 + i * 2 * math.pi / 5
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


def draw_ball():
    im = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)

    # 背景（角丸ライトグレー）
    d.rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=192, fill=BG + (255,))

    # ボール本体（白円 + ネイビーの縁）
    d.ellipse([172, 232, 672, 732], fill=WHITE + (255,), outline=BALL + (255,), width=22)

    # 中央の五角形パッチ（サッカーボールの模様）
    d.polygon(_pentagon(422, 482, 120), fill=PATCH + (255,))

    # 周囲の模様（上下左右の小さなパッチ）
    for px, py in [(422, 302), (292, 592), (552, 592)]:
        d.polygon(_pentagon(px, py, 74), fill=PATCH + (255,))

    # 走行のスピード線（オレンジ。ボールの左側に3本）
    for i, y in enumerate((372, 462, 552)):
        d.line([(80, y), (150 - (i % 2) * 20, y)], fill=ACCENT + (255,), width=22)

    return im


if __name__ == "__main__":
    im = draw_ball()
    im = rounded(im, 192)
    out = r"..\app\assets\icon\app_icon.png"
    im.save(out)
    print("saved:", out)
