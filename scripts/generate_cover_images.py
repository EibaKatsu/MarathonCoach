from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parent.parent
BASE_IMAGE = ROOT / "assets" / "UI_Image.png"
OUTPUT_DIR = ROOT / "assets" / "store_shots"
NORMAL_OUTPUT = OUTPUT_DIR / "cover_normal.png"
BETA_OUTPUT = OUTPUT_DIR / "cover_beta.png"

FONT_CANDIDATES = [
    "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc",
    "/System/Library/Fonts/HelveticaNeue.ttc",
    "/Library/Fonts/Arial Unicode.ttf",
]


def load_font(size: int) -> ImageFont.FreeTypeFont:
    for candidate in FONT_CANDIDATES:
        path = Path(candidate)
        if path.exists():
            return ImageFont.truetype(str(path), size=size)
    return ImageFont.load_default()


def add_shadow(base: Image.Image, bounds: tuple[int, int, int, int], radius: int = 18) -> None:
    shadow = Image.new("RGBA", base.size, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    x0, y0, x1, y1 = bounds
    shadow_draw.rounded_rectangle((x0 + 6, y0 + 10, x1 + 6, y1 + 10), radius=radius, fill=(0, 0, 0, 72))
    shadow = shadow.filter(ImageFilter.GaussianBlur(12))
    base.alpha_composite(shadow)


def draw_badge(draw: ImageDraw.ImageDraw, bounds: tuple[int, int, int, int], fill: tuple[int, int, int, int], text: str) -> None:
    font = load_font(34)
    draw.rounded_rectangle(bounds, radius=24, fill=fill)
    bbox = draw.textbbox((0, 0), text, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    x0, y0, x1, y1 = bounds
    draw.text(
        (x0 + ((x1 - x0) - text_w) / 2, y0 + ((y1 - y0) - text_h) / 2 - 2),
        text,
        font=font,
        fill=(255, 255, 255, 255),
    )


def build_cover(beta: bool) -> Image.Image:
    image = Image.open(BASE_IMAGE).convert("RGBA")
    overlay = Image.new("RGBA", image.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)

    accent = (32, 145, 214, 255)
    accent_soft = (225, 244, 255, 240)
    beta_accent = (234, 108, 37, 255)
    beta_soft = (255, 243, 234, 246)

    badge_bounds = (70, 54, 380, 124)
    panel_bounds = (70, 132, 760, 482)
    subpanel_bounds = (70, 830, 1466, 962)

    add_shadow(overlay, panel_bounds)
    add_shadow(overlay, subpanel_bounds)

    draw_badge(draw, badge_bounds, beta_accent if beta else accent, "PUBLIC BETA" if beta else "STORE COVER")
    draw.rounded_rectangle(panel_bounds, radius=36, fill=beta_soft if beta else accent_soft)
    draw.rounded_rectangle(subpanel_bounds, radius=32, fill=(12, 18, 26, 218))

    title_font = load_font(78)
    body_font = load_font(34)
    small_font = load_font(28)
    strong_font = load_font(44)

    title = "実機テスト\n運用中" if beta else "レース中の\n迷いを減らす"
    title_color = beta_accent if beta else accent
    draw.multiline_text((112, 168), title, font=title_font, fill=title_color, spacing=4)

    body_lines = (
        [
            "公開前の実機テスト版です。",
            "安定版ではありません。",
            "対応機種と設定導線の確認用です。",
        ]
        if beta
        else [
            "ペース調整と補給タイミングを1画面でガイド。",
            "Garminレース中の判断負荷を減らし、",
            "走りに集中できます。",
        ]
    )
    y = 322
    for line in body_lines:
        draw.text((116, y), line, font=body_font, fill=(25, 33, 42, 255))
        y += 54

    subtext = (
        "BETA listing changes title, description and cover only."
        if beta
        else "Normal listing cover. Shared screenshots and icon remain unchanged."
    )
    draw.text((112, 854), subtext, font=small_font, fill=(255, 255, 255, 220))
    draw.text((112, 896), "PACE + FUEL GUIDE", font=strong_font, fill=(255, 255, 255, 255))

    if beta:
        draw_badge(draw, (1188, 854, 1438, 930), beta_accent, "TEST BUILD")
    else:
        draw_badge(draw, (1210, 854, 1438, 930), accent, "READY")

    return Image.alpha_composite(image, overlay)


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    build_cover(beta=False).save(NORMAL_OUTPUT)
    build_cover(beta=True).save(BETA_OUTPUT)
    print(f"generated: {NORMAL_OUTPUT}")
    print(f"generated: {BETA_OUTPUT}")


if __name__ == "__main__":
    main()
