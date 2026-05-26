#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from html import escape
from pathlib import Path
import shutil
from typing import Any

import yaml


BASE_URL = "https://racenavi.jpn.org"
SITE_DIR = Path(__file__).resolve().parents[1]
REPO_DIR = SITE_DIR.parents[1]
RACE_DEFS_DIR = REPO_DIR / "apps" / "GateChecker" / "race_defs"


def versioned_asset_url(public_path: str, source_path: Path) -> str:
    stamp = int(source_path.stat().st_mtime)
    return f"{public_path}?v={stamp}"


ASSET_SYNC_MAP = {
    REPO_DIR / "assets" / "store_shots" / "mainIcon.png": SITE_DIR / "assets" / "mainIcon.png",
    REPO_DIR / "assets" / "store_shots" / "heroImage_jpn.png": SITE_DIR / "assets" / "heroImage_jpn.png",
    REPO_DIR / "assets" / "store_shots" / "heroImage_eng.png": SITE_DIR / "assets" / "heroImage_eng.png",
    REPO_DIR / "assets" / "store_shots" / "screen_discription.jpg": SITE_DIR / "assets" / "screen_discription.jpg",
    REPO_DIR / "assets" / "store_shots" / "shot05_four_settings.jpg": SITE_DIR / "assets" / "shot05_four_settings.jpg",
    REPO_DIR / "apps" / "GateChecker" / "assets" / "RunToCoal_Image.png": SITE_DIR / "assets" / "gatechecker_icon.png",
    REPO_DIR / "apps" / "GateChecker" / "assets" / "GateChecker_Hero_Image_jp.png": SITE_DIR / "assets" / "GateChecker_Hero_Image_jp.png",
    REPO_DIR / "apps" / "GateChecker" / "assets" / "GateChecker_Hero_Image_en.png": SITE_DIR / "assets" / "GateChecker_Hero_Image_en.png",
    REPO_DIR / "apps" / "GateChecker" / "assets" / "screen_image.png": SITE_DIR / "assets" / "screen_image.png",
}
RACENAVI_ICON = "/assets/mainIcon.png"
RACENAVI_HERO_JA = "/assets/heroImage_jpn.png"
RACENAVI_HERO_EN = "/assets/heroImage_eng.png"
RACENAVI_SCREEN_IMAGE = "/assets/screen_discription.jpg"
RACENAVI_SETUP_IMAGE = "/assets/shot05_four_settings.jpg"
GATE_ICON = "/assets/gatechecker_icon.png"
GATE_HERO_JA = versioned_asset_url(
    "/assets/GateChecker_Hero_Image_jp.png",
    REPO_DIR / "apps" / "GateChecker" / "assets" / "GateChecker_Hero_Image_jp.png",
)
GATE_HERO_EN = versioned_asset_url(
    "/assets/GateChecker_Hero_Image_en.png",
    REPO_DIR / "apps" / "GateChecker" / "assets" / "GateChecker_Hero_Image_en.png",
)
GATE_SCREEN_IMAGE = versioned_asset_url(
    "/assets/screen_image.png",
    REPO_DIR / "apps" / "GateChecker" / "assets" / "screen_image.png",
)
FAVICON_IMAGE = RACENAVI_ICON
OG_IMAGE = f"{BASE_URL}{RACENAVI_HERO_JA}"
X_URL = "https://x.com/racenavi_run"
RACENAVI_CONNECT_IQ_JA = "https://apps.garmin.com/ja-JP/apps/00ebf0d8-4f9f-47d0-a59c-27f9b286c830"
RACENAVI_CONNECT_IQ_EN = "https://apps.garmin.com/apps/00ebf0d8-4f9f-47d0-a59c-27f9b286c830"
GATE_CONNECT_IQ_URL = "https://apps.garmin.com/ja-JP/apps/8424ea31-8acc-4bfe-9548-defecf1eb018"
BUY_ME_A_COFFEE_URL = "https://buymeacoffee.com/racenavi"
STRIPE_PAYMENT_LINK_MARATHON = "https://buy.stripe.com/cNibJ2bRW571a9YcBP8IU00"
STRIPE_PAYMENT_LINK_ULTRA_TRAIL = STRIPE_PAYMENT_LINK_MARATHON
PAID_RACE_CODE_PRICE = "US$4"
GARMIN_LACTATE_THRESHOLD_URL = "https://www.garmin.com/en-XD/garmin-technology/running-science/physiological-measurements/lactate-threshold/"
GARMIN_HR_ZONES_URL = "https://support.garmin.com/en-US/?faq=s3HqdKNtWV1NYrK16eFcc7"
GOOGLE_FORM_URL_JA = "https://forms.gle/xy492imp9MCXxNRP7"
GOOGLE_FORM_URL_EN = "https://forms.gle/m2k85w17z62gnCP37"
FREE_SAMPLE_RACE_CODES = {
    "20260503_bmo_vancouver_marathon": [
        {
            "course": {"ja": "フルマラソン", "en": "Marathon"},
            "code": "BMO26-F42-2QTP",
        },
    ],
    "20260524_kurobe_meisui_marathon": [
        {
            "course": {"ja": "フルマラソン", "en": "Marathon"},
            "code": "KURO26-F42-M1AF",
        },
    ],
    "20260531_nara_ultra_marathon": [
        {
            "course": {"ja": "100km", "en": "100km"},
            "code": "NARA26-100K-R7P4",
        },
    ],
    "20260614_hida_takayama_ultramarathon": [
        {
            "course": {"ja": "100km WAVE A", "en": "100 km Wave A"},
            "code": "HIDA26-100A-K7P2",
        },
        {
            "course": {"ja": "100km WAVE B", "en": "100 km Wave B"},
            "code": "HIDA26-100B-R8M4",
        },
        {
            "course": {"ja": "71km WAVE C", "en": "71 km Wave C"},
            "code": "HIDA26-71C-N9Q5",
        },
    ],
}


@dataclass
class Course:
    code: str
    race_code: str
    name_ja: str
    name_en: str
    distance_label_ja: str
    distance_label_en: str
    start_time: str
    notes_ja: str
    notes_en: str
    gates: list[dict[str, Any]]
    aids: list[dict[str, Any]]


@dataclass
class Race:
    slug: str
    name_ja: str
    name_en: str
    date: str
    timezone: str
    sample_free: bool
    country_ja: str
    country_en: str
    connect_iq_url_ja: str | None
    connect_iq_url_en: str | None
    courses: list[Course]


def load_yaml(path: Path) -> dict[str, Any]:
    return yaml.safe_load(path.read_text(encoding="utf-8")) or {}


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def write_text(path: Path, text: str) -> None:
    ensure_dir(path.parent)
    normalized = "\n".join(line.rstrip() for line in text.splitlines())
    path.write_text(normalized.rstrip() + "\n", encoding="utf-8")


def sync_assets() -> None:
    for source, destination in ASSET_SYNC_MAP.items():
        ensure_dir(destination.parent)
        if source.exists():
            shutil.copy2(source, destination)
        elif not destination.exists():
            raise FileNotFoundError(f"Missing asset source: {source}")


def cleanup_stale_race_dirs(root: Path, keep_slugs: set[str]) -> int:
    ensure_dir(root)
    removed = 0
    for child in root.iterdir():
        if child.is_dir() and child.name not in keep_slugs:
            shutil.rmtree(child)
            removed += 1
    return removed


def normalize_text(value: Any) -> str:
    if not isinstance(value, str):
        return ""
    return value.strip()


def normalize_url(value: Any) -> str | None:
    text = normalize_text(value)
    if not text:
        return None
    return text


def first_non_empty(*values: Any) -> str:
    for value in values:
        text = normalize_text(value)
        if text:
            return text
    return ""


def fmt_num(value: float) -> str:
    return f"{value:.3f}".rstrip("0").rstrip(".")


def mi_to_km(value: float) -> float:
    return value * 1.609344


def distance_label(value: float, unit: str) -> str:
    if unit == "km":
        return f"{fmt_num(value)} km"
    return f"{fmt_num(value)} mi / {fmt_num(mi_to_km(value))} km"


def localized_name(value: Any, lang: str, fallback: str = "") -> str:
    if isinstance(value, dict):
        return first_non_empty(
            value.get("jpn" if lang == "ja" else "eng"),
            value.get("ja" if lang == "ja" else "en"),
            value.get("eng"),
            value.get("jpn"),
            value.get("en"),
            value.get("ja"),
            fallback,
        )
    if isinstance(value, str):
        return value
    return fallback


def resolve_country(timezone: str) -> tuple[str, str]:
    by_timezone = {
        "Asia/Tokyo": ("日本", "Japan"),
        "America/Vancouver": ("カナダ", "Canada"),
        "America/Toronto": ("カナダ", "Canada"),
        "America/Chicago": ("アメリカ", "United States"),
        "America/New_York": ("アメリカ", "United States"),
        "Europe/Stockholm": ("スウェーデン", "Sweden"),
        "Europe/London": ("イギリス", "United Kingdom"),
        "Europe/Oslo": ("ノルウェー", "Norway"),
        "Europe/Luxembourg": ("ルクセンブルク", "Luxembourg"),
    }
    return by_timezone.get(timezone, ("その他", "Other"))


def is_public_race(slug: str, name_ja: str, name_en: str) -> bool:
    lowered = f"{slug} {name_ja} {name_en}".lower()
    blocked_tokens = ["sample", "beta", "check", "確認用"]
    return not any(token in lowered for token in blocked_tokens)


def absolute_url(path: str) -> str:
    if path == "/":
        return f"{BASE_URL}/"
    return f"{BASE_URL}{path}"


def external_attrs() -> str:
    return ' target="_blank" rel="noreferrer"'


def button_link(href: str, label: str, kind: str = "primary", external: bool = False) -> str:
    attrs = external_attrs() if external else ""
    return f'<a class="button button-{kind}" href="{escape(href)}"{attrs}>{escape(label)}</a>'


def button_placeholder(label: str, kind: str = "secondary") -> str:
    return f'<span class="button button-{kind} button-disabled" aria-disabled="true">{escape(label)}</span>'


def link_ready(url: str | None) -> bool:
    return bool(url and url.startswith(("https://", "http://")))


def google_form_url(lang: str) -> str:
    return GOOGLE_FORM_URL_JA if lang == "ja" else GOOGLE_FORM_URL_EN


def google_form_ready(lang: str) -> bool:
    return link_ready(google_form_url(lang))


def request_form_button(label: str, lang: str, kind: str = "primary") -> str:
    return button_link(google_form_url(lang), label, kind, external=google_form_ready(lang))


def optional_link_button(url: str | None, label: str, lang: str, kind: str = "primary") -> str:
    if link_ready(url):
        return button_link(str(url), label, kind, external=True)
    pending = "リンク準備中" if lang == "ja" else "Link coming soon"
    return button_placeholder(pending, kind)


def render_todo_note(value: str | None, lang: str) -> str:
    if not value or link_ready(value):
        return ""
    prefix = "現在のプレースホルダー" if lang == "ja" else "Current placeholder"
    return f'<p class="todo-note">{escape(prefix)}: <code>{escape(value)}</code></p>'


def render_request_form_status(lang: str) -> str:
    return ""


def render_paid_code_pricing_cards(lang: str) -> str:
    if lang == "ja":
        cards = [
            ("すべてのRace Code", PAID_RACE_CODE_PRICE, "フルマラソン / ウルトラ / トレイル共通"),
            ("案内方法", "手動", "購入後にRace Codeをメールで案内"),
        ]
    else:
        cards = [
            ("All Race Codes", PAID_RACE_CODE_PRICE, "Same price for marathon, ultra, and trail"),
            ("Delivery", "Manual", "Race Code is sent after purchase"),
        ]

    return "".join(
        f"""
          <article class="pricing-card">
            <span class="meta-pill">{escape(label)}</span>
            <strong class="pricing-amount">{escape(amount)}</strong>
            <p class="pricing-note">{escape(note)}</p>
          </article>
"""
        for label, amount, note in cards
    )


def render_request_flow_steps(lang: str) -> str:
    if lang == "ja":
        steps = [
            "フォームで大会名とURLを送る",
            "こちらで公式サイトや要項から関門とエイドを拾う",
            "情報が足りるか、使う人がいそうかを見て順番を決める",
            "対応できる大会からRace Codeを追加する",
            "公開できたらこのサイトで案内する",
        ]
    else:
        steps = [
            "Send your request through the Google Form.",
            "Review the official website or race guide PDF.",
            "Prioritize races with clear official data and stronger demand.",
            "Add or update the Race Code when the race can be supported.",
            "Publish the available code or status update on this website.",
        ]

    return "".join(
        f"""
          <article class="step-card">
            <span class="step-number">{index}</span>
            <p>{escape(step)}</p>
          </article>
"""
        for index, step in enumerate(steps, start=1)
    )


