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
GATE_HERO_JA = "/assets/GateChecker_Hero_Image_jp.png"
GATE_HERO_EN = "/assets/GateChecker_Hero_Image_en.png"
GATE_SCREEN_IMAGE = "/assets/screen_image.png"
FAVICON_IMAGE = RACENAVI_ICON
OG_IMAGE = f"{BASE_URL}{RACENAVI_HERO_JA}"
X_URL = "https://x.com/racenavi_run"
RACENAVI_CONNECT_IQ_JA = "https://apps.garmin.com/ja-JP/apps/00ebf0d8-4f9f-47d0-a59c-27f9b286c830"
RACENAVI_CONNECT_IQ_EN = "https://apps.garmin.com/apps/00ebf0d8-4f9f-47d0-a59c-27f9b286c830"
GARMIN_LACTATE_THRESHOLD_URL = "https://www.garmin.com/en-XD/garmin-technology/running-science/physiological-measurements/lactate-threshold/"
GARMIN_HR_ZONES_URL = "https://support.garmin.com/en-US/?faq=s3HqdKNtWV1NYrK16eFcc7"
GOOGLE_FORM_URL_JA = "https://forms.gle/xy492imp9MCXxNRP7"
GOOGLE_FORM_URL_EN = "https://forms.gle/5e8J9hBNDotUr6NR9"


@dataclass
class Course:
    code: str
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


def google_form_url(lang: str) -> str:
    return GOOGLE_FORM_URL_JA if lang == "ja" else GOOGLE_FORM_URL_EN


def google_form_ready(lang: str) -> bool:
    return google_form_url(lang).startswith(("https://", "http://"))


def request_form_button(label: str, lang: str, kind: str = "primary") -> str:
    return button_link(google_form_url(lang), label, kind, external=google_form_ready(lang))


def render_request_form_status(lang: str) -> str:
    return ""