def render_request_faq(lang: str) -> str:
    if lang == "ja":
        items = [
            (
                "Q. お金を払った人だけが使えるアプリですか？",
                "A. いいえ。完成後はConnect IQで公開するため、他のランナーもダウンロードできる場合があります。依頼者専用アプリではありません。",
            ),
            (
                "Q. 何に対して料金を払うのですか？",
                "A. 希望する大会の公式情報を確認し、関門・エイド情報を整理して、Garminで使える関門ガイドとして作成する作業に対する料金です。",
            ),
            (
                "Q. どんな大会でも作れますか？",
                "A. 公式サイトや大会要項から、関門時刻・関門地点・エイド地点を確認できる大会が対象です。情報が見つからない場合は作成できないことがあります。",
            ),
            (
                "Q. リクエストはどこから送ればいいですか？",
                "A. Googleフォームから送ってください。大会名、公式サイトURL、関門・エイド情報が分かるURLを入力してもらう予定です。",
            ),
            (
                "Q. 支払いはいつですか？",
                "A. フォームで送られた大会情報を確認し、対応できる大会からRace Codeを追加します。立ち上げ初期のため、リクエスト自体は無料で受け付けています。",
            ),
            (
                "Q. 情報が間違っていた場合は？",
                "A. 公開後に誤りに気づいた場合は、フォームまたは別途案内する連絡手段から連絡してください。確認できる範囲で修正します。ただし、大会公式情報の変更や直前変更までは保証できません。",
            ),
            (
                "Q. 大会公式アプリですか？",
                "A. いいえ。Garmin公式、大会公式のアプリではありません。関門・エイド情報は必ず大会公式情報も確認してください。",
            ),
        ]
    else:
        items = [
            (
                "Q. Is this a private app that only the requester can use?",
                "A. No. Once completed, the app is planned to be published on Connect IQ, so other runners may be able to download it as well.",
            ),
            (
                "Q. What am I paying for?",
                "A. You are paying for the work of checking the official race information, organizing the cutoff and aid data, and turning it into a Garmin-ready Cutoff Guide.",
            ),
            (
                "Q. Can you create a guide for any race?",
                "A. The race needs publicly available cutoff times, cutoff points, and aid-station information on the official site or race guide. Some races cannot be created if the information is not available.",
            ),
            (
                "Q. How do I send a request?",
                "A. Requests are accepted through the Google Form. Please send your race name, official website, and any URL that shows cutoff or aid-station information.",
            ),
            (
                "Q. When do I pay?",
                "A. After I review the race information, I prioritize races that can be supported and publish the Race Code on the site when ready. Race requests themselves are currently free during launch.",
            ),
            (
                "Q. What if the information is wrong?",
                "A. If you notice an issue after publication, please use the form or the follow-up contact method. I can correct confirmed issues, but I cannot guarantee organizer-side changes or late updates.",
            ),
            (
                "Q. Is this affiliated with Garmin or the race organizer?",
                "A. No. It is not affiliated with Garmin or the race organizer, and official race information should always be checked as well.",
            ),
        ]

    return "".join(
        f"""
          <article class="faq-card">
            <h3>{escape(question)}</h3>
            <p>{escape(answer)}</p>
          </article>
"""
        for question, answer in items
    )


def render_list(items: list[str]) -> str:
    return "".join(f"<li>{escape(item)}</li>" for item in items)


def render_meta_rows(rows: list[tuple[str, str]]) -> str:
    parts = []
    for label, value in rows:
        if not value:
            continue
        parts.append(
            f'<div class="meta-row"><span class="meta-label">{escape(label)}</span><span>{escape(value)}</span></div>'
        )
    return "".join(parts)


def render_pills(items: list[str]) -> str:
    pills = [f'<span class="meta-pill">{escape(item)}</span>' for item in items if item]
    return "".join(pills)


def render_steps(steps: list[str]) -> str:
    return "".join(
        f"""
          <article class="step-card">
            <span class="step-number">{index}</span>
            <p>{escape(step)}</p>
          </article>
"""
        for index, step in enumerate(steps, start=1)
    )


def is_free_sample_race(race: Race) -> bool:
    return race.slug in FREE_SAMPLE_RACE_CODES or race.sample_free


def free_sample_code_entries(race: Race, lang: str) -> list[tuple[str, str]]:
    manual_entries = FREE_SAMPLE_RACE_CODES.get(race.slug)
    if isinstance(manual_entries, list) and manual_entries:
        items: list[tuple[str, str]] = []
        for entry in manual_entries:
            if not isinstance(entry, dict):
                continue
            course = entry.get("course") or {}
            code = normalize_text(entry.get("code"))
            if not code:
                continue
            label = localized_name(course, lang, "")
            items.append((label, code))
        if items:
            return items

    if race.sample_free:
        return [
            ((course.name_ja if lang == "ja" else course.name_en), course.race_code)
            for course in race.courses
            if course.race_code
        ]

    return []


def race_code_value(race: Race, lang: str) -> str:
    entries = free_sample_code_entries(race, lang)
    if not entries:
        return ""
    if len(entries) == 1:
        return entries[0][1]
    return " / ".join(code for _, code in entries)


def sample_code_count_label(race: Race, lang: str) -> str:
    count = len(free_sample_code_entries(race, lang))
    if count <= 1:
        return race_code_value(race, lang)
    return f"{count} codes published" if lang == "en" else f"{count}コード公開中"


def render_race_code_list(race: Race, lang: str) -> str:
    entries = free_sample_code_entries(race, lang)
    if not entries:
        return ""
    if len(entries) == 1:
        return render_single_code_box(entries[0][1])

    heading = "公開Race Code" if lang == "ja" else "Published Race Codes"
    rows = []
    for label, code in entries:
        label_html = f'<span class="code-label">{escape(label)}</span>' if label else ""
        rows.append(
            '<div class="code-box">'
            f"{label_html}"
            f'<strong class="code-value">{escape(code)}</strong>'
            "</div>"
        )
    return f'<div class="code-list"><span class="code-label">{escape(heading)}</span>{"".join(rows)}</div>'


def render_single_code_box(code_value: str) -> str:
    return (
        '          <div class="code-box">\n'
        '            <span class="code-label">Race Code</span>\n'
        f'            <strong class="code-value">{escape(code_value)}</strong>\n'
        "          </div>"
    )


def is_ultra_or_trail_race(race: Race) -> bool:
    tokens = " ".join([
        race.slug,
        race.name_ja,
        race.name_en,
        *(course.name_ja for course in race.courses),
        *(course.name_en for course in race.courses),
        *(course.distance_label_en for course in race.courses),
    ]).lower()
    ultra_tokens = ["ultra", "trail", "100 km", "50 km", "50 mi", "100mi"]
    return any(token in tokens for token in ultra_tokens)


def race_category_label(race: Race, lang: str) -> str:
    if is_ultra_or_trail_race(race):
        return "ウルトラ / トレイル" if lang == "ja" else "Ultra / Trail"
    return "フルマラソン" if lang == "ja" else "Marathon"


def race_price_label(race: Race, lang: str) -> str:
    if is_free_sample_race(race):
        return "無料" if lang == "ja" else "Free"
    return PAID_RACE_CODE_PRICE


def race_payment_link(race: Race) -> str | None:
    if is_free_sample_race(race):
        return None
    return STRIPE_PAYMENT_LINK_MARATHON


def race_status_badge_class(race: Race) -> str:
    return "badge-free" if is_free_sample_race(race) else "badge-paid"


def race_status_badge_label(race: Race, lang: str) -> str:
    if is_free_sample_race(race):
        return "無料サンプル" if lang == "ja" else "Free Sample"
    return "有料Race Code予定" if lang == "ja" else "Paid Race Code Planned"


def race_code_summary(race: Race, lang: str) -> str:
    if is_free_sample_race(race):
        return sample_code_count_label(race, lang)
    return "購入後に案内" if lang == "ja" else "Available after purchase"


def render_sample_race_card(race: Race, lang: str) -> str:
    title = race.name_ja if lang == "ja" else race.name_en
    country = race.country_ja if lang == "ja" else race.country_en
    detail_href = f"/gatechecker/races/{race.slug}/" if lang == "ja" else f"/en/gatechecker/races/{race.slug}/"
    code_label = "Race Code"
    type_label = "種別" if lang == "ja" else "Type"
    country_label = "国" if lang == "ja" else "Country"
    course_label = "コース" if lang == "ja" else "Course"
    price_label = "価格" if lang == "ja" else "Price"
    detail_label = "使い方を見る" if lang == "ja" else "View details"

    return f"""
        <article class="race-list-card">
          <span class="badge {race_status_badge_class(race)}">{escape(race_status_badge_label(race, lang))}</span>
          <h3>{escape(title)}</h3>
          <div class="meta-stack">
            {render_meta_rows([
                (type_label, race_category_label(race, lang)),
                (country_label, country),
                (course_label, race_course_list_label(race, lang)),
                (price_label, race_price_label(race, lang)),
            ])}
          </div>
          <div class="code-box">
            <span class="code-label">{escape(code_label)}</span>
            <strong class="code-value">{escape(race_code_summary(race, lang))}</strong>
          </div>
          <div class="actions">
            {button_link(detail_href, detail_label, "primary")}
          </div>
        </article>
"""


def render_paid_race_card(race: Race, lang: str) -> str:
    title = race.name_ja if lang == "ja" else race.name_en
    detail_href = f"/gatechecker/races/{race.slug}/" if lang == "ja" else f"/en/gatechecker/races/{race.slug}/"
    get_label = "Race Codeを受け取る" if lang == "ja" else "Get Race Code"
    detail_label = "詳細を見る" if lang == "ja" else "View details"
    type_label = "種別" if lang == "ja" else "Type"
    country_label = "国" if lang == "ja" else "Country"
    course_label = "コース" if lang == "ja" else "Course"
    price_label = "価格" if lang == "ja" else "Price"
    code_label = "Race Code"
    purchase_button = optional_link_button(race_payment_link(race), get_label, lang, "primary")

    return f"""
        <article class="race-list-card">
          <span class="badge {race_status_badge_class(race)}">{escape(race_status_badge_label(race, lang))}</span>
          <h3>{escape(title)}</h3>
          <div class="meta-stack">
            {render_meta_rows([
                (type_label, race_category_label(race, lang)),
                (country_label, race.country_ja if lang == "ja" else race.country_en),
                (course_label, race_course_list_label(race, lang)),
                (price_label, race_price_label(race, lang)),
            ])}
          </div>
          <div class="code-box">
            <span class="code-label">{escape(code_label)}</span>
            <strong class="code-value">{escape(race_code_summary(race, lang))}</strong>
          </div>
          <div class="actions">
            {purchase_button}
            {button_link(detail_href, detail_label, "secondary")}
          </div>
        </article>
"""


def render_free_sample_table(races: list[Race], lang: str) -> str:
    if lang == "ja":
        headers = ("大会名", "開催日", "Race Code", "詳細")
    else:
        headers = ("Race", "Date", "Race Code", "Details")

    rows = []
    for race in races:
        title = race.name_ja if lang == "ja" else race.name_en
        detail_href = f"/gatechecker/races/{race.slug}/" if lang == "ja" else f"/en/gatechecker/races/{race.slug}/"
        detail_label = "詳細" if lang == "ja" else "Details"
        entries = free_sample_code_entries(race, lang)
        if len(entries) == 1:
            code_cell = f"<strong class=\"code-value\">{escape(entries[0][1])}</strong>"
        else:
            code_cell = "".join(
                (
                    f"<div><strong>{escape(label)}</strong></div>" if label else ""
                )
                + f"<div><strong class=\"code-value\">{escape(code)}</strong></div>"
                for label, code in entries
            )
        rows.append(
            "<tr>"
            f"<td>{escape(title)}</td>"
            f"<td>{escape(race.date)}</td>"
            f"<td>{code_cell}</td>"
            f"<td>{button_link(detail_href, detail_label, 'secondary')}</td>"
            "</tr>"
        )

    return f"""
        <div class="table-wrap">
          <table class="data-table">
            <thead>
              <tr>
                <th>{escape(headers[0])}</th>
                <th>{escape(headers[1])}</th>
                <th>{escape(headers[2])}</th>
                <th>{escape(headers[3])}</th>
              </tr>
            </thead>
            <tbody>
              {''.join(rows)}
            </tbody>
          </table>
        </div>
"""


def render_paid_race_table(races: list[Race], lang: str) -> str:
    if lang == "ja":
        headers = ("大会名", "開催日", "種別", "コース", "価格", "Race Code", "リンク")
        detail_label = "詳細"
        purchase_label = "Race Codeを受け取る"
    else:
        headers = ("Race", "Date", "Type", "Course", "Price", "Race Code", "Links")
        detail_label = "Details"
        purchase_label = "Get Race Code"

    rows = []
    for race in races:
        title = race.name_ja if lang == "ja" else race.name_en
        detail_href = f"/gatechecker/races/{race.slug}/" if lang == "ja" else f"/en/gatechecker/races/{race.slug}/"
        action_links = (
            optional_link_button(race_payment_link(race), purchase_label, lang, "primary")
            + button_link(detail_href, detail_label, "secondary")
        )
        rows.append(
            "<tr>"
            f"<td>{escape(title)}</td>"
            f"<td>{escape(race.date)}</td>"
            f"<td>{escape(race_category_label(race, lang))}</td>"
            f"<td>{escape(race_course_list_label(race, lang))}</td>"
            f"<td>{escape(race_price_label(race, lang))}</td>"
            f"<td>{escape(race_code_summary(race, lang))}</td>"
            f"<td><div class=\"actions\">{action_links}</div></td>"
            "</tr>"
        )

    return f"""
        <div class="table-wrap">
          <table class="data-table">
            <thead>
              <tr>
                <th>{escape(headers[0])}</th>
                <th>{escape(headers[1])}</th>
                <th>{escape(headers[2])}</th>
                <th>{escape(headers[3])}</th>
                <th>{escape(headers[4])}</th>
                <th>{escape(headers[5])}</th>
                <th>{escape(headers[6])}</th>
              </tr>
            </thead>
            <tbody>
              {''.join(rows)}
            </tbody>
          </table>
        </div>
"""


def point_distance_label(gate: dict[str, Any]) -> str:
    if gate.get("point") == "GOAL":
        return "GOAL"
    if gate.get("point_mi") is not None:
        return distance_label(float(gate["point_mi"]), "mi")
    if gate.get("point") is not None:
        return distance_label(float(gate["point"]), "km")
    return ""


def gate_location_label(gate: dict[str, Any], lang: str) -> str:
    location = localized_name(gate.get("name"), lang, "")
    if location:
        return location
    return point_distance_label(gate)


def aid_distance_label(aid: dict[str, Any]) -> str:
    if aid.get("mi") is not None:
        return distance_label(float(aid["mi"]), "mi")
    if aid.get("km") is not None:
        return distance_label(float(aid["km"]), "km")
    return ""


def optional_course_note(course: dict[str, Any], lang: str) -> str:
    notes = course.get("notes") or course.get("note")
    localized = localized_name(notes, lang, "")
    return localized or first_non_empty(
        course.get("notesJa") if lang == "ja" else course.get("notesEn"),
        course.get("noteJa") if lang == "ja" else course.get("noteEn"),
    )


def optional_course_start(course: dict[str, Any], race_info: dict[str, Any]) -> str:
    return first_non_empty(
        course.get("start_time"),
        course.get("startTime"),
        course.get("wave_start"),
        course.get("waveStart"),
        course.get("start"),
        race_info.get("start_time"),
        race_info.get("startTime"),
    )


def normalize_course_names(course: dict[str, Any], race_name_ja: str, race_name_en: str, index: int) -> tuple[str, str]:
    localized_course_name = course.get("course_name")
    name_ja = first_non_empty(
        localized_name(localized_course_name, "ja", ""),
        course.get("courseNameJa"),
        course.get("courseName"),
        course.get("course_id"),
        course.get("courseCode"),
    )
    name_en = first_non_empty(
        localized_name(localized_course_name, "en", ""),
        course.get("courseNameEn"),
        course.get("courseName"),
        course.get("course_id"),
        course.get("courseCode"),
    )
    if name_ja and name_en:
        return name_ja, name_en
    if name_ja:
        return name_ja, name_ja
    if name_en:
        return name_en, name_en
    if index == 1:
        return race_name_ja, race_name_en
    return f"コース{index}", f"Course {index}"


def normalize_courses(data: dict[str, Any], race_name_ja: str, race_name_en: str) -> list[Course]:
    race_info = data.get("race", {})
    raw_courses = data.get("courses") or [{
        "courseCode": "default",
        "courseNameJa": race_name_ja,
        "courseNameEn": race_name_en,
        "distance_km": race_info.get("distance_km"),
        "distance_mi": race_info.get("distance_mi"),
        "gates": data.get("gates", []),
        "aids": data.get("aids", []),
    }]

    courses: list[Course] = []
    for index, raw_course in enumerate(raw_courses, start=1):
        name_ja, name_en = normalize_course_names(raw_course, race_name_ja, race_name_en, index)
        distance_km = raw_course.get("distance_km")
        distance_mi = raw_course.get("distance_mi")
        if distance_km is not None:
            label = distance_label(float(distance_km), "km")
        elif distance_mi is not None:
            label = distance_label(float(distance_mi), "mi")
        else:
            label = ""

        courses.append(Course(
            code=str(raw_course.get("course_id") or raw_course.get("courseCode") or f"course-{index}"),
            race_code=normalize_text(raw_course.get("race_code")),
            name_ja=name_ja,
            name_en=name_en,
            distance_label_ja=label,
            distance_label_en=label,
            start_time=optional_course_start(raw_course, race_info),
            notes_ja=optional_course_note(raw_course, "ja"),
            notes_en=optional_course_note(raw_course, "en"),
            gates=list(raw_course.get("gates", [])),
            aids=list(raw_course.get("aids", [])),
        ))
    return courses


def extract_connect_iq_urls(index_meta: dict[str, Any], data: dict[str, Any]) -> tuple[str | None, str | None]:
    ja_url: str | None = None
    en_url: str | None = None

    sources = [
        data.get("connect_iq"),
        index_meta.get("connect_iq"),
        data.get("site"),
        index_meta.get("site"),
        index_meta,
    ]

    for source in sources:
        if not isinstance(source, dict):
            continue

        nested_urls = source.get("store_urls")
        if isinstance(nested_urls, dict):
            ja_url = ja_url or normalize_url(
                first_non_empty(
                    nested_urls.get("jpn"),
                    nested_urls.get("ja"),
                    nested_urls.get("japanese"),
                    nested_urls.get("jp"),
                    nested_urls.get("default"),
                    nested_urls.get("url"),
                )
            )
            en_url = en_url or normalize_url(
                first_non_empty(
                    nested_urls.get("eng"),
                    nested_urls.get("en"),
                    nested_urls.get("english"),
                    nested_urls.get("default"),
                    nested_urls.get("url"),
                )
            )

        shared_url = normalize_url(
            first_non_empty(
                source.get("store_url"),
                source.get("storeUrl"),
                source.get("connectIqUrl"),
                source.get("connect_iq_url"),
                source.get("url"),
            )
        )
        iq_app_id = normalize_text(first_non_empty(
            source.get("iq_apl_id"),
            source.get("iqAppId"),
            source.get("iq_app_id"),
        ))
        if iq_app_id:
            shared_url = shared_url or f"https://apps.garmin.com/ja-JP/apps/{iq_app_id}"

        ja_url = ja_url or normalize_url(first_non_empty(
            source.get("store_url_ja"),
            source.get("storeUrlJa"),
            source.get("connectIqUrlJa"),
            source.get("connect_iq_url_ja"),
            shared_url,
        ))
        en_url = en_url or normalize_url(first_non_empty(
            source.get("store_url_en"),
            source.get("storeUrlEn"),
            source.get("connectIqUrlEn"),
            source.get("connect_iq_url_en"),
            f"https://apps.garmin.com/apps/{iq_app_id}" if iq_app_id else shared_url,
        ))

    return ja_url, en_url


def load_races() -> list[Race]:
    index = load_yaml(RACE_DEFS_DIR / "race_index.yml")
    races: list[Race] = []
    raw_races = index.get("races", {})
    entries = raw_races.values() if isinstance(raw_races, dict) else raw_races

    for meta in entries:
        if not isinstance(meta, dict):
            continue
        definition_ref = meta.get("definition") or meta.get("file")
        if not definition_ref:
            continue
        definition_path = RACE_DEFS_DIR / str(definition_ref)
        data = load_yaml(definition_path)
        display_name = data.get("display_name", {})
        name_ja = localized_name(display_name, "ja", str(data.get("slug") or data.get("race_key") or ""))
        name_en = localized_name(display_name, "en", name_ja)
        race_info = data.get("race", {})
        slug = str(data.get("slug") or data.get("race_key") or definition_path.stem)
        country_ja, country_en = resolve_country(str(race_info.get("timezone") or ""))
        connect_iq_url_ja, connect_iq_url_en = extract_connect_iq_urls(meta, data)

        races.append(Race(
            slug=slug,
            name_ja=name_ja,
            name_en=name_en,
            date=str(race_info.get("date") or ""),
            timezone=str(race_info.get("timezone") or ""),
            sample_free=bool((data.get("meta") or {}).get("sample_free", meta.get("sample_free", False))),
            country_ja=country_ja,
            country_en=country_en,
            connect_iq_url_ja=connect_iq_url_ja,
            connect_iq_url_en=connect_iq_url_en,
            courses=normalize_courses(data, name_ja, name_en),
        ))

    return races


def render_header(lang: str) -> str:
    if lang == "ja":
        nav_items = [
            ("/racenavi/", "RaceNavi"),
            ("/gatechecker/", "関門ガイド"),
            ("/en/", "English"),
        ]
    else:
        nav_items = [
            ("/en/racenavi/", "RaceNavi"),
            ("/en/gatechecker/", "Cutoff Guide"),
            ("/", "Japanese"),
        ]

    nav_html = "".join(f'<a href="{href}">{escape(label)}</a>' for href, label in nav_items)
    home_href = "/" if lang == "ja" else "/en/"
    aria_label = "メインナビゲーション" if lang == "ja" else "Main navigation"

    return f"""
  <header class="page-shell site-header">
    <a class="site-logo" href="{home_href}">
      <img class="site-logo-mark" src="{FAVICON_IMAGE}" alt="RaceNavi icon" />
      <span>RaceNavi</span>
    </a>
    <nav class="site-nav" aria-label="{aria_label}">
      {nav_html}
    </nav>
  </header>
"""


def render_footer(lang: str) -> str:
    if lang == "ja":
        links = [
            ("/racenavi/", "RaceNavi"),
            ("/gatechecker/", "関門ガイド"),
            ("/en/", "English"),
            (X_URL, "X DM"),
        ]
        summary = "RaceNaviは、レース中の判断を減らすためのGarmin向けアプリサイトです。"
        disclaimer = "RaceNaviと関門ガイドはGarmin公式・大会公式のアプリではありません。"
    else:
        links = [
            ("/en/racenavi/", "RaceNavi"),
            ("/en/gatechecker/", "Cutoff Guide"),
            ("/", "Japanese"),
            (X_URL, "X DM"),
        ]
        summary = "RaceNavi is where I put the Garmin apps I make to cut down race-day guessing and mental math."
        disclaimer = "RaceNavi and Cutoff Guide are not official Garmin apps or official race apps."

    link_html = []
    for href, label in links:
        is_external = href.startswith("http")
        attrs = external_attrs() if is_external else ""
        link_html.append(f'<a href="{href}"{attrs}>{escape(label)}</a>')

    return f"""
  <footer class="page-shell site-footer">
    <div class="footer-block">
      <strong>RaceNavi</strong>
      <p>{escape(summary)}</p>
      <p>{escape(disclaimer)}</p>
    </div>
    <div class="footer-links">
      {''.join(link_html)}
    </div>
  </footer>
"""


def build_page(
    *,
    lang: str,
    title: str,
    description: str,
    canonical_path: str,
    ja_path: str,
    en_path: str,
    body_html: str,
) -> str:
    locale = "ja_JP" if lang == "ja" else "en_US"
    return f"""<!DOCTYPE html>
<html lang="{lang}">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>{escape(title)}</title>
  <meta name="description" content="{escape(description)}" />
  <link rel="canonical" href="{absolute_url(canonical_path)}" />
  <link rel="alternate" hreflang="ja" href="{absolute_url(ja_path)}" />
  <link rel="alternate" hreflang="en" href="{absolute_url(en_path)}" />
  <meta property="og:title" content="{escape(title)}" />
  <meta property="og:description" content="{escape(description)}" />
  <meta property="og:type" content="website" />
  <meta property="og:url" content="{absolute_url(canonical_path)}" />
  <meta property="og:image" content="{OG_IMAGE}" />
  <meta property="og:locale" content="{locale}" />
  <meta name="theme-color" content="#071423" />
  <link rel="icon" type="image/png" href="{FAVICON_IMAGE}" />
  <link rel="apple-touch-icon" href="{FAVICON_IMAGE}" />
  <link rel="stylesheet" href="/styles.css" />
</head>
<body>
{render_header(lang)}
{body_html}
{render_footer(lang)}
</body>
</html>
"""