def render_request_pricing_cards(lang: str) -> str:
    if lang == "ja":
        cards = [
            ("国内大会", "2,980円", "標準料金"),
            ("海外大会", "US$29", "標準料金"),
        ]
    else:
        cards = [
            ("Request price", "US$29", "Standard pricing"),
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
            "Googleフォームからリクエスト送信",
            "大会情報を確認",
            "作成可否とPayPal支払い手続きを連絡",
            "支払い確認後に作成開始",
            "完成後、Connect IQ Storeに公開",
        ]
    else:
        steps = [
            "Send your request through the Google Form.",
            "The race information is reviewed.",
            "I contact you about feasibility and the PayPal payment steps.",
            "Work starts after the payment is confirmed.",
            "The completed app is published on the Connect IQ Store.",
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
                "A. フォームで送られた大会情報を確認し、作成できそうな場合にPayPalの支払い案内を送ります。いきなり支払いではありません。",
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
                "A. Payment is handled via PayPal only after I review the race information and confirm that the guide looks feasible to create.",
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
    name_ja = first_non_empty(course.get("courseNameJa"), course.get("courseName"), course.get("courseCode"))
    name_en = first_non_empty(course.get("courseNameEn"), course.get("courseName"), course.get("courseCode"))
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
            code=str(raw_course.get("courseCode") or f"course-{index}"),
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

    for _, meta in index.get("races", {}).items():
        definition_path = RACE_DEFS_DIR / meta["definition"]
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
            ("/gatechecker/races/", "対応大会"),
            ("/racenavi/custom/", "カスタム設定"),
            ("/en/", "English"),
        ]
    else:
        nav_items = [
            ("/en/racenavi/", "RaceNavi"),
            ("/en/gatechecker/", "Cutoff Guide"),
            ("/en/gatechecker/races/", "Supported Races"),
            ("/en/racenavi/custom/", "Custom Setup"),
            ("/", "日本語"),
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
            ("/gatechecker/races/", "対応大会"),
            ("/gatechecker/request/", "作成リクエスト"),
            ("/racenavi/custom/", "カスタム設定"),
            ("/en/", "English"),
            (X_URL, "X DM"),
        ]
        summary = "RaceNaviは、レース中の判断を減らすためのGarmin向けアプリサイトです。"
        disclaimer = "RaceNaviと関門ガイドはGarmin公式・大会公式のアプリではありません。"
    else:
        links = [
            ("/en/racenavi/", "RaceNavi"),
            ("/en/gatechecker/", "Cutoff Guide"),
            ("/en/gatechecker/races/", "Supported Races"),
            ("/en/gatechecker/request/", "Request Details"),
            ("/en/racenavi/custom/", "Custom Setup"),
            ("/", "日本語"),
            (X_URL, "X DM"),
        ]
        summary = "RaceNavi provides Garmin apps for race-day pacing decisions and cutoff awareness."
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
        description = "RaceNaviは、フルマラソン中の心拍・ペース・目標差を確認するRaceNaviと、関門・エイドを確認する関門ガイドを提供するGarmin向けアプリサイトです。"
        path = "/"
        other = "/en/"
        hero_title = "レース中の迷いを、Garminの1画面で減らす。"
        hero_lead = "RaceNaviは、心拍・ペース・目標差を確認するマラソン用アプリ。関門ガイドは、次の関門とエイドを確認する大会別アプリです。"
        hero_copy = "どちらも、走っている最中にスマホを見たり、頭の中で計算したりする負担を減らすために作っています。"
        actions = "".join([
            button_link(RACENAVI_CONNECT_IQ_JA, "RaceNaviをConnect IQで見る", "primary", external=True),
            button_link("/gatechecker/races/", "関門ガイドの対応大会を見る", "secondary"),
            button_link("/racenavi/custom/", "カスタム設定を見る", "secondary"),
        ])
        hero_visual = f"""
          <article class="icon-card">
            <img class="icon-card-image" src="{RACENAVI_ICON}" alt="RaceNavi app icon" />
            <div>
              <strong>RaceNavi</strong>
              <p>心拍・ペース・目標差を確認する。</p>
            </div>
          </article>
          <article class="icon-card">
            <img class="icon-card-image" src="{GATE_ICON}" alt="関門ガイド app icon" />
            <div>
              <strong>関門ガイド</strong>
              <p>関門情報とエイド情報を確認する。</p>
            </div>
          </article>
"""
        app_cards = f"""
        <article class="app-card">
          <span class="app-label label-racenavi">RaceNavi</span>
          <h2>心拍・ペース・目標差を、レース中に確認する。</h2>
          <p class="app-summary">序盤で突っ込みすぎていないか。このままのペースで目標に届くか。心拍とペースを見ながら、フルマラソン中の判断を支えるGarminデータフィールドです。</p>
          <div class="app-image">
            <img src="{RACENAVI_HERO_JA}" alt="RaceNaviのHeroイメージ。心拍、ペース、目標との差、到達予測を表示するGarminデータフィールド。" />
          </div>
          <div class="actions">
            {button_link(RACENAVI_CONNECT_IQ_JA, "Connect IQで見る", "primary", external=True)}
            {button_link("/racenavi/", "RaceNaviの使い方を見る", "secondary")}
          </div>
        </article>
        <article class="app-card">
          <span class="app-label label-gate">関門ガイド</span>
          <h2>次の関門とエイドまでの余裕を確認する。</h2>
          <p class="app-summary">次の関門まであと何kmか。制限時刻まであと何分あるか。大会ごとの関門・エイド情報をGarmin上で確認するためのアプリです。</p>
          <p class="page-copy">対応大会にないレースでも、関門・エイド情報を確認できる場合は、有償の作成リクエストとして受け付けます。完成後はConnect IQで公開し、同じ大会に出る他のランナーも使える形になります。</p>
          <div class="app-image">
            <img src="{GATE_HERO_JA}" alt="関門ガイドのHeroイメージ。次の関門までの残り時間と次のエイドまでの距離をGarminで確認するアプリ。" />
          </div>
          <div class="actions">
            {button_link("/gatechecker/", "関門ガイドを見る", "primary")}
            {button_link("/gatechecker/races/", "対応大会を見る", "secondary")}
            {button_link("/gatechecker/request/", "作成リクエストを見る", "secondary")}
          </div>
        </article>
"""
        section_title = "2つのアプリを、目的で分ける。"
        section_copy = "トップページでは、RaceNaviと関門ガイドを別アプリとして案内します。まずは自分の困りごとに近い方から確認してください。"
        quick_cards = """
          <article class="quick-card">
            <span class="meta-pill">RaceNavi</span>
            <strong>心拍・ペース・目標差</strong>
            <p>フルマラソン中の判断を減らす。</p>
          </article>
          <article class="quick-card">
            <span class="meta-pill">関門ガイド</span>
            <strong>関門・エイド</strong>
            <p>大会ごとの余裕時間を確認する。</p>
          </article>
"""
        notice = "RaceNaviと関門ガイドはGarmin向けアプリです。Garmin公式、大会公式のアプリではありません。関門・エイド情報は必ず大会公式情報も確認してください。"
    else:
        title = "RaceNavi | Garmin apps for pacing and cutoff guidance"
        description = "RaceNavi helps marathon runners check heart rate, pace, target gap, and estimated finish time, while Cutoff Guide helps them check cutoffs and aid stations on Garmin watches."
        path = "/en/"
        other = "/"
        hero_title = "Make race-day decisions faster on your Garmin."
        hero_lead = "RaceNavi helps you check heart rate, pace, target gap, and estimated finish time during a marathon. Cutoff Guide helps you see the next cutoff and aid station for supported races."
        hero_copy = "Both apps are built to reduce the need to look at your phone or calculate race information in your head while you are running."
        actions = "".join([
            button_link(RACENAVI_CONNECT_IQ_EN, "View RaceNavi on Connect IQ", "primary", external=True),
            button_link("/en/gatechecker/races/", "View Supported Races", "secondary"),
            button_link("/en/racenavi/custom/", "Learn about Custom Setup", "secondary"),
        ])
        hero_visual = f"""
          <article class="icon-card">
            <img class="icon-card-image" src="{RACENAVI_ICON}" alt="RaceNavi app icon" />
            <div>
              <strong>RaceNavi</strong>
              <p>Heart rate, pace, and target gap.</p>
            </div>
          </article>
          <article class="icon-card">
            <img class="icon-card-image" src="{GATE_ICON}" alt="Cutoff Guide app icon" />
            <div>
              <strong>Cutoff Guide</strong>
              <p>Cutoffs and aid stations for each race.</p>
            </div>
          </article>
"""
        app_cards = f"""
        <article class="app-card">
          <span class="app-label label-racenavi">RaceNavi</span>
          <h2>Check heart rate, pace, and target gap while you race.</h2>
          <p class="app-summary">Are you pushing too hard early? Are you still on pace for your goal? RaceNavi keeps the key pacing decisions on one Garmin screen.</p>
          <div class="app-image">
            <img src="{RACENAVI_HERO_EN}" alt="RaceNavi hero image showing heart rate, pace, target gap, and estimated finish time." />
          </div>
          <div class="actions">
            {button_link(RACENAVI_CONNECT_IQ_EN, "View on Connect IQ", "primary", external=True)}
            {button_link("/en/racenavi/", "Learn about RaceNavi", "secondary")}
          </div>
        </article>
        <article class="app-card">
          <span class="app-label label-gate">Cutoff Guide</span>
          <h2>Check the next cutoff and aid station before they become a problem.</h2>
          <p class="app-summary">How far is the next cutoff? How much time is left? Cutoff Guide is a race-specific Garmin app built for supported events.</p>
          <p class="page-copy">If your race is not listed yet, paid request slots are planned for races where official cutoff and aid information can be confirmed. Finished guides are published on Connect IQ and may be used by other runners as well.</p>
          <div class="app-image">
            <img src="{GATE_HERO_EN}" alt="Cutoff Guide hero image showing the next cutoff, time left, and next aid station." />
          </div>
          <div class="actions">
            {button_link("/en/gatechecker/", "Learn about Cutoff Guide", "primary")}
            {button_link("/en/gatechecker/races/", "View Supported Races", "secondary")}
            {button_link("/en/gatechecker/request/", "View Request Details", "secondary")}
          </div>
        </article>
"""
        section_title = "Two apps, two different race-day jobs."
        section_copy = "RaceNavi handles pacing and heart-rate decisions. Cutoff Guide handles race-specific cutoff and aid-station awareness."
        quick_cards = """
          <article class="quick-card">
            <span class="meta-pill">RaceNavi</span>
            <strong>Heart rate, pace, target gap</strong>
            <p>Built for marathon pacing decisions.</p>
          </article>
          <article class="quick-card">
            <span class="meta-pill">Cutoff Guide</span>
            <strong>Cutoffs and aid stations</strong>
            <p>Built for supported race-specific pages.</p>
          </article>
"""
        notice = "RaceNavi and Cutoff Guide are independently developed Garmin apps. They are not official Garmin apps or official race apps. Always check official race information as well."

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
      <div class="notice">
        <strong>{"注意事項" if lang == "ja" else "Disclaimer"}:</strong>
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
        description = "RaceNaviは、フルマラソン中に心拍、ペース、目標との差、到達予測をGarminの1画面で確認するためのデータフィールドです。"
        path = "/racenavi/"
        other = "/en/racenavi/"
        hero_title = "心拍とペースで、レース中の判断を減らす。"
        hero_lead = "RaceNaviは、フルマラソン本番で心拍・ペース・目標との差・到達予測を1画面で確認するGarmin向けデータフィールドです。"
        hero_copy = "数字を増やすためではなく、走りながら判断しやすくするために作っています。"
        actions = "".join([
            button_link(RACENAVI_CONNECT_IQ_JA, "Connect IQでRaceNaviを見る", "primary", external=True),
            button_link("#screen-preview", "画面イメージを見る", "secondary"),
            button_link("/racenavi/custom/", "カスタム設定を見る", "secondary"),
        ])
        decision_points = [
            "序盤で心拍を上げすぎていないか",
            "今のペースで目標タイムに届きそうか",
            "目標に対して貯金か、借金か",
            "このまま行くとゴール予測はどれくらいか",
            "後半まで押せる状態か",
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
            ("CAP HR", "その時点での心拍上限目安です。"),
            ("HR", "現在の心拍を確認します。"),
            ("Pace", "現在の走行ペースです。"),
            ("Prediction", "このまま進んだ場合の到達予測です。"),
            ("Difference from goal", "目標に対して貯金か借金かを見ます。"),
            ("Distance", "経過距離です。"),
            ("Time", "経過時間です。"),
        ]
        cap_copy = "CAP心拍は、その時点で許容する心拍上限の目安です。医療的な心拍管理ではなく、レース中に突っ込みすぎを避けるための参考値として扱います。"
        setup_items = [
            "Race Distance: Full Marathon / Half Marathon / 10Km から選択します。",
            "Target Time Hour / Minutes: 目標タイムを時分で設定します。",
            "LTHR: 心拍閾値の心拍数です。設定すると目安の精度を合わせやすくなります。",
            "LTHRを設定しない場合は、Garmin側の心拍ゾーン設定を使います。",
            "Custom Code: カスタム設定ページで作成したコードを入力すると個別設定を反映できます。",
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
        cta_title = "まずは通常版で試す"
        cta_copy = "まずは通常設定で使い、必要であれば目標タイムや心拍情報に合わせたカスタム設定を検討してください。"
        cta_actions = "".join([
            button_link(RACENAVI_CONNECT_IQ_JA, "Connect IQでRaceNaviを見る", "primary", external=True),
            button_link("/racenavi/custom/", "カスタム設定を見る", "secondary"),
        ])
    else:
        title = "RaceNavi | Garmin marathon app for heart rate, pace, and target gap"
        description = "RaceNavi is a Garmin marathon data field that shows heart rate, pace, target gap, and estimated finish time on a single screen."
        path = "/en/racenavi/"
        other = "/racenavi/"
        hero_title = "Use heart rate and pace to reduce race-day guesswork."
        hero_lead = "RaceNavi is a Garmin marathon data field that shows heart rate, pace, target gap, and estimated finish time on a single screen."
        hero_copy = "It is built to help you make simpler decisions while running, not to add more numbers to think about."
        actions = "".join([
            button_link(RACENAVI_CONNECT_IQ_EN, "View RaceNavi on Connect IQ", "primary", external=True),
            button_link("#screen-preview", "View Screen Preview", "secondary"),
            button_link("/en/racenavi/custom/", "Learn about Custom Setup", "secondary"),
        ])
        decision_points = [
            "Whether your early effort is too high",
            "Whether your current pace still supports your goal time",
            "Whether you are ahead of or behind your target",
            "What your projected finish looks like",
            "Whether your effort still looks sustainable for the second half",
        ]
        info_points = [
            "Current heart rate",
            "CAP heart rate",
            "Current pace",
            "Gap from target",
            "Estimated finish time",
            "Distance",
            "Elapsed time",
        ]
        screen_labels = [
            ("CAP HR", "A practical upper effort guide for that point in the race."),
            ("HR", "Your current heart rate."),
            ("Pace", "Your current running pace."),
            ("Prediction", "Estimated finish based on the current trend."),
            ("Difference from goal", "How far ahead of or behind goal you are."),
            ("Distance", "Elapsed distance."),
            ("Time", "Elapsed time."),
        ]
        cap_copy = "CAP heart rate is a practical upper guide for race effort at that point in the marathon. It is not a medical threshold."
        setup_items = [
            "Race Distance: choose Full Marathon, Half Marathon, or 10Km.",
            "Target Time Hour / Minutes: set your goal finish time.",
            "LTHR: your lactate threshold heart rate if you have it.",
            "If LTHR is not set, RaceNavi falls back to your Garmin heart-rate zone setup.",
            "Custom Code: enter a code generated from the Custom Setup page for personalized tuning.",
        ]
        setup_copy = (
            f'Read <a href="{GARMIN_LACTATE_THRESHOLD_URL}" target="_blank" rel="noreferrer">Garmin Lactate Threshold</a> '
            f'and <a href="{GARMIN_HR_ZONES_URL}" target="_blank" rel="noreferrer">Garmin Heart Rate Zones</a> '
            "for the underlying Garmin setup."
        )
        notice_items = [
            "RaceNavi is not an official Garmin app.",
            "RaceNavi is not medical advice.",
            "Appropriate race effort changes with weather, course, and runner condition.",
            "Final decisions remain with the runner.",
        ]
        cta_title = "Start with the standard setup"
        cta_copy = "Try the standard setup first. If you need more tuning later, use the Custom Setup page as the next step."
        cta_actions = "".join([
            button_link(RACENAVI_CONNECT_IQ_EN, "View RaceNavi on Connect IQ", "primary", external=True),
            button_link("/en/racenavi/custom/", "Learn about Custom Setup", "secondary"),
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
          <h2>{"レース中に見たいこと" if lang == "ja" else "Things to check during the race"}</h2>
          <ul>{render_list(decision_points)}</ul>
        </article>
        <article class="info-card">
          <h2>{"表示する情報" if lang == "ja" else "What RaceNavi shows"}</h2>
          <ul>{render_list(info_points)}</ul>
        </article>
      </div>
    </section>

    <section class="page-section" id="screen-preview">
      <div class="section-header">
        <span class="eyebrow">Screen</span>
        <h2>{"画面イメージ" if lang == "ja" else "Screen Preview"}</h2>
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
        <h2>{"使用前の設定" if lang == "ja" else "Setup Before Your Race"}</h2>
        <p class="section-copy">{"インストール後、使用前に事前設定が必要です。" if lang == "ja" else "RaceNavi needs a quick setup before you use it."}</p>
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
        description = "RaceNaviのカスタム設定は、目標タイム、心拍情報、過去のレースデータをもとに設定を整理するモニター募集予定ページです。"
        path = "/racenavi/custom/"
        other = "/en/racenavi/custom/"
        hero_title = "RaceNaviを、自分の目標レース用に調整する。"
        hero_lead = "同じサブ4狙いでも、心拍の上がり方や後半の落ち方は人によって違います。カスタム設定では、目標タイム、心拍情報、過去のレースデータをもとに、RaceNaviで使う設定を整理します。"
        actions = "".join([
            button_link(X_URL, "モニター希望をXで送る", "primary", external=True),
            button_link("#needed-info", "必要な情報を見る", "secondary"),
        ])
        audience = [
            "目標タイムに合わせて、心拍の上限目安を整理したい",
            "後半に失速しやすく、序盤の抑え方を決めておきたい",
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
        status_copy = "現在は正式販売前のため、先着モニター募集の形を検討しています。希望があれば、XのDMで「RaceNaviカスタム設定希望」と送ってください。提供内容・価格・募集人数は、準備ができ次第案内します。"
        note_items = [
            "医療的助言ではありません。",
            "体調、暑さ、コース条件によって適切な心拍は変わります。",
            "最終判断はランナー本人が行ってください。",
        ]
    else:
        title = "Custom Setup | Planned monitor page for personalized RaceNavi tuning"
        description = "Custom Setup is a planned monitor page for runners who want RaceNavi adjusted around their goal time, heart-rate profile, and past race data."
        path = "/en/racenavi/custom/"
        other = "/racenavi/custom/"
        hero_title = "Tune RaceNavi for your goal race."
        hero_lead = "Runners with the same finish goal still respond differently in heart rate and late-race fade. Custom Setup is meant to organize RaceNavi settings around your target time, heart-rate profile, and past race data."
        actions = "".join([
            button_link(X_URL, "Send a monitor request on X", "primary", external=True),
            button_link("#needed-info", "See Required Info", "secondary"),
        ])
        audience = [
            "Runners who want a clearer upper effort guide for their target pace",
            "Runners who often fade late and want a better early-race plan",
            "Runners who have Garmin or FIT data but are not sure how to use it",
            "Runners who want RaceNavi tuned for a specific goal race",
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
        status_copy = "This is still under consideration as a monitor program rather than a fixed commercial service. If you are interested, send an X DM with “RaceNavi Custom Setup”. Details such as scope, pricing, and number of monitor users will be shared when ready."
        note_items = [
            "This is not medical advice.",
            "Appropriate race effort changes with weather, course, and runner condition.",
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
          <h2>{"必要な情報" if lang == "ja" else "Required information"}</h2>
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
    if lang == "ja":
        title = "関門ガイド | マラソンの関門・エイドをGarminで確認"
        description = "関門ガイドは、大会ごとの関門時刻とエイド地点をGarminで確認するアプリです。対応大会にないレースも、公式情報を確認できる場合は個別大会用の関門ガイド作成リクエストをGoogleフォームから受け付けます。"
        path = "/gatechecker/"
        other = "/en/gatechecker/"
        hero_title = "Garminで関門情報とエイド情報を確認する。"
        hero_lead = "関門ガイドは、大会ごとの関門時刻とエイド地点をもとに、次の関門までの残り距離・残り時間、次のエイドまでの距離をGarminで確認するアプリです。スマホを取り出したり、頭の中で関門時刻を計算したりする余裕がない場面を想定しています。"
        actions = "".join([
            button_link("/gatechecker/races/", "対応大会を見る", "primary"),
            button_link("/gatechecker/request/", "作成リクエストを見る", "secondary"),
        ])
        info_points = [
            "次の関門はどこか",
            "関門まであと何kmか",
            "制限時刻まであと何分あるか",
            "次のエイドはどこか",
            "エイドまであと何kmか",
        ]
        audience = [
            "関門が多い大会に出る人",
            "完走狙いで余裕時間を見ながら走りたい人",
            "ウルトラマラソンや海外マラソンで、関門・エイド情報を確認したい人",
            "レース中にスマホを見るのが面倒、または難しい人",
        ]
        screen_rows = [
            ("1段目", "次の関門地点の距離と、そこまでの残り距離を確認します。"),
            ("2段目", "次の関門地点の設定時間と、残り時間を確認します。"),
            ("3段目", "次のエイドまでの距離と、残り距離を確認します。"),
        ]
        teaser_title = "未対応大会の作成リクエスト"
        teaser_copy = "希望する大会が未対応の場合は、作成リクエストの詳細ページから料金と流れを確認できます。"
        teaser_copy_2 = "作成した大会版は、他のユーザーも利用できる形でConnect IQ Storeに公開します。"
        notice_items = [
            "Garmin公式アプリではありません。",
            "大会公式アプリではありません。",
            "関門・エイド情報は必ず大会公式情報も確認してください。",
            "コース変更、ウェーブスタート、天候、主催者発表により情報が変わる場合があります。",
            "完走、関門通過、記録達成を保証するものではありません。",
        ]
        hero_image = GATE_HERO_JA
        image_alt = "関門ガイドのHeroイメージ"
    else:
        title = "Cutoff Guide | Garmin app for race cutoffs and aid stations"
        description = "Cutoff Guide is a Garmin app that helps runners check the next cutoff, time left, and distance to the next aid station for supported races. If a race is not listed yet, a race-specific request can be sent through the Google Form when official race information is available."
        path = "/en/gatechecker/"
        other = "/gatechecker/"
        hero_title = "Know your next cutoff before it becomes a problem."
        hero_lead = "Cutoff Guide shows the next cutoff point, time left, and distance to the next aid station on your Garmin watch. It is built for races where checking your phone or calculating cutoff times in your head is not realistic."
        actions = "".join([
            button_link("/en/gatechecker/races/", "View Supported Races", "primary"),
            button_link("/en/gatechecker/request/", "View Request Details", "secondary"),
        ])
        info_points = [
            "Where the next cutoff is",
            "How far away the cutoff is",
            "How much time is left before the cutoff",
            "Where the next aid station is",
            "How far away the next aid station is",
        ]
        audience = [
            "Runners in races with many cutoff points",
            "Runners trying to finish while managing the time limit",
            "Ultramarathon or overseas race runners who want cutoff and aid awareness",
            "Runners who do not want to check a phone during the race",
        ]
        screen_rows = [
            ("Row 1", "Distance of the next cutoff point and the remaining distance to it."),
            ("Row 2", "Configured cutoff time and the remaining time before it."),
            ("Row 3", "Distance to the next aid station and the remaining distance."),
        ]
        teaser_title = "Unsupported race request"
        teaser_copy = "If your race is not supported yet, the request page explains the pricing and the process."
        teaser_copy_2 = "The completed race edition is published on the Connect IQ Store for other users as well."
        notice_items = [
            "This is not an official Garmin app.",
            "This is not an official race app.",
            "Always confirm cutoff and aid-station information with official race information.",
            "Course changes, wave starts, weather, and organizer updates may change the information.",
            "Finishing, beating a cutoff, or hitting a goal time is not guaranteed.",
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
          <div class="actions">{actions}</div>
        </div>
        <div class="hero-image-panel">
          <img src="{hero_image}" alt="{escape(image_alt)}" />
        </div>
      </div>
    </section>

    <section class="page-section">
      <div class="info-grid">
        <article class="info-card">
          <h2>{"レース中に確認できること" if lang == "ja" else "What you can check during the race"}</h2>
          <ul>{render_list(info_points)}</ul>
        </article>
        <article class="info-card">
          <h2>{"こんな人向け" if lang == "ja" else "Who it is for"}</h2>
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
          <span class="badge badge-gate">{"画面項目" if lang == "ja" else "Screen Fields"}</span>
          <ul class="page-link-list bullet-copy">
            {''.join(f'<li><strong>{escape(label)}</strong>: {escape(copy)}</li>' for label, copy in screen_rows)}
          </ul>
        </div>
      </article>
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <span class="badge badge-gate">{"作成リクエスト" if lang == "ja" else "Custom Cutoff Guide Request"}</span>
        <h2>{escape(teaser_title)}</h2>
        <p class="page-copy">{escape(teaser_copy)}</p>
        <p class="page-copy">{escape(teaser_copy_2)}</p>
        <div class="actions">
          {button_link("/gatechecker/request/" if lang == "ja" else "/en/gatechecker/request/", "希望する大会が未対応の場合はこちら" if lang == "ja" else "Open the request page", "primary")}
          {button_link("/gatechecker/races/" if lang == "ja" else "/en/gatechecker/races/", "対応大会を見る" if lang == "ja" else "View Supported Races", "secondary")}
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


def render_gatechecker_request_page(lang: str) -> str:
    if lang == "ja":
        title = "未対応大会の作成リクエスト | 関門ガイド"
        description = "関門ガイドに未対応の大会について、作成リクエストを受け付けています。作成リクエストは有償で、料金は国内大会 2,980円、海外大会 US$29 です。"
        path = "/gatechecker/request/"
        other = "/en/gatechecker/request/"
        hero_title = "未対応大会の作成リクエスト"
        hero_lead = "関門ガイドに未対応の大会について、作成リクエストを受け付けています。"
        hero_copy = "作成リクエストは有償です。料金は国内大会 2,980円、海外大会 US$29 です。"
        actions = "".join([
            request_form_button("作成リクエストフォームへ", lang, "primary"),
            button_link("/gatechecker/races/", "対応大会を見る", "secondary"),
        ])
        pricing_title = "料金"
        process_title = "受付後の流れ"
        publication_title = "公開方針"
        process_copy_1 = "リクエストを受領後、大会情報を確認したうえで、作成可否とPayPalでのお支払い手続きについてご連絡します。"
        process_copy_2 = "お支払い確認後、作成作業を開始します。"
        publication_copy_1 = "作成した大会版は、依頼者専用の非公開アプリではなく、他のユーザーも利用できる形でConnect IQ Storeに公開します。"
        publication_copy_2 = "依頼者専用アプリの販売ではありません。"
        notice_items = [
            "Garmin公式アプリではありません。",
            "大会公式アプリではありません。",
            "関門・エイド情報は必ず大会公式情報も確認してください。",
            "コース変更、ウェーブスタート、天候、主催者発表により情報が変わることがあります。",
            "完走、関門通過、記録達成を保証するものではありません。",
            "大会情報を確認できない場合は作成できません。",
            "支払い前に作成可否を確認します。",
            "作成可否の確認後、PayPalでのお支払い手続きをご案内します。",
            "他のユーザーも利用できる形でConnect IQ Storeに公開します。",
        ]
    else:
        title = "Unsupported Race Request | Cutoff Guide"
        description = "Requests are accepted for races that are not yet supported by Cutoff Guide. This is a paid request, and the price on the English site is US$29."
        path = "/en/gatechecker/request/"
        other = "/gatechecker/request/"
        hero_title = "Unsupported Race Request"
        hero_lead = "Requests are accepted for races that are not yet supported by Cutoff Guide."
        hero_copy = "This is a paid request. Pricing on the English site is US$29."
        actions = "".join([
            request_form_button("Go to the request form", lang, "primary"),
            button_link("/en/gatechecker/races/", "View Supported Races", "secondary"),
        ])
        pricing_title = "Pricing"
        process_title = "Process"
        publication_title = "Publication policy"
        process_copy_1 = "After I receive your request, I will review the race information and contact you about whether the guide can be created and how to complete the PayPal payment."
        process_copy_2 = "Work starts after the payment is confirmed."
        publication_copy_1 = "The completed race edition is not a private requester-only app. It is published on the Connect IQ Store in a form that other users can download as well."
        publication_copy_2 = "This is not a sale of exclusive access."
        notice_items = [
            "This is not an official Garmin app.",
            "This is not an official race app.",
            "Always confirm cutoff and aid-station information with official race information.",
            "Course changes, wave starts, weather, and organizer updates can change the information.",
            "Finishing, beating a cutoff, or hitting a goal time is not guaranteed.",
            "A guide cannot be created if the race information cannot be verified.",
            "The race information is checked before PayPal payment instructions are sent.",
            "The completed app is published on the Connect IQ Store for other users as well.",
        ]

    body = f"""
  <main class="page-shell">
    <section class="hero">
      <div class="hero-card">
        <div>
          <span class="eyebrow eyebrow-gate">{"作成リクエスト" if lang == "ja" else "Request"}</span>
          <h1>{escape(hero_title)}</h1>
          <p class="lead">{escape(hero_lead)}</p>
          <p class="section-copy">{escape(hero_copy)}</p>
          <div class="actions">{actions}</div>
        </div>
      </div>
    </section>

    <section class="page-section">
      <div class="service-layout">
        <article class="cta-panel">
          <span class="badge badge-gate">{escape(pricing_title)}</span>
          <h2>{escape(pricing_title)}</h2>
          <div class="pricing-grid">
            {render_request_pricing_cards(lang)}
          </div>
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
        <span class="badge badge-gate">{escape(publication_title)}</span>
        <h2>{escape(publication_title)}</h2>
        <p class="page-copy">{escape(publication_copy_1)}</p>
        <p class="page-copy">{escape(publication_copy_2)}</p>
        <div class="actions">
          {request_form_button("作成リクエストフォームへ" if lang == "ja" else "Go to the request form", lang, "primary")}
        </div>
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
        if len(race.courses) == 1 and course.code == "default":
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
    if lang == "ja":
        title = "関門ガイド対応大会 | Garminで関門・エイドを確認"
        description = "関門ガイドで対応しているマラソン大会一覧です。掲載されていない大会も、公式情報を確認できる場合は個別大会用の関門ガイド作成リクエストを受け付けます。"
        path = "/gatechecker/races/"
        other = "/en/gatechecker/races/"
        hero_title = "関門ガイド対応大会"
        hero_lead = "関門ガイドは、大会ごとの関門・エイド情報をもとに作成しています。対象レースでは、次の関門までの残り距離、制限時刻までの残り時間、次のエイドまでの距離をGarminで確認できます。"
        actions = ""
        notice = "この一覧と詳細ページは、ページ作成時点で参照した大会情報をもとに作成しています。掲載内容に誤りや更新漏れがある可能性があるため、参加前には必ず大会公式情報を確認してください。"
        request_title = "一覧にない大会をリクエストする"
        request_copy = "対応大会一覧にないレースでも、公式情報から関門・エイド情報を確認できる場合は、個別大会用の関門ガイドとして作成できます。"
        request_copy_2 = "作成した大会版は、他のユーザーも利用できる形でConnect IQ Storeに公開します。"
        request_note = "まずは大会名、公式サイトURL、関門・エイド情報が分かるURLをフォームから送ってください。大会情報を確認したうえで、作成可否とPayPalでのお支払い手続きについてご連絡します。"
    else:
        title = "Supported Races | Garmin cutoff and aid station pages"
        description = "Supported races for Cutoff Guide. If a race is not listed yet, a request can be sent when official cutoff and aid station information is available."
        path = "/en/gatechecker/races/"
        other = "/gatechecker/races/"
        hero_title = "Supported Races"
        hero_lead = "Cutoff Guide is built from race-specific cutoff and aid-station information. For supported races, you can check the next cutoff, time left, and distance to the next aid station on your Garmin watch."
        actions = ""
        notice = "These pages are based on referenced race information and may become outdated. Always confirm official race information before race day."
        request_title = "Request a race that is not listed yet"
        request_copy = "If your race is not listed yet, I may be able to create a race-specific Cutoff Guide when official cutoff and aid-station information is available."
        request_copy_2 = "The completed race edition is published on the Connect IQ Store for other users as well."
        request_note = "Please send the race name, official race website, and any cutoff or aid-station URL through the form. I will review the race information and contact you about feasibility and the PayPal payment steps."

    groups_html = []
    for country, country_races in group_races_by_country(races, lang):
        cards = "".join(render_race_list_card(race, lang) for race in country_races)
        groups_html.append(f"""
      <section class="race-group">
        <div class="section-header">
          <span class="badge badge-gate">{escape(country)}</span>
          <h2>{escape(country)}</h2>
        </div>
        <div class="race-list-grid">
          {cards}
        </div>
      </section>
""")

    body = f"""
  <main class="page-shell">
    <section class="hero">
      <div class="hero-card">
        <div>
          <span class="eyebrow eyebrow-gate">Supported Races</span>
          <h1>{escape(hero_title)}</h1>
          <p class="lead">{escape(hero_lead)}</p>
          {f'<div class="actions">{actions}</div>' if actions else ''}
        </div>
      </div>
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <span class="badge badge-gate">{"作成リクエスト" if lang == "ja" else "Custom Cutoff Guide Request"}</span>
        <h2>{escape(request_title)}</h2>
        <p class="page-copy">{escape(request_copy)}</p>
        <div class="pricing-grid">
          {render_request_pricing_cards(lang)}
        </div>
        <p class="page-copy">{escape(request_copy_2)}</p>
        <div class="actions">
          {button_link("/gatechecker/request/" if lang == "ja" else "/en/gatechecker/request/", "作成リクエストを見る" if lang == "ja" else "View Request Details", "primary")}
        </div>
        <p class="pricing-disclaimer">{escape(request_note)}</p>
      </article>
    </section>

    <section class="page-section">
      {''.join(groups_html)}
    </section>

    <section class="page-section">
      <div class="notice">
        <strong>{"注意事項" if lang == "ja" else "Disclaimer"}:</strong>
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


def detail_course_heading(race: Race, course: Course, lang: str) -> str:
    if len(race.courses) == 1 and course.code == "default":
        return ""
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
    connect_url = race_connect_url(race, lang)
    if lang == "ja":
        title = f"{race.name_ja}の関門・エイド情報 | 関門ガイド"
        description = f"{race.name_ja}の関門地点、制限時刻、エイド地点を整理したページです。関門ガイドでは、Garminで次の関門とエイドまでの情報を確認できます。"
        path = f"/gatechecker/races/{race.slug}/"
        other = f"/en/gatechecker/races/{race.slug}/"
        hero_title = f"{race.name_ja}の関門・エイド情報"
        hero_lead = f"このページでは、{race.name_ja}の関門地点・制限時刻・エイド地点を整理しています。関門ガイドでは、レース中に次の関門までの残り距離と残り時間、次のエイドまでの距離をGarminで確認できるようにします。"
        primary_cta = button_link(connect_url, "Connect IQで見る", "primary", external=True) if connect_url else button_placeholder("準備中", "secondary")
        secondary_cta = button_link("/gatechecker/races/", "対応大会一覧に戻る", "secondary")
        cutoff_copy = "以下は参照時点で確認した関門地点と制限時刻です。実際の大会では変更される可能性があるため、必ず大会公式情報も確認してください。"
        aid_copy = "次のエイドまでの距離確認に使うための情報です。給水・給食の内容までは保証しません。"
        request_title = "別の大会もリクエストできます"
        request_copy = "対応大会にないレースでも、公式情報から関門・エイド情報を確認できる場合は、個別大会用の関門ガイドとして作成できます。"
        request_copy_2 = "作成した関門ガイドはConnect IQで公開され、同じ大会に出る他のランナーもダウンロードできる形になります。"
        request_button = "作成リクエストを見る"
        request_note = "まずは大会名、公式サイトURL、関門・エイド情報が分かるURLをGoogleフォームから送ってください。作成可能な場合にPayPalの支払い案内を送ります。"
        footer_title = "注意事項"
        disclaimer_items = [
            "このページはGarmin公式、大会公式の情報ではありません。",
            "関門・エイド情報は大会公式情報を必ず確認してください。",
            "コース変更、ウェーブスタート、天候変更などにより、実際の条件と異なる場合があります。",
            "完走、関門通過、記録達成を保証するものではありません。",
            "完成後はConnect IQで公開され、依頼者以外も利用できる場合があります。",
        ]
        meta_rows = [
            ("開催日", race.date),
            ("タイムゾーン", race.timezone),
            ("コース数", str(len(race.courses))),
        ]
    else:
        title = f"{race.name_en} Cutoff and Aid Station Info | Cutoff Guide"
        description = f"Cutoff and aid station information for {race.name_en}. Cutoff Guide helps you check the next cutoff, time left, and distance to the next aid station on your Garmin watch."
        path = f"/en/gatechecker/races/{race.slug}/"
        other = f"/gatechecker/races/{race.slug}/"
        hero_title = f"{race.name_en} Cutoff and Aid Station Info"
        hero_lead = f"This page summarizes cutoff points, cutoff times, and aid station locations for {race.name_en}. Cutoff Guide is designed to show the next cutoff, time left, and distance to the next aid station on your Garmin watch during the race."
        primary_cta = button_link(connect_url, "View on Connect IQ", "primary", external=True) if connect_url else button_placeholder("Coming soon", "secondary")
        secondary_cta = button_link("/en/gatechecker/races/", "Back to Supported Races", "secondary")
        cutoff_copy = "The cutoff points and times below are based on available race information at the time of preparation. Please always check the official race information before race day."
        aid_copy = "This information is used to estimate the distance to the next aid station. Food and drink availability is not guaranteed on this page."
        request_title = "You can request another race too"
        request_copy = "If your race is not listed yet, I may be able to create a race-specific Cutoff Guide when official cutoff and aid-station information is available."
        request_copy_2 = "Completed guides are published on Connect IQ, so other runners in the same race may be able to download them as well."
        request_button = "View Request Details"
        request_note = "Please send the race name, official website, and any cutoff or aid-station URL through the Google Form. PayPal instructions are sent only after the race information is checked."
        footer_title = "Important Notes"
        disclaimer_items = [
            "This site is not affiliated with Garmin or the race organizer.",
            "Always confirm cutoff and aid-station details with official race information.",
            "Race information may change because of course changes, wave starts, weather, or organizer updates.",
            "Finishing, beating a cutoff, or hitting a goal time is not guaranteed.",
            "Finished guides are published on Connect IQ and may be available to other runners.",
        ]
        meta_rows = [
            ("Date", race.date),
            ("Timezone", race.timezone),
            ("Courses", str(len(race.courses))),
        ]

    cutoff_blocks = "".join(render_cutoff_course_block(race, course, lang) for course in race.courses)
    aid_blocks = "".join(render_aid_course_block(race, course, lang) for course in race.courses)
    extra_pills = []
    if connect_url:
        extra_pills.append("Connect IQ公開済み" if lang == "ja" else "Connect IQ available")
    else:
        extra_pills.append("準備中" if lang == "ja" else "Coming soon")

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
        </div>
        <div class="quick-card detail-summary">
          <h2>{"大会データ" if lang == "ja" else "Race Data"}</h2>
          <div class="meta-stack">
            {render_meta_rows(meta_rows)}
          </div>
          <div class="meta-pills">
            {render_pills(extra_pills)}
          </div>
        </div>
      </div>
    </section>

    <section class="page-section">
      <div class="section-header">
        <span class="eyebrow eyebrow-gate">Cutoff</span>
        <h2>{"関門情報" if lang == "ja" else "Cutoff Information"}</h2>
        <p class="section-copy">{escape(cutoff_copy)}</p>
      </div>
      <div class="course-section-grid">
        {cutoff_blocks}
      </div>
    </section>

    <section class="page-section">
      <div class="section-header">
        <span class="eyebrow eyebrow-gate">Aid</span>
        <h2>{"エイド情報" if lang == "ja" else "Aid Station Information"}</h2>
        <p class="section-copy">{escape(aid_copy)}</p>
      </div>
      <div class="course-section-grid">
        {aid_blocks}
      </div>
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <span class="badge badge-gate">{"作成リクエスト" if lang == "ja" else "Custom Cutoff Guide Request"}</span>
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
        <span class="badge badge-gate">{"注意事項" if lang == "ja" else "Important Notes"}</span>
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