def render_home_page(lang: str) -> str:
    if lang == "ja":
        title = "RaceNavi | Garmin向けレース支援アプリ"
        description = "RaceNaviは、目標タイムを狙うときのRaceNaviと、関門が不安なときの関門ガイドを置いているGarmin向けアプリサイトです。レース中の判断や計算を少し減らしたくて作っています。"
        path = "/"
        other = "/en/"
        hero_title = "レース中の迷いを、Garminの1画面で減らす。"
        hero_lead = "レース中に、心拍を見るか、ペースを見るか、関門まであと何分か。走りながら考える余裕がなくなるので、必要な情報をGarminに出したくて作っています。"
        hero_copy = "目標タイムを狙うなら RaceNavi。関門が不安なら 関門ガイド。どちらも、スマホを見たり頭の中で計算したりする回数を減らしたいときのためのアプリです。"
        actions = "".join([
            button_link(RACENAVI_CONNECT_IQ_JA, "RaceNaviをConnect IQで見る", "primary", external=True),
            button_link(GATE_CONNECT_IQ_URL, "関門ガイドをConnect IQで見る", "secondary", external=True),
        ])
        action_note = '<p class="action-note"><a href="/racenavi/custom/">カスタム設定を触りたい場合はこちら</a></p>'
        hero_visual = f"""
          <a class="icon-card icon-card-link" href="/racenavi/">
            <img class="icon-card-image" src="{RACENAVI_ICON}" alt="RaceNavi app icon" />
            <div>
              <strong>RaceNavi</strong>
              <p>目標タイムを狙うときの画面です。</p>
            </div>
          </a>
          <a class="icon-card icon-card-link" href="/gatechecker/">
            <img class="icon-card-image" src="{GATE_ICON}" alt="関門ガイド app icon" />
            <div>
              <strong>関門ガイド</strong>
              <p>次の関門まで何km・何分かを見ます。</p>
            </div>
          </a>
"""
        app_cards = f"""
        <article class="app-card">
          <span class="app-label label-racenavi">RaceNavi</span>
          <h2>目標タイムを狙うなら、上げすぎも落としすぎも見たい。</h2>
          <p class="app-summary">心拍、ペース、目標との差、予測タイムを1画面にまとめています。序盤で突っ込みすぎていないか、このままで目標に届くかを、その場で見やすくしたくて作った画面です。</p>
          <div class="app-image">
            <img src="{RACENAVI_HERO_JA}" alt="RaceNaviのHeroイメージ。心拍、ペース、目標との差、到達予測を表示するGarminデータフィールド。" />
          </div>
          <div class="actions">
            {button_link(RACENAVI_CONNECT_IQ_JA, "Connect IQで見る", "primary", external=True)}
            {button_link("/racenavi/", "RaceNaviの使い方を見る", "secondary")}
            {button_link("/racenavi/custom/", "カスタム設定を見る", "secondary")}
          </div>
        </article>
        <article class="app-card">
          <span class="app-label label-gate">関門ガイド</span>
          <h2>関門が気になるなら、次の関門まであと何km・あと何分かを見る。</h2>
          <p class="app-summary">関門表を事前に見ていても、走り出すと細かい情報はすぐ飛びます。関門ガイドは、次の関門までの残り距離と残り時間をGarminに出します。エイド情報も必要なときに見られます。</p>
          <p class="page-copy">1つのアプリにRace Codeを入れて大会ごとのデータを切り替える形です。無料サンプルの大会もあり、未対応大会のリクエストも受けています。</p>
          <div class="app-image">
            <img src="{GATE_HERO_JA}" alt="関門ガイドのHeroイメージ。次の関門までの残り時間を中心に、必要に応じてエイド情報も見られるGarminアプリ。" />
          </div>
          <div class="actions">
            {button_link(GATE_CONNECT_IQ_URL, "Connect IQで見る", "primary", external=True)}
            {button_link("/gatechecker/", "関門ガイドの使い方を見る", "secondary")}
            {button_link("/gatechecker/races/", "対応大会を見る", "secondary")}
          </div>
        </article>
"""
        section_title = "同じレースでも、困ることは少し違います。"
        section_copy = "ペースが上がりすぎていないかを見たい日もあれば、とにかく次の関門まで持つか知りたい日もあります。そこで、RaceNaviと関門ガイドを分けています。"
        support_title = "開発を応援する"
        support_copy = "RaceNaviと関門ガイドは個人開発のアプリです。役に立った場合は、今後の開発や大会情報更新のために、Buy Me a Coffeeから応援してもらえるとうれしいです。"
        support_note = "チップは任意であり、作成保証や個別対応の対価ではありません。"
        notice = "RaceNaviと関門ガイドはGarmin向けの個人開発アプリです。Garmin公式・大会公式のアプリではありません。関門やエイドの情報は更新に追いつけないこともあるので、使う前に大会公式情報も見てください。"
    else:
        title = "RaceNavi | Garmin apps for pacing and cutoff worries"
        description = "RaceNavi is where I put two Garmin apps I am building from my own race-day problems: one for chasing a goal time, and one for watching the next cutoff."
        path = "/en/"
        other = "/"
        hero_title = "Cut race-day second-guessing down to one Garmin screen."
        hero_lead = "In a race, you run out of room to think about whether to watch heart rate, pace, or the next cutoff. I am building these so the numbers I keep needing are already on the watch."
        hero_copy = "If you are chasing a goal time, use RaceNavi. If cutoffs worry you, use Cutoff Guide. Both are there to cut down phone checks and mental math while you are moving."
        actions = "".join([
            button_link(RACENAVI_CONNECT_IQ_EN, "View RaceNavi on Connect IQ", "primary", external=True),
            button_link(GATE_CONNECT_IQ_URL, "View Cutoff Guide on Connect IQ", "secondary", external=True),
        ])
        action_note = '<p class="action-note"><a href="/en/racenavi/custom/">If you want to tune RaceNavi more closely, start here</a></p>'
        hero_visual = f"""
          <a class="icon-card icon-card-link" href="/en/racenavi/">
            <img class="icon-card-image" src="{RACENAVI_ICON}" alt="RaceNavi app icon" />
            <div>
              <strong>RaceNavi</strong>
              <p>The screen I use when I am trying to hold a goal time.</p>
            </div>
          </a>
          <a class="icon-card icon-card-link" href="/en/gatechecker/">
            <img class="icon-card-image" src="{GATE_ICON}" alt="Cutoff Guide app icon" />
            <div>
              <strong>Cutoff Guide</strong>
              <p>The screen for seeing how far and how long to the next cutoff.</p>
            </div>
          </a>
"""
        app_cards = f"""
        <article class="app-card">
          <span class="app-label label-racenavi">RaceNavi</span>
          <h2>If you are chasing a goal time, you want to know when you are pushing too hard or letting it slip.</h2>
          <p class="app-summary">RaceNavi puts heart rate, pace, gap to goal, and predicted finish on one screen. It is for the part of the race where you want to judge early overcooking and late fade without piecing the numbers together in your head.</p>
          <div class="app-image">
            <img src="{RACENAVI_HERO_EN}" alt="RaceNavi hero image showing heart rate, pace, target gap, and estimated finish time." />
          </div>
          <div class="actions">
            {button_link(RACENAVI_CONNECT_IQ_EN, "View on Connect IQ", "primary", external=True)}
            {button_link("/en/racenavi/", "Learn about RaceNavi", "secondary")}
            {button_link("/en/racenavi/custom/", "Custom Setup", "secondary")}
          </div>
        </article>
        <article class="app-card">
          <span class="app-label label-gate">Cutoff Guide</span>
          <h2>If cutoffs are what keep bothering you, look at the next cutoff first.</h2>
          <p class="app-summary">Even if you studied the cutoff table before the race, the small details disappear once you are moving. Cutoff Guide shows the remaining distance and remaining time to the next cutoff on Garmin. Aid info is there when you need it, but it is secondary.</p>
          <p class="page-copy">It works as one app plus a Race Code for each race and course. Some races are free samples, and you can also request a race that is not listed yet.</p>
          <div class="app-image">
            <img src="{GATE_HERO_EN}" alt="Cutoff Guide hero image showing the next cutoff, time left, and next aid station." />
          </div>
          <div class="actions">
            {button_link(GATE_CONNECT_IQ_URL, "View on Connect IQ", "primary", external=True)}
            {button_link("/en/gatechecker/", "Learn about Cutoff Guide", "secondary")}
            {button_link("/en/gatechecker/races/", "View Supported Races", "secondary")}
          </div>
        </article>
"""
        section_title = "The problem changes depending on the race."
        section_copy = "Some days the real question is pace control. On other days it is just whether you are safely getting to the next cutoff. That is why these are split into two apps."
        support_title = "Support the project"
        support_copy = "RaceNavi and Cutoff Guide are personal projects. If they help, you can support future tweaks and race-data updates through Buy me a coffee."
        support_note = "Support is optional and does not guarantee race requests or individual support."
        notice = "RaceNavi and Cutoff Guide are independently developed Garmin apps. They are not official Garmin apps or official race apps. Cutoff and aid details can change, so always check the official race information too."

    body = f"""
  <main class="page-shell">
    <section class="hero">
        <div class="hero-card hero-home">
          <div>
            <span class="eyebrow">Garmin Race Support</span>
            <h1>{escape(hero_title)}</h1>
            <p class="lead">{escape(hero_lead)}</p>
            <p class="section-copy">{escape(hero_copy)}</p>
            <div class="actions">{actions}</div>
            {action_note if lang == "ja" else action_note}
          </div>
        <div class="hero-quick-grid hero-icon-grid">
          {hero_visual}
        </div>
      </div>
    </section>

    <section class="page-section">
      <div class="section-header">
        <span class="eyebrow">Apps</span>
        <h2>{escape(section_title)}</h2>
        <p class="section-copy">{escape(section_copy)}</p>
      </div>
      <div class="app-grid">
        {app_cards}
      </div>
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <span class="badge badge-support">{escape(support_title)}</span>
        <h2>{escape(support_title)}</h2>
        <p class="page-copy">{escape(support_copy)}</p>
        <div class="actions">
          {optional_link_button(BUY_ME_A_COFFEE_URL, "Buy Me a Coffeeで応援する" if lang == "ja" else "Buy me a coffee", lang, "primary")}
        </div>
        <p class="pricing-disclaimer">{escape(support_note)}</p>
      </article>
    </section>

    <section class="page-section">
      <div class="notice">
        <strong>{"使う前に" if lang == "ja" else "Disclaimer"}:</strong>
        {escape(notice)}
      </div>
    </section>
  </main>
"""
    return build_page(
        lang=lang,
        title=title,
        description=description,
        canonical_path=path,
        ja_path=path if lang == "ja" else other,
        en_path=other if lang == "ja" else path,
        body_html=body,
    )


def render_racenavi_page(lang: str) -> str:
    if lang == "ja":
        title = "RaceNavi | 心拍・ペース・目標差を1画面で確認するGarminアプリ"
        description = "RaceNaviは、目標タイムを狙う日に心拍、ペース、目標との差、予測タイムをGarminの1画面で見やすくするデータフィールドです。"
        path = "/racenavi/"
        other = "/en/racenavi/"
        hero_title = "心拍とペースで、レース中の判断を減らす。"
        hero_lead = "フルマラソンで、心拍、ペース、目標との差、予測タイムを1画面にまとめています。序盤で上げすぎていないか、このままで目標に届くかを、その場で見やすくしたくて作っています。"
        hero_copy = "数字を増やすためではなく、走りながら頭の中で組み立てることを減らしたい日に使う想定です。"
        actions = "".join([
            button_link(RACENAVI_CONNECT_IQ_JA, "Connect IQでRaceNaviを見る", "primary", external=True),
            button_link("#screen-preview", "画面イメージを見る", "secondary"),
            button_link("/racenavi/custom/", "カスタム設定を見る", "secondary"),
        ])
        decision_points = [
            "序盤で突っ込みすぎていないか",
            "今のペースで目標タイムにまだ届きそうか",
            "目標に対して今どれくらい前後しているか",
            "このまま行くとゴール予測がどこに落ちそうか",
            "後半まで押せる範囲にまだ収まっているか",
        ]
        info_points = [
            "現在の心拍",
            "CAP心拍",
            "現在のペース",
            "目標との差",
            "到達予測",
            "距離",
            "経過時間",
        ]
        screen_labels = [
            ("CAP HR", "その時点で上げすぎたくない心拍の目安です。"),
            ("HR", "今の心拍です。"),
            ("Pace", "現在の走行ペースです。"),
            ("Prediction", "このまま進んだ場合のゴール予測です。"),
            ("Difference from goal", "目標に対して前か後ろかを見ます。"),
            ("Distance", "経過距離です。"),
            ("Time", "経過時間です。"),
        ]
        cap_copy = "CAP心拍は、その時点で上げすぎたくない心拍の目安です。医療的な心拍管理ではなく、レース中に飛ばしすぎないための参考として使う想定です。"
        setup_items = [
            "Race Distance: Full Marathon / Half Marathon / 10Km から選びます。",
            "Target Time Hour / Minutes: 目標タイムを時分で入れます。",
            "LTHR: 分かっていれば、心拍閾値の心拍数を入れます。",
            "LTHRを入れない場合は、Garmin側の心拍ゾーン設定を使います。",
            "Custom Code: カスタム設定ページで作成したコードを入れると個別設定を反映できます。",
        ]
        setup_copy = (
            f'LTHR の考え方は <a href="{GARMIN_LACTATE_THRESHOLD_URL}" target="_blank" rel="noreferrer">'
            "Garmin の Lactate Threshold 解説</a> を参照してください。"
            f' 心拍ゾーンについては <a href="{GARMIN_HR_ZONES_URL}" target="_blank" rel="noreferrer">'
            "Garmin の Heart Rate Zones 解説</a> も確認できます。"
        )
        notice_items = [
            "Garmin公式アプリではありません。",
            "医療的助言ではありません。",
            "体調、暑さ、コース条件によって適切な判断は変わります。",
            "最終判断はランナー本人が行ってください。",
        ]
        cta_title = "まずは通常版で走ってみる"
        cta_copy = "まずは通常設定で使ってみて、もっと合わせたくなったらカスタム設定を見る流れを想定しています。"
        cta_actions = "".join([
            button_link(RACENAVI_CONNECT_IQ_JA, "Connect IQでRaceNaviを見る", "primary", external=True),
            button_link("/racenavi/custom/", "カスタム設定を見る", "secondary"),
        ])
    else:
        title = "RaceNavi | A Garmin screen for chasing a goal time"
        description = "RaceNavi is a Garmin marathon data field for runners who want heart rate, pace, gap to goal, and predicted finish on one screen while they race."
        path = "/en/racenavi/"
        other = "/racenavi/"
        hero_title = "Use heart rate and pace to cut down race-day guesswork."
        hero_lead = "RaceNavi puts heart rate, pace, gap to goal, and predicted finish on one screen for the marathon. I made it for the moments when you want to tell whether you are going out too hard or quietly drifting away from your target."
        hero_copy = "The point is not to add more numbers. It is to stop rebuilding the same judgment in your head while you run."
        actions = "".join([
            button_link(RACENAVI_CONNECT_IQ_EN, "View RaceNavi on Connect IQ", "primary", external=True),
            button_link("#screen-preview", "See the screen", "secondary"),
            button_link("/en/racenavi/custom/", "Custom Setup", "secondary"),
        ])
        decision_points = [
            "Whether your early effort is already too high",
            "Whether your current pace still leaves your goal time in range",
            "How far ahead of or behind goal you are right now",
            "Where your finish is drifting if you keep going like this",
            "Whether the effort still looks survivable for the second half",
        ]
        info_points = [
            "Current heart rate",
            "CAP heart rate",
            "Current pace",
            "Gap from goal",
            "Predicted finish",
            "Distance",
            "Elapsed time",
        ]
        screen_labels = [
            ("CAP HR", "A rough ceiling for effort at that point in the race."),
            ("HR", "Your current heart rate."),
            ("Pace", "Your current running pace."),
            ("Prediction", "Where your finish looks headed if the trend stays the same."),
            ("Difference from goal", "Whether you are ahead of or behind the goal."),
            ("Distance", "Elapsed distance."),
            ("Time", "Elapsed time."),
        ]
        cap_copy = "CAP heart rate is a rough upper guide for marathon effort at that point in the race. It is there to help with pacing judgment, not as a medical threshold."
        setup_items = [
            "Race Distance: choose Full Marathon, Half Marathon, or 10Km.",
            "Target Time Hour / Minutes: enter the finish time you are aiming for.",
            "LTHR: your lactate threshold heart rate if you have it.",
            "If LTHR is not set, RaceNavi uses your Garmin heart-rate zone setup instead.",
            "Custom Code: enter a code from the Custom Setup page if you want more personal tuning.",
        ]
        setup_copy = (
            f'Read <a href="{GARMIN_LACTATE_THRESHOLD_URL}" target="_blank" rel="noreferrer">Garmin Lactate Threshold</a> '
            f'and <a href="{GARMIN_HR_ZONES_URL}" target="_blank" rel="noreferrer">Garmin Heart Rate Zones</a> '
            "if you want the Garmin-side setup details."
        )
        notice_items = [
            "RaceNavi is not an official Garmin app.",
            "RaceNavi is not medical advice.",
            "The right effort changes with weather, course, and runner condition.",
            "Final decisions remain with the runner.",
        ]
        cta_title = "Start with the standard setup first"
        cta_copy = "The normal flow is simple: run with the standard setup first, then look at Custom Setup only if you want to tune it more closely."
        cta_actions = "".join([
            button_link(RACENAVI_CONNECT_IQ_EN, "View RaceNavi on Connect IQ", "primary", external=True),
            button_link("/en/racenavi/custom/", "Custom Setup", "secondary"),
        ])

    body = f"""
  <main class="page-shell">
    <section class="hero">
      <div class="hero-card hero-media">
        <div>
          <span class="eyebrow">RaceNavi</span>
          <h1>{escape(hero_title)}</h1>
          <p class="lead">{escape(hero_lead)}</p>
          <p class="section-copy">{escape(hero_copy)}</p>
          <div class="actions">{actions}</div>
        </div>
        <div class="hero-image-panel">
          <img src="{RACENAVI_HERO_JA if lang == 'ja' else RACENAVI_HERO_EN}" alt="RaceNavi hero image" />
        </div>
      </div>
    </section>

    <section class="page-section">
      <div class="info-grid">
        <article class="info-card">
          <h2>{"レース中に見たいこと" if lang == "ja" else "What you probably want to judge mid-race"}</h2>
          <ul>{render_list(decision_points)}</ul>
        </article>
        <article class="info-card">
          <h2>{"表示する情報" if lang == "ja" else "What RaceNavi puts on screen"}</h2>
          <ul>{render_list(info_points)}</ul>
        </article>
      </div>
    </section>

    <section class="page-section" id="screen-preview">
      <div class="section-header">
        <span class="eyebrow">Screen</span>
        <h2>{"画面イメージ" if lang == "ja" else "Screen preview"}</h2>
      </div>
      <article class="cta-panel hero-media">
        <div class="app-image app-image-narrow">
          <img src="{RACENAVI_SCREEN_IMAGE}" alt="RaceNavi screen preview" />
        </div>
        <div>
          <ul class="page-link-list bullet-copy">
            {''.join(f'<li><strong>{escape(label)}</strong>: {escape(copy)}</li>' for label, copy in screen_labels)}
          </ul>
        </div>
      </article>
    </section>

    <section class="page-section">
      <div class="info-grid">
        <article class="info-card">
          <h2>{"CAP心拍について" if lang == "ja" else "About CAP heart rate"}</h2>
          <p class="page-copy">{escape(cap_copy)}</p>
        </article>
        <article class="info-card">
          <h2>{"注意事項" if lang == "ja" else "Important notes"}</h2>
          <ul>{render_list(notice_items)}</ul>
        </article>
      </div>
    </section>

    <section class="page-section">
      <div class="section-header">
        <span class="eyebrow">Setup</span>
        <h2>{"使用前の設定" if lang == "ja" else "Before your race"}</h2>
        <p class="section-copy">{"インストール後、使用前に事前設定が必要です。" if lang == "ja" else "There is a short setup step before you use it."}</p>
      </div>
      <article class="cta-panel hero-media">
        <div class="app-image app-image-narrow">
          <img src="{RACENAVI_SETUP_IMAGE}" alt="RaceNavi setup screen" />
        </div>
        <div>
          <ul class="page-link-list bullet-copy">{render_list(setup_items)}</ul>
          <p class="page-copy">{setup_copy}</p>
        </div>
      </article>
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <span class="badge badge-racenavi">RaceNavi</span>
        <h2>{escape(cta_title)}</h2>
        <p class="page-copy">{escape(cta_copy)}</p>
        <div class="actions">{cta_actions}</div>
      </article>
    </section>
  </main>
"""
    return build_page(
        lang=lang,
        title=title,
        description=description,
        canonical_path=path,
        ja_path=path if lang == "ja" else other,
        en_path=other if lang == "ja" else path,
        body_html=body,
    )


def render_custom_page(lang: str) -> str:
    if lang == "ja":
        title = "RaceNaviカスタム設定 | 目標レースに合わせたモニター募集予定ページ"
        description = "RaceNaviのカスタム設定は、目標タイムや心拍情報、過去レースの傾向を見ながら、自分のレース用に少し詰めたい人向けの案内ページです。"
        path = "/racenavi/custom/"
        other = "/en/racenavi/custom/"
        hero_title = "RaceNaviを、自分のレース用に少し細かく合わせる。"
        hero_lead = "同じサブ4狙いでも、心拍の上がり方も後半の落ち方も人によって違います。ここでは、RaceNaviの設定を自分の目標レースに合わせて詰めたい人向けに案内しています。"
        actions = "".join([
            button_link(X_URL, "モニター希望をXで送る", "primary", external=True),
            button_link("#needed-info", "必要な情報を見る", "secondary"),
        ])
        audience = [
            "目標タイムに合わせて、心拍の上限目安をもう少し詰めたい",
            "後半に失速しやすく、序盤をどう抑えるか決めておきたい",
            "GarminやFITデータはあるが、どう見ればいいか分からない",
            "RaceNaviを自分のレース用に調整して使いたい",
        ]
        required = [
            "目標タイム",
            "最大心拍",
            "安静時心拍",
            "LTHRがあればLTHR",
            "過去のレースデータまたはFITデータ",
            "出場予定レース",
        ]
        status_title = "現在の募集状況"
        status_copy = "まだ固定メニューにはしておらず、まずはモニターで少しずつ試している段階です。興味があれば、XのDMで「RaceNaviカスタム設定希望」と送ってください。できる範囲と順番を見ながら案内します。"
        note_items = [
            "医療的助言ではありません。",
            "体調、暑さ、コース条件によって適切な心拍は変わります。",
            "最終判断はランナー本人が行ってください。",
        ]
    else:
        title = "Custom Setup | For runners who want RaceNavi tuned a bit more closely"
        description = "Custom Setup is for runners who want to tune RaceNavi more closely around their goal race, heart-rate profile, and past race data."
        path = "/en/racenavi/custom/"
        other = "/racenavi/custom/"
        hero_title = "Tune RaceNavi a bit closer to your own race."
        hero_lead = "Two runners chasing the same finish time can still have very different heart-rate behavior and late-race fade. This page is for runners who want to adjust RaceNavi more closely to their own race and past data."
        actions = "".join([
            button_link(X_URL, "Send a monitor request on X", "primary", external=True),
            button_link("#needed-info", "See what is needed", "secondary"),
        ])
        audience = [
            "You want the upper effort guide tightened a bit for your goal pace",
            "You often fade late and want a better plan for the first half",
            "You have Garmin or FIT data but are not sure how to use it",
            "You want RaceNavi adjusted around a specific goal race",
        ]
        required = [
            "Target finish time",
            "Max heart rate",
            "Resting heart rate",
            "LTHR if available",
            "Recent race data or FIT data",
            "Your target race",
        ]
        status_title = "Current status"
        status_copy = "This is still being tried in a small monitor-style format, not as a fixed service page. If you are interested, send an X DM with “RaceNavi Custom Setup” and I will reply with what I can handle and in what order."
        note_items = [
            "This is not medical advice.",
            "The right effort changes with weather, course, and runner condition.",
            "Final decisions remain with the runner.",
        ]

    body = f"""
  <main class="page-shell">
    <section class="hero">
      <div class="hero-card">
        <div>
          <span class="eyebrow">Custom Setup</span>
          <h1>{escape(hero_title)}</h1>
          <p class="lead">{escape(hero_lead)}</p>
          <div class="actions">{actions}</div>
        </div>
      </div>
    </section>

    <section class="page-section">
      <div class="info-grid">
        <article class="info-card">
          <h2>{"こんな人向け" if lang == "ja" else "Who this is for"}</h2>
          <ul>{render_list(audience)}</ul>
        </article>
        <article class="info-card" id="needed-info">
          <h2>{"必要な情報" if lang == "ja" else "What I would need"}</h2>
          <ul>{render_list(required)}</ul>
        </article>
      </div>
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <span class="badge badge-racenavi">Monitor</span>
        <h2>{escape(status_title)}</h2>
        <p class="page-copy">{escape(status_copy)}</p>
        <div class="actions">
          {button_link(X_URL, "Xでモニター希望を送る" if lang == "ja" else "Send a monitor request on X", "primary", external=True)}
        </div>
      </article>
    </section>

    <section class="page-section">
      <div class="notice">
        <strong>{"注意事項" if lang == "ja" else "Important notes"}:</strong>
        <ul class="page-link-list">{render_list(note_items)}</ul>
      </div>
    </section>
  </main>
"""
    return build_page(
        lang=lang,
        title=title,
        description=description,
        canonical_path=path,
        ja_path=path if lang == "ja" else other,
        en_path=other if lang == "ja" else path,
        body_html=body,
    )


def render_gatechecker_page(lang: str) -> str:
    sample_races = [race for race in load_races() if is_public_race(race.slug, race.name_ja, race.name_en) and is_free_sample_race(race)]
    if lang == "ja":
        title = "関門ガイド | Garminで次の関門までの残り距離と時間を見る"
        description = "関門ガイドは、次の関門まであと何km・あと何分かをGarminで見やすくするアプリです。Race Codeで大会とコースを切り替えます。"
        path = "/gatechecker/"
        other = "/en/gatechecker/"
        hero_title = "次の関門まで、あと何km・あと何分かを見る。"
        hero_lead = "関門表を事前に見ていても、レース中は細かい数字をすぐ忘れます。関門ガイドは、次の関門までの残り距離と残り時間をGarminに出すためのアプリです。"
        actions = "".join([
            optional_link_button(GATE_CONNECT_IQ_URL, "Connect IQでダウンロード", lang, "primary"),
            button_link("/gatechecker/races/", "対応大会を見る", "secondary"),
            button_link("/gatechecker/request/", "大会をリクエストする", "secondary"),
            optional_link_button(BUY_ME_A_COFFEE_URL, "Buy Me a Coffeeで応援する", lang, "secondary"),
        ])
        hero_follow = "エイド情報も必要なら見られます。Race Codeを入れると、その大会・コースのデータに切り替わります。"
        info_points = [
            "次の関門の場所",
            "次の関門までの残り距離",
            "次の関門までの残り時間",
            "次の関門の制限時刻",
            "必要なら次のエイドまでの距離",
        ]
        audience_title = "Race Codeで大会を切り替える"
        audience = [
            "Connect IQ Storeから関門ガイドをインストール",
            "このサイトでRace Codeを確認",
            "Garmin Connectのアプリ設定でRace Codeを入力",
            "時計に同期",
            "レース中に次の関門までの距離と時間を見る",
        ]
        screen_rows = [
            ("1段目", "次の関門がどこか、制限時刻が何時かを出します。"),
            ("2段目", "次の関門まであと何km・あと何分かを出します。"),
            ("3段目", "必要なら次のエイドまでの距離も見られます。"),
        ]
        audience_copy = "大会ごとにアプリを入れ替える形ではなく、1つのアプリで複数の大会に対応します。このサイトでRace Codeを見つけて、Garmin Connectの設定に入れる使い方です。"
        sample_title = "無料サンプル大会"
        sample_copy = "まず試しやすいように、無料サンプルとして公開している大会です。"
        support_title = "開発を応援する"
        support_copy = "関門ガイドは個人開発で作っています。役に立った場合は、今後の大会追加や情報更新のためにコーヒー1杯分で応援してもらえるとうれしいです。"
        support_note = "チップは任意であり、作成保証や個別対応の対価ではありません。"
        notice_items = [
            "Garmin公式アプリではありません。",
            "大会公式アプリではありません。",
            "関門・エイド情報は公式情報をもとに作成しますが、必ず大会公式情報も確認してください。",
            "コース変更、ウェーブスタート、天候、主催者発表により情報が変わる場合があります。",
            "完走、関門通過、記録達成を保証するものではありません。",
            "Race Codeは大会とコースを選ぶためのコードです。",
            "有料Race Codeはアプリ本体ではなく、大会別データを利用するためのコードです。",
            "チップは任意であり、作成保証や個別対応の対価ではありません。",
        ]
        hero_image = GATE_HERO_JA
        image_alt = "関門ガイドのHeroイメージ"
    else:
        title = "Cutoff Guide | See the next cutoff on your Garmin"
        description = "Cutoff Guide is a Garmin app for runners who want to see the distance and time left to the next cutoff, with aid information kept as a secondary extra."
        path = "/en/gatechecker/"
        other = "/gatechecker/"
        hero_title = "See how far and how long to the next cutoff."
        hero_lead = "Even if you looked at the cutoff table before the race, the details are easy to lose once you are moving. Cutoff Guide is the app I am building to keep the remaining distance and remaining time to the next cutoff on Garmin."
        actions = "".join([
            optional_link_button(GATE_CONNECT_IQ_URL, "Download on Connect IQ", lang, "primary"),
            button_link("/en/gatechecker/races/", "Supported Races", "secondary"),
            button_link("/en/gatechecker/request/", "Request a Race", "secondary"),
            optional_link_button(BUY_ME_A_COFFEE_URL, "Buy me a coffee", lang, "secondary"),
        ])
        hero_follow = "Aid information can also be shown when needed, but the main job is cutoff awareness. One app works with many races through Race Codes."
        info_points = [
            "Where the next cutoff is",
            "How far to the next cutoff",
            "How much time is left before that cutoff",
            "What time that cutoff is set for",
            "How far to the next aid station if you need it",
        ]
        audience_title = "One app, switched by Race Code"
        audience = [
            "Install Cutoff Guide from Connect IQ",
            "Find your Race Code on this website",
            "Enter the Race Code in Garmin Connect app settings",
            "Sync your watch",
            "Use the watch to see the next cutoff during the race",
        ]
        screen_rows = [
            ("Row 1", "Shows where the next cutoff is and what time it closes."),
            ("Row 2", "Shows how far and how long to that cutoff."),
            ("Row 3", "Can show the next aid distance when needed."),
        ]
        audience_copy = "This is not a separate app for every race. You use one app, find the Race Code for your race here, put it into Garmin Connect, and sync your watch."
        sample_title = "Free sample races"
        sample_copy = "These races are published as free sample Race Codes so you can try the flow first."
        support_title = "Support the project"
        support_copy = "Cutoff Guide is a personal project. If it helped, you can buy me a coffee to support more race pages and data updates."
        support_note = "Tips are optional and do not guarantee race requests or individual support."
        notice_items = [
            "This is not an official Garmin app.",
            "This is not an official race app.",
            "Cutoff and aid station data is based on official race information, but always check the official race guide.",
            "Course changes, wave starts, weather, and organizer updates may change the information.",
            "Finishing, beating a cutoff, or hitting a goal time is not guaranteed.",
            "A Race Code selects a race and course.",
            "A paid Race Code gives access to race-specific data, not the app itself.",
            "Tips are optional and do not guarantee race requests or individual support.",
        ]
        hero_image = GATE_HERO_EN
        image_alt = "Cutoff Guide hero image"

    body = f"""
  <main class="page-shell">
    <section class="hero">
      <div class="hero-card hero-media">
        <div>
          <span class="eyebrow eyebrow-gate">{"関門ガイド" if lang == "ja" else "Cutoff Guide"}</span>
          <h1>{escape(hero_title)}</h1>
          <p class="lead">{escape(hero_lead)}</p>
          <p class="section-copy">{escape(hero_follow)}</p>
          <div class="actions">{actions}</div>
          {render_todo_note(GATE_CONNECT_IQ_URL, lang)}
          {render_todo_note(BUY_ME_A_COFFEE_URL, lang)}
        </div>
        <div class="hero-image-panel">
          <img src="{hero_image}" alt="{escape(image_alt)}" />
        </div>
      </div>
    </section>

    <section class="page-section">
      <div class="info-grid">
        <article class="info-card">
          <h2>{"レース中に確認できること" if lang == "ja" else "What it lets you see mid-race"}</h2>
          <ul>{render_list(info_points)}</ul>
        </article>
        <article class="info-card">
          <h2>{escape(audience_title)}</h2>
          <p class="page-copy">{escape(audience_copy)}</p>
          <ul>{render_list(audience)}</ul>
        </article>
      </div>
    </section>

    <section class="page-section">
      <article class="cta-panel hero-media">
        <div class="app-image app-image-narrow">
          <img src="{GATE_SCREEN_IMAGE}" alt="Cutoff Guide screen preview" />
        </div>
        <div>
          <span class="badge badge-gate">{"画面項目" if lang == "ja" else "Screen fields"}</span>
          <ul class="page-link-list bullet-copy">
            {''.join(f'<li><strong>{escape(label)}</strong>: {escape(copy)}</li>' for label, copy in screen_rows)}
          </ul>
        </div>
      </article>
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <span class="badge badge-free">{escape(sample_title)}</span>
        <h2>{escape(sample_title)}</h2>
        <p class="page-copy">{escape(sample_copy)}</p>
        {render_free_sample_table(sample_races, lang)}
      </article>
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <span class="badge badge-support">{escape(support_title)}</span>
        <h2>{escape(support_title)}</h2>
        <p class="page-copy">{escape(support_copy)}</p>
        <div class="actions">
          {optional_link_button(BUY_ME_A_COFFEE_URL, "Buy Me a Coffeeで応援する" if lang == "ja" else "Buy me a coffee", lang, "primary")}
          {button_link("/gatechecker/request/" if lang == "ja" else "/en/gatechecker/request/", "大会をリクエストする" if lang == "ja" else "Request a Race", "secondary")}
        </div>
        <p class="pricing-disclaimer">{escape(support_note)}</p>
        {render_todo_note(BUY_ME_A_COFFEE_URL, lang)}
      </article>
    </section>

    <section class="page-section">
      <div class="notice">
        <strong>{"注意事項" if lang == "ja" else "Disclaimer"}:</strong>
        <ul class="page-link-list">{render_list(notice_items)}</ul>
      </div>
    </section>
  </main>
"""
    return build_page(
        lang=lang,
        title=title,
        description=description,
        canonical_path=path,
        ja_path=path if lang == "ja" else other,
        en_path=other if lang == "ja" else path,
        body_html=body,
    )


def render_gatechecker_request_page(lang: str) -> str:
    if lang == "ja":
        title = "未対応大会のリクエスト | 関門ガイド"
        description = "関門ガイドにまだない大会について、公式サイトや大会要項のURLを送るためのページです。大会リクエストは無料で受け付けています。"
        path = "/gatechecker/request/"
        other = "/en/gatechecker/request/"
        hero_title = "未対応大会のリクエスト"
        hero_lead = "関門ガイドにまだない大会で使いたいものがあれば、公式サイトや大会要項のURLを送ってください。"
        hero_copy = "リクエスト自体は無料です。ただし、どの大会でもすぐ作れるわけではありません。公式情報が揃っているか、他にも必要としている人がいそうかを見ながら順番に対応します。"
        actions = "".join([
            request_form_button("大会をリクエストする", lang, "primary"),
            button_link("/gatechecker/races/", "対応大会を見る", "secondary"),
            optional_link_button(BUY_ME_A_COFFEE_URL, "Buy Me a Coffeeで応援する", lang, "secondary"),
        ])
        request_title = "リクエストに必要な情報"
        request_items = [
            "大会名",
            "開催年",
            "種目 / コース",
            "公式サイトURL",
            "関門情報が載っているページまたはPDF",
            "エイド情報が載っているページまたはPDF",
            "ウェーブスタートやコース変更の情報があればそのURL",
            "連絡先メールアドレス 任意",
        ]
        process_title = "対応の進め方"
        process_copy_1 = "リクエストを受けたら、まず公式サイトや大会要項から関門とエイドの情報を拾います。"
        process_copy_2 = "そのあと、情報が足りるかと需要を見て順番を決め、対応できる大会からRace Codeを追加します。"
        support_title = "開発を応援する"
        support_copy_1 = "大会情報の確認やRace Code作成にはそれなりに時間がかかります。関門ガイドの開発を応援してもらえる場合は、Buy Me a Coffee からチップを送ってもらえるとうれしいです。"
        support_copy_2 = "チップは任意です。優先対応や作成保証の料金ではなく、今後の開発や情報更新への応援として受け取ります。"
        notice_items = [
            "Garmin公式アプリではありません。",
            "大会公式アプリではありません。",
            "関門・エイド情報は必ず大会公式情報も確認してください。",
            "コース変更、ウェーブスタート、天候、主催者発表により情報が変わることがあります。",
            "完走、関門通過、記録達成を保証するものではありません。",
            "チップを送っても、リクエスト大会の作成を保証するものではありません。",
            "公式情報が確認できない大会は対応できない場合があります。",
            "チップは任意であり、作成保証や個別対応の対価ではありません。",
        ]
    else:
        title = "Request a Race | Cutoff Guide"
        description = "Request a race for Cutoff Guide by sending the official race website or race guide PDF. Requests are free, but I add races in the order I can verify them."
        path = "/en/gatechecker/request/"
        other = "/gatechecker/request/"
        hero_title = "Request a Race"
        hero_lead = "If your race is not here yet, send the official race website or race guide PDF."
        hero_copy = "Requests are free. I cannot promise every race, but I work through the ones where the official cutoff information is clear enough to build from."
        actions = "".join([
            request_form_button("Request a Race", lang, "primary"),
            button_link("/en/gatechecker/races/", "View Supported Races", "secondary"),
            optional_link_button(BUY_ME_A_COFFEE_URL, "Buy me a coffee", lang, "secondary"),
        ])
        request_title = "What to send"
        request_items = [
            "Race name",
            "Race year",
            "Course / distance",
            "Official website",
            "Cutoff information URL or PDF",
            "Aid station information URL or PDF",
            "Wave start or course variation information if available",
            "Your email (optional)",
        ]
        process_title = "How I work through requests"
        process_copy_1 = "After I get a request, I first check the official website or race guide PDF and pull the cutoff and aid data from there."
        process_copy_2 = "Then I work through races where the official information is clear enough and demand looks real. When a race is ready, I add its Race Code here."
        support_title = "Support the project"
        support_copy_1 = "Checking race guides and building Race Codes takes time. If you want to support that work, you can buy me a coffee."
        support_copy_2 = "Support is optional. It does not buy priority handling or guarantee that a requested race will be added."
        notice_items = [
            "This is not an official Garmin app.",
            "This is not an official race app.",
            "Always confirm cutoff and aid-station information with official race information.",
            "Course changes, wave starts, weather, and organizer updates can change the information.",
            "Finishing, beating a cutoff, or hitting a goal time is not guaranteed.",
            "Some races cannot be supported if the official information cannot be verified.",
            "Tips are optional and do not guarantee race requests or individual support.",
        ]

    body = f"""
  <main class="page-shell">
    <section class="hero">
      <div class="hero-card">
        <div>
          <span class="eyebrow eyebrow-gate">{"大会リクエスト" if lang == "ja" else "Request a Race"}</span>
          <h1>{escape(hero_title)}</h1>
          <p class="lead">{escape(hero_lead)}</p>
          <p class="section-copy">{escape(hero_copy)}</p>
          <div class="actions">{actions}</div>
          {render_todo_note(BUY_ME_A_COFFEE_URL, lang)}
        </div>
      </div>
    </section>

    <section class="page-section">
      <div class="service-layout">
        <article class="cta-panel">
          <span class="badge badge-request">{escape(request_title)}</span>
          <h2>{escape(request_title)}</h2>
          <ul class="page-link-list">{render_list(request_items)}</ul>
        </article>

        <article class="info-card compact-card">
          <span class="badge badge-gate">{escape(process_title)}</span>
          <h2>{escape(process_title)}</h2>
          <p class="page-copy">{escape(process_copy_1)}</p>
          <p class="page-copy">{escape(process_copy_2)}</p>
        </article>
      </div>
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <span class="badge badge-support">{escape(support_title)}</span>
        <h2>{escape(support_title)}</h2>
        <p class="page-copy">{escape(support_copy_1)}</p>
        <p class="page-copy">{escape(support_copy_2)}</p>
        <div class="actions">
          {optional_link_button(BUY_ME_A_COFFEE_URL, "Buy Me a Coffeeで応援する" if lang == "ja" else "Buy me a coffee", lang, "primary")}
          {request_form_button("大会をリクエストする" if lang == "ja" else "Request a Race", lang, "secondary")}
        </div>
        {render_todo_note(BUY_ME_A_COFFEE_URL, lang)}
      </article>
    </section>

    <section class="page-section">
      <div class="section-header">
        <span class="eyebrow eyebrow-gate">Flow</span>
        <h2>{"流れ" if lang == "ja" else "Flow"}</h2>
      </div>
      <div class="steps-grid">
        {render_request_flow_steps(lang)}
      </div>
    </section>

    <section class="page-section">
      <div class="notice">
        <strong>{"注意事項" if lang == "ja" else "Disclaimer"}:</strong>
        <ul class="page-link-list">{render_list(notice_items)}</ul>
      </div>
    </section>
  </main>
"""
    return build_page(
        lang=lang,
        title=title,
        description=description,
        canonical_path=path,
        ja_path=path if lang == "ja" else other,
        en_path=other if lang == "ja" else path,
        body_html=body,
    )


def race_course_list_label(race: Race, lang: str) -> str:
    labels = []
    for course in race.courses:
        name = course.name_ja if lang == "ja" else course.name_en
        distance = course.distance_label_ja if lang == "ja" else course.distance_label_en
        if len(race.courses) == 1:
            labels.append(distance or name)
        else:
            labels.append(f"{name} ({distance})" if distance else name)
    return " / ".join(label for label in labels if label)


def race_connect_url(race: Race, lang: str) -> str | None:
    return race.connect_iq_url_ja if lang == "ja" else race.connect_iq_url_en


def render_race_list_card(race: Race, lang: str) -> str:
    if lang == "ja":
        title = race.name_ja
        detail_href = f"/gatechecker/races/{race.slug}/"
        detail_label = "関門・エイドを見る"
        connect_label = "Connect IQで見る"
        pending_label = "準備中"
        meta_rows = [
            ("開催日", race.date),
            ("コース", race_course_list_label(race, lang)),
        ]
        chips = []
        if len(race.courses) > 1:
            chips.append("複数コース対応")
        if race_connect_url(race, lang):
            chips.append("Connect IQ公開済み")
        else:
            chips.append("Connect IQ準備中")
    else:
        title = race.name_en
        detail_href = f"/en/gatechecker/races/{race.slug}/"
        detail_label = "View cutoff info"
        connect_label = "View on Connect IQ"
        pending_label = "Coming soon"
        meta_rows = [
            ("Date", race.date),
            ("Course", race_course_list_label(race, lang)),
        ]
        chips = []
        if len(race.courses) > 1:
            chips.append("Multiple courses")
        if race_connect_url(race, lang):
            chips.append("Connect IQ available")
        else:
            chips.append("Connect IQ coming soon")

    actions = [button_link(detail_href, detail_label, "primary")]
    connect_url = race_connect_url(race, lang)
    if connect_url:
        actions.append(button_link(connect_url, connect_label, "secondary", external=True))
    else:
        actions.append(button_placeholder(pending_label, "secondary"))

    return f"""
        <article class="race-list-card">
          <span class="badge badge-gate">{escape(race.country_ja if lang == "ja" else race.country_en)}</span>
          <h3>{escape(title)}</h3>
          <div class="meta-stack">
            {render_meta_rows(meta_rows)}
          </div>
          <div class="meta-pills">
            {render_pills(chips)}
          </div>
          <div class="actions">
            {''.join(actions)}
          </div>
        </article>
"""


def group_races_by_country(races: list[Race], lang: str) -> list[tuple[str, list[Race]]]:
    groups: dict[str, list[Race]] = {}
    for race in races:
        country = race.country_ja if lang == "ja" else race.country_en
        groups.setdefault(country, []).append(race)

    if lang == "ja":
        ordered_names = sorted(groups, key=lambda country: (0 if country == "日本" else 1, country))
    else:
        ordered_names = sorted(groups)

    return [
        (country, sorted(groups[country], key=lambda item: (item.date, item.name_ja, item.slug)))
        for country in ordered_names
    ]


def render_races_index(races: list[Race], lang: str) -> str:
    free_races = [race for race in races if is_free_sample_race(race)]
    paid_races = [race for race in races if not is_free_sample_race(race)]
    if lang == "ja":
        title = "対応大会・Race Code一覧 | 関門ガイド"
        description = "関門ガイドで使える大会とRace Codeをまとめた一覧です。無料サンプルと、有料で案内している大会をここに並べています。"
        path = "/gatechecker/races/"
        other = "/en/gatechecker/races/"
        hero_title = "対応大会・Race Code一覧"
        hero_lead = "関門ガイドは、Race Codeを入れて大会とコースを切り替える形です。無料サンプルの大会もあれば、有料で案内している大会もあります。"
        how_title = "Race Codeの使い方"
        how_copy = "1つのアプリにRace Codeを入れて使います。アプリ内で決済する形ではなく、有料のものは外部決済のあとにこちらから案内します。"
        how_points = [
            "Connect IQ Storeから関門ガイドをインストール",
            "このページでRace Codeを確認",
            "Garmin Connectのアプリ設定にRace Codeを入力",
            "時計に同期して使用",
        ]
        free_title = "無料Race Codes"
        free_copy = "まず試せるように、無料サンプルとして公開しているRace Codeです。"
        paid_title = "有料Race Codes"
        paid_copy = "有料のRace Codeは、購入後にGarmin Connectの設定へ入れて使います。今のところ、購入後の案内はメールで手動対応しています。"
        paid_note = "購入ページは共通です。購入後に対象大会のコードを案内します。"
        request_title = "リクエスト受付中の大会"
        request_copy = "まだない大会で使いたいものがあれば、リクエストページから公式サイトや大会要項のURLを送ってください。リクエスト自体は無料です。"
        notice_items = [
            "関門ガイドはGarmin公式アプリではありません。",
            "大会公式アプリではありません。",
            "関門・エイド情報は公式情報をもとに作成しますが、必ず大会公式情報も確認してください。",
            "コース変更、ウェーブスタート、天候、主催者発表により情報が変わる場合があります。",
            "完走、関門通過、記録達成を保証するものではありません。",
            "Race Codeは大会とコースを選ぶためのコードです。",
            "有料Race Codeはアプリ本体ではなく、大会別データを利用するためのコードです。",
            "チップは任意であり、作成保証や個別対応の対価ではありません。",
        ]
    else:
        title = "Supported Races & Race Codes | Cutoff Guide"
        description = "Supported races and Race Codes for Cutoff Guide. This is the list to check when you want to know whether your race already has a Race Code."
        path = "/en/gatechecker/races/"
        other = "/gatechecker/races/"
        hero_title = "Supported Races & Race Codes"
        hero_lead = "Cutoff Guide works by entering a Race Code to switch the race and course. Some races are published as free samples. Others are handled as paid Race Codes."
        how_title = "How Race Codes work"
        how_copy = "You use one app and put a Race Code into its settings. Paid Race Codes are handled outside the app, then sent over separately after purchase."
        how_points = [
            "Install Cutoff Guide from Connect IQ",
            "Find the Race Code on this page",
            "Enter the code in Garmin Connect app settings",
            "Sync your watch and use it during the race",
        ]
        free_title = "Free Race Codes"
        free_copy = "These are the free sample Race Codes you can try first."
        paid_title = "Paid Race Codes"
        paid_copy = "Paid Race Codes are for race-specific data, not for the app itself. After purchase, you receive the code for the race you selected and enter it in Garmin Connect."
        paid_note = "The purchase page is shared. After purchase, the Race Code for your selected race is sent separately."
        request_title = "Need another race?"
        request_copy = "If your race is not listed yet, send the official website or race guide URL from the request page. Requests are free."
        notice_items = [
            "Cutoff Guide is not an official Garmin app.",
            "It is not an official race app.",
            "Cutoff and aid station data is based on official race information, but always check the official race guide.",
            "Race information may change due to course changes, wave starts, weather, or organizer announcements.",
            "This app does not guarantee finishing, passing cutoffs, or achieving a target time.",
            "A Race Code selects a race and course.",
            "A paid Race Code gives access to race-specific data, not the app itself.",
            "Tips are optional and do not guarantee race requests or individual support.",
        ]

    body = f"""
  <main class="page-shell">
    <section class="hero">
      <div class="hero-card">
        <div>
          <span class="eyebrow eyebrow-gate">{"Race Code" if lang == "ja" else "Supported Races"}</span>
          <h1>{escape(hero_title)}</h1>
          <p class="lead">{escape(hero_lead)}</p>
        </div>
      </div>
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <span class="badge badge-gate">{escape(how_title)}</span>
        <h2>{escape(how_title)}</h2>
        <p class="page-copy">{escape(how_copy)}</p>
        <ul class="page-link-list">{render_list(how_points)}</ul>
        <div class="actions">
          {optional_link_button(GATE_CONNECT_IQ_URL, "Connect IQでダウンロード" if lang == "ja" else "Download on Connect IQ", lang, "primary")}
          {button_link("/gatechecker/request/" if lang == "ja" else "/en/gatechecker/request/", "大会をリクエストする" if lang == "ja" else "Request a Race", "secondary")}
        </div>
        {render_todo_note(GATE_CONNECT_IQ_URL, lang)}
      </article>
    </section>

    <section class="page-section">
      <div class="section-header">
        <span class="badge badge-free">{escape(free_title)}</span>
        <h2>{escape(free_title)}</h2>
        <p class="section-copy">{escape(free_copy)}</p>
      </div>
      {render_free_sample_table(free_races, lang)}
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <span class="badge badge-paid">{escape(paid_title)}</span>
        <h2>{escape(paid_title)}</h2>
        <p class="page-copy">{escape(paid_copy)}</p>
        <div class="pricing-grid">
          {render_paid_code_pricing_cards(lang)}
        </div>
        <p class="pricing-disclaimer">{escape(paid_note)}</p>
      </article>
    </section>

    <section class="page-section">
      {''.join(
          f'''
      <section class="race-group">
        <div class="section-header">
          <span class="badge badge-gate">{escape(country)}</span>
          <h2>{escape(country)}</h2>
        </div>
        {render_paid_race_table(country_races, lang)}
      </section>
''' for country, country_races in group_races_by_country(paid_races, lang)
      )}
      {render_todo_note(STRIPE_PAYMENT_LINK_MARATHON, lang)}
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <span class="badge badge-request">{escape(request_title)}</span>
        <h2>{escape(request_title)}</h2>
        <p class="page-copy">{escape(request_copy)}</p>
        <div class="actions">
          {button_link("/gatechecker/request/" if lang == "ja" else "/en/gatechecker/request/", "大会リクエストへ" if lang == "ja" else "Request a Race", "primary")}
        </div>
      </article>
    </section>

    <section class="page-section">
      <div class="notice">
        <strong>{"注意事項" if lang == "ja" else "Disclaimer"}:</strong>
        <ul class="page-link-list">{render_list(notice_items)}</ul>
      </div>
    </section>
  </main>
"""
    return build_page(
        lang=lang,
        title=title,
        description=description,
        canonical_path=path,
        ja_path=path if lang == "ja" else other,
        en_path=other if lang == "ja" else path,
        body_html=body,
    )


def detail_course_heading(race: Race, course: Course, lang: str) -> str:
    if len(race.courses) == 1:
        return race.name_ja if lang == "ja" else race.name_en
    return course.name_ja if lang == "ja" else course.name_en


def render_cutoff_rows(gates: list[dict[str, Any]], lang: str) -> str:
    rows = []
    for index, gate in enumerate(gates, start=1):
        rows.append(
            "<tr>"
            f"<td>{index}</td>"
            f"<td>{escape(gate_location_label(gate, lang))}</td>"
            f"<td>{escape(point_distance_label(gate))}</td>"
            f"<td>{escape(str(gate.get('cutoff') or ''))}</td>"
            "</tr>"
        )
    return "".join(rows)


def render_aid_rows(aids: list[dict[str, Any]], lang: str) -> str:
    rows = []
    for index, aid in enumerate(aids, start=1):
        rows.append(
            "<tr>"
            f"<td>{index}</td>"
            f"<td>{escape(aid_distance_label(aid))}</td>"
            f"<td>{escape(localized_name(aid.get('name'), lang, ''))}</td>"
            "</tr>"
        )
    return "".join(rows)


def render_course_intro_pills(course: Course, lang: str) -> str:
    distance = course.distance_label_ja if lang == "ja" else course.distance_label_en
    note = course.notes_ja if lang == "ja" else course.notes_en
    pills = []
    if distance:
        pills.append(distance)
    if course.start_time:
        pills.append(("スタート " if lang == "ja" else "Start ") + course.start_time)
    if note:
        pills.append(note)
    return render_pills(pills)


def render_cutoff_course_block(race: Race, course: Course, lang: str) -> str:
    heading = detail_course_heading(race, course, lang)
    if lang == "ja":
        empty_copy = "現在、このコースの関門情報は準備中です。"
    else:
        empty_copy = "Cutoff information for this course is being prepared."

    content = (
        f"""
          <div class="table-wrap">
            <table class="data-table">
              <thead>
                <tr>
                  <th>No</th>
                  <th>{"地点" if lang == "ja" else "Point"}</th>
                  <th>{"距離" if lang == "ja" else "Distance"}</th>
                  <th>{"制限時刻" if lang == "ja" else "Cutoff time"}</th>
                </tr>
              </thead>
              <tbody>
                {render_cutoff_rows(course.gates, lang)}
              </tbody>
            </table>
          </div>
"""
        if course.gates else f'<p class="empty-note">{escape(empty_copy)}</p>'
    )

    return f"""
        <article class="detail-section-card">
          {'<h3>' + escape(heading) + '</h3>' if heading else ''}
          <div class="meta-pills">{render_course_intro_pills(course, lang)}</div>
          {content}
        </article>
"""


def render_aid_course_block(race: Race, course: Course, lang: str) -> str:
    heading = detail_course_heading(race, course, lang)
    if lang == "ja":
        empty_copy = "現在、このコースのエイド情報は準備中です。"
    else:
        empty_copy = "Aid-station information for this course is being prepared."

    content = (
        f"""
          <div class="table-wrap">
            <table class="data-table">
              <thead>
                <tr>
                  <th>No</th>
                  <th>{"距離" if lang == "ja" else "Distance"}</th>
                  <th>{"メモ" if lang == "ja" else "Note"}</th>
                </tr>
              </thead>
              <tbody>
                {render_aid_rows(course.aids, lang)}
              </tbody>
            </table>
          </div>
"""
        if course.aids else f'<p class="empty-note">{escape(empty_copy)}</p>'
    )

    return f"""
        <article class="detail-section-card">
          {'<h3>' + escape(heading) + '</h3>' if heading else ''}
          <div class="meta-pills">{render_course_intro_pills(course, lang)}</div>
          {content}
        </article>
"""


def render_race_detail(race: Race, lang: str) -> str:
    free_sample = is_free_sample_race(race)
    free_code_count = len(free_sample_code_entries(race, lang)) if free_sample else 0
    code_value = race_code_summary(race, lang)
    price_value = race_price_label(race, lang)
    purchase_link = race_payment_link(race)
    if lang == "ja":
        title = f"{race.name_ja}のRace Codeと関門・エイド情報 | 関門ガイド"
        description = f"{race.name_ja}のRace Codeと、次の関門までの判断に使うための関門・エイド情報をまとめたページです。"
        path = f"/gatechecker/races/{race.slug}/"
        other = f"/en/gatechecker/races/{race.slug}/"
        hero_title = f"{race.name_ja}のRace Codeと関門・エイド情報"
        hero_lead = f"このページは、{race.name_ja}の関門表をレース前に見返しやすくするためのまとめです。関門ガイドでは、この大会のRace Codeを入れると次の関門までの距離と時間を見られます。"
        primary_cta = optional_link_button(GATE_CONNECT_IQ_URL, "Connect IQでダウンロード", lang, "primary")
        secondary_cta = button_link("/gatechecker/races/", "対応大会一覧に戻る", "secondary")
        cutoff_copy = "ここでは、参照時点で確認できた関門地点と制限時刻を並べています。直前変更の可能性はあるので、最終的には大会公式情報も見てください。"
        aid_copy = "エイドは補足です。次のエイドまでどれくらいあるかを見るための情報で、給水や給食の内容までは保証しません。"
        code_title = "この大会のRace Code"
        code_copy = "Garmin Connectのアプリ設定にRace Codeを入れて時計に同期すると、この大会のデータを使えます。"
        code_steps = [
            "関門ガイドをConnect IQ Storeからインストール",
            "このページでRace Codeを確認",
            "Garmin Connectの設定画面にRace Codeを入力",
            "時計に同期",
            "レース中に次の関門までの距離と時間を見る",
        ]
        purchase_copy = (
            "このRace Codeは無料サンプルとして公開しています。複数コースがある大会は、コースごとに別のRace Codeを公開します。"
            if free_sample and free_code_count > 1
            else "このRace Codeは無料サンプルとして公開しています。"
            if free_sample
            else "有料Race Codeはアプリ本体ではなく、この大会データを使うためのコードです。購入後は当面メールで手動案内します。"
        )
        request_title = "別の大会も必要ならリクエストできます"
        request_copy = "未対応大会のリクエストは無料で受け付けています。"
        request_copy_2 = "公式サイトや大会要項から情報を拾える大会から順番に対応します。"
        request_button = "大会リクエストを見る"
        request_note = "チップは任意であり、作成保証や個別対応の対価ではありません。"
        footer_title = "使う前に"
        disclaimer_items = [
            "このページはGarmin公式、大会公式の情報ではありません。",
            "関門・エイド情報は大会公式情報を必ず確認してください。",
            "コース変更、ウェーブスタート、天候変更などにより、実際の条件と異なる場合があります。",
            "完走、関門通過、記録達成を保証するものではありません。",
            "Race Codeは大会とコースを選ぶためのコードです。",
            "Race Codeはアプリ本体ではなく、大会別データを選ぶためのコードです。" if free_sample else "有料Race Codeはアプリ本体ではなく、大会別データを利用するためのコードです。",
        ]
        meta_rows = [
            ("開催日", race.date),
            ("タイムゾーン", race.timezone),
            ("コース数", str(len(race.courses))),
            ("種別", race_category_label(race, lang)),
            ("価格", price_value),
        ]
    else:
        title = f"{race.name_en} Race Code and Cutoff Info | Cutoff Guide"
        description = f"Race Code and cutoff information for {race.name_en}, with aid details kept as a secondary reference."
        path = f"/en/gatechecker/races/{race.slug}/"
        other = f"/gatechecker/races/{race.slug}/"
        hero_title = f"{race.name_en} Race Code and Cutoff Info"
        hero_lead = f"This page is a race-prep summary for {race.name_en}. It is here so you can look back at the cutoff table more easily before race day, and use the Race Code in Cutoff Guide to see the next cutoff on your watch."
        primary_cta = optional_link_button(GATE_CONNECT_IQ_URL, "Download on Connect IQ", lang, "primary")
        secondary_cta = button_link("/en/gatechecker/races/", "Back to Supported Races", "secondary")
        cutoff_copy = "These are the cutoff points and cutoff times I could confirm from the available race information when preparing the page. Always recheck the official race information before race day."
        aid_copy = "Aid information is secondary here. It is mainly for seeing how far the next aid is, and it does not guarantee food or drink details."
        code_title = "Race Code for this race"
        code_copy = "Put the Race Code into Garmin Connect app settings, then sync your watch to load this race."
        code_steps = [
            "Install Cutoff Guide from Connect IQ",
            "Check the Race Code on this page",
            "Enter it in Garmin Connect app settings",
            "Sync your watch",
            "Use the watch to see the next cutoff during the race",
        ]
        purchase_copy = (
            "This Race Code is published as a free sample. When a race has multiple courses, each course gets its own published code."
            if free_sample and free_code_count > 1
            else "This Race Code is published as a free sample."
            if free_sample
            else "This paid Race Code is for the race data only, not for the app itself. For now, it is sent manually after purchase."
        )
        request_title = "Need another race?"
        request_copy = "Race requests are free."
        request_copy_2 = "I work through races where the official information is clear enough to build from."
        request_button = "Request a Race"
        request_note = "Tips are optional and do not guarantee race requests or individual support."
        footer_title = "Before you use it"
        disclaimer_items = [
            "This site is not affiliated with Garmin or the race organizer.",
            "Always confirm cutoff and aid-station details with official race information.",
            "Race information may change because of course changes, wave starts, weather, or organizer updates.",
            "Finishing, beating a cutoff, or hitting a goal time is not guaranteed.",
            "A Race Code selects a race and course.",
            "A Race Code selects race-specific data and does not include the app itself." if free_sample else "A paid Race Code gives access to race-specific data, not the app itself.",
        ]
        meta_rows = [
            ("Date", race.date),
            ("Timezone", race.timezone),
            ("Courses", str(len(race.courses))),
            ("Type", race_category_label(race, lang)),
            ("Price", price_value),
        ]

    cutoff_blocks = "".join(render_cutoff_course_block(race, course, lang) for course in race.courses)
    aid_blocks = "".join(render_aid_course_block(race, course, lang) for course in race.courses)
    extra_pills = [
        "無料サンプルRace Code" if free_sample and lang == "ja" else "",
        "有料Race Code予定" if (not free_sample) and lang == "ja" else "",
        "Free sample Race Code" if free_sample and lang == "en" else "",
        "Paid Race Code planned" if (not free_sample) and lang == "en" else "",
    ]
    code_button = (
        button_link("/gatechecker/races/" if lang == "ja" else "/en/gatechecker/races/", "対応大会一覧を見る" if lang == "ja" else "See all Race Codes", "secondary")
        if free_sample
        else optional_link_button(purchase_link, "Race Codeを受け取る" if lang == "ja" else "Get Race Code", lang, "primary")
    )

    body = f"""
  <main class="page-shell">
    <section class="hero">
      <div class="hero-card hero-home">
        <div>
          <span class="eyebrow eyebrow-gate">{"関門ガイド" if lang == "ja" else "Cutoff Guide"}</span>
          <h1>{escape(hero_title)}</h1>
          <p class="lead">{escape(hero_lead)}</p>
          <div class="actions">
            {primary_cta}
            {secondary_cta}
          </div>
          {render_todo_note(GATE_CONNECT_IQ_URL, lang)}
        </div>
        <div class="quick-card detail-summary">
          <h2>{"Race Code概要" if lang == "ja" else "Race Code Summary"}</h2>
          <div class="meta-stack">
            {render_meta_rows(meta_rows)}
          </div>
          <div class="meta-pills">
            {render_pills(extra_pills)}
          </div>
          {render_race_code_list(race, lang) if free_sample else render_single_code_box(code_value)}
        </div>
      </div>
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <span class="badge {race_status_badge_class(race)}">{escape(code_title)}</span>
        <h2>{escape(code_title)}</h2>
        <p class="page-copy">{escape(code_copy)}</p>
        {render_race_code_list(race, lang) if free_sample else render_single_code_box(code_value)}
        <ul class="page-link-list">{render_list(code_steps)}</ul>
        <p class="pricing-disclaimer">{escape(purchase_copy)}</p>
        <div class="actions">
          {code_button}
          {button_link("/gatechecker/request/" if lang == "ja" else "/en/gatechecker/request/", request_button, "secondary")}
        </div>
        {render_todo_note(purchase_link, lang)}
      </article>
    </section>

    <section class="page-section">
      <div class="section-header">
        <span class="eyebrow eyebrow-gate">Cutoff</span>
        <h2>{"関門情報" if lang == "ja" else "Cutoff information"}</h2>
        <p class="section-copy">{escape(cutoff_copy)}</p>
      </div>
      <div class="course-section-grid">
        {cutoff_blocks}
      </div>
    </section>

    <section class="page-section">
      <div class="section-header">
        <span class="eyebrow eyebrow-gate">Aid</span>
        <h2>{"エイド情報" if lang == "ja" else "Aid information"}</h2>
        <p class="section-copy">{escape(aid_copy)}</p>
      </div>
      <div class="course-section-grid">
        {aid_blocks}
      </div>
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <span class="badge badge-request">{"大会リクエスト" if lang == "ja" else "Race Request"}</span>
        <h2>{escape(request_title)}</h2>
        <p class="page-copy">{escape(request_copy)}</p>
        <p class="page-copy">{escape(request_copy_2)}</p>
        <div class="actions">
          {button_link("/gatechecker/request/" if lang == "ja" else "/en/gatechecker/request/", request_button, "primary")}
        </div>
        <p class="pricing-disclaimer">{escape(request_note)}</p>
      </article>
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <span class="badge badge-gate">{"注意事項" if lang == "ja" else "Important notes"}</span>
        <h2>{escape(footer_title)}</h2>
        <ul class="page-link-list">{render_list(disclaimer_items)}</ul>
      </article>
    </section>
  </main>
"""
    return build_page(
        lang=lang,
        title=title,
        description=description,
        canonical_path=path,
        ja_path=path if lang == "ja" else other,
        en_path=other if lang == "ja" else path,
        body_html=body,
    )


def generate() -> None:
    sync_assets()
    races = load_races()
    public_races = [race for race in races if is_public_race(race.slug, race.name_ja, race.name_en)]
    keep_slugs = {race.slug for race in public_races}

    pages = {
        SITE_DIR / "index.html": render_home_page("ja"),
        SITE_DIR / "racenavi" / "index.html": render_racenavi_page("ja"),
        SITE_DIR / "racenavi" / "custom" / "index.html": render_custom_page("ja"),
        SITE_DIR / "gatechecker" / "index.html": render_gatechecker_page("ja"),
        SITE_DIR / "gatechecker" / "request" / "index.html": render_gatechecker_request_page("ja"),
        SITE_DIR / "gatechecker" / "races" / "index.html": render_races_index(public_races, "ja"),
        SITE_DIR / "en" / "index.html": render_home_page("en"),
        SITE_DIR / "en" / "racenavi" / "index.html": render_racenavi_page("en"),
        SITE_DIR / "en" / "racenavi" / "custom" / "index.html": render_custom_page("en"),
        SITE_DIR / "en" / "gatechecker" / "index.html": render_gatechecker_page("en"),
        SITE_DIR / "en" / "gatechecker" / "request" / "index.html": render_gatechecker_request_page("en"),
        SITE_DIR / "en" / "gatechecker" / "races" / "index.html": render_races_index(public_races, "en"),
    }

    for race in public_races:
        pages[SITE_DIR / "gatechecker" / "races" / race.slug / "index.html"] = render_race_detail(race, "ja")
        pages[SITE_DIR / "en" / "gatechecker" / "races" / race.slug / "index.html"] = render_race_detail(race, "en")

    for path, html in pages.items():
        write_text(path, html)

    removed = 0
    removed += cleanup_stale_race_dirs(SITE_DIR / "gatechecker" / "races", keep_slugs)
    removed += cleanup_stale_race_dirs(SITE_DIR / "en" / "gatechecker" / "races", keep_slugs)

    print(
        f"Generated {len(pages)} pages from {len(public_races)} public races "
        f"({len(races)} total definitions, removed {removed} stale race directories)."
    )


if __name__ == "__main__":
    generate()
