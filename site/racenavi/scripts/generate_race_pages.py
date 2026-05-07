#!/usr/bin/env python3
from __future__ import annotations

from dataclasses import dataclass
from html import escape
from pathlib import Path
from typing import Any

import yaml


BASE_URL = "https://racenavi.jpn.org"
SITE_DIR = Path(__file__).resolve().parents[1]
REPO_DIR = SITE_DIR.parents[1]
RACE_DEFS_DIR = REPO_DIR / "apps" / "GateChecker" / "race_defs"


RACENAVI_IMAGE = "/assets/shot02_one_screen.png"
GATE_IMAGE_JA = "/assets/gatechecker_hero_jp.png"
GATE_IMAGE_EN = "/assets/gatechecker_hero_en.png"
FAVICON_IMAGE = "/assets/mainIcon.png"
OG_IMAGE = f"{BASE_URL}/assets/shot02_one_screen.png"
X_URL = "https://x.com/racenavi_run"


@dataclass
class Course:
    code: str
    name_ja: str
    name_en: str
    distance_label_ja: str
    distance_label_en: str
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
    courses: list[Course]


def load_yaml(path: Path) -> dict[str, Any]:
    return yaml.safe_load(path.read_text(encoding="utf-8")) or {}


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def write_text(path: Path, text: str) -> None:
    ensure_dir(path.parent)
    path.write_text(text.rstrip() + "\n", encoding="utf-8")


def fmt_num(value: float) -> str:
    text = f"{value:.3f}".rstrip("0").rstrip(".")
    return text


def mi_to_km(value: float) -> float:
    return value * 1.609344


def distance_label(value: float, unit: str, lang: str) -> str:
    if unit == "km":
        return f"{fmt_num(value)} km"
    km = mi_to_km(value)
    if lang == "ja":
        return f"{fmt_num(value)} mi / {fmt_num(km)} km"
    return f"{fmt_num(value)} mi / {fmt_num(km)} km"


def point_label(gate: dict[str, Any], lang: str) -> str:
    if gate.get("point") == "GOAL":
        return "GOAL"
    if "point_mi" in gate:
        return distance_label(float(gate["point_mi"]), "mi", lang)
    if "point" in gate:
        return distance_label(float(gate["point"]), "km", lang)
    return ""


def aid_distance_label(aid: dict[str, Any], lang: str) -> str:
    if "mi" in aid:
        return distance_label(float(aid["mi"]), "mi", lang)
    if "km" in aid:
        return distance_label(float(aid["km"]), "km", lang)
    return ""


def localized_name(value: Any, lang: str, fallback: str = "") -> str:
    if isinstance(value, dict):
        return value.get("jpn" if lang == "ja" else "eng") or value.get("eng") or value.get("jpn") or fallback
    if isinstance(value, str):
        return value
    return fallback


def normalize_course_names(course: dict[str, Any], race_name_ja: str, race_name_en: str, index: int) -> tuple[str, str]:
    name_ja = course.get("courseNameJa") or course.get("courseName") or course.get("courseCode")
    name_en = course.get("courseNameEn") or course.get("courseName") or course.get("courseCode")
    if name_ja and name_en:
        return str(name_ja), str(name_en)
    if name_ja:
        return str(name_ja), str(name_ja)
    if name_en:
        return str(name_en), str(name_en)
    if len(race_name_ja) > 0:
        return f"{race_name_ja} コース{index}", f"{race_name_en} Course {index}"
    return f"コース{index}", f"Course {index}"


def normalize_courses(data: dict[str, Any], race_name_ja: str, race_name_en: str) -> list[Course]:
    if data.get("courses"):
        raw_courses = data["courses"]
    else:
        raw_courses = [{
            "courseCode": "default",
            "courseNameJa": race_name_ja,
            "courseNameEn": race_name_en,
            "distance_km": data.get("race", {}).get("distance_km"),
            "distance_mi": data.get("race", {}).get("distance_mi"),
            "gates": data.get("gates", []),
            "aids": data.get("aids", []),
        }]

    courses: list[Course] = []
    for idx, raw in enumerate(raw_courses, start=1):
        name_ja, name_en = normalize_course_names(raw, race_name_ja, race_name_en, idx)
        distance_km = raw.get("distance_km")
        distance_mi = raw.get("distance_mi")
        if distance_km is not None:
            label_ja = distance_label(float(distance_km), "km", "ja")
            label_en = distance_label(float(distance_km), "km", "en")
        elif distance_mi is not None:
            label_ja = distance_label(float(distance_mi), "mi", "ja")
            label_en = distance_label(float(distance_mi), "mi", "en")
        else:
            label_ja = ""
            label_en = ""

        courses.append(Course(
            code=str(raw.get("courseCode") or f"course-{idx}"),
            name_ja=name_ja,
            name_en=name_en,
            distance_label_ja=label_ja,
            distance_label_en=label_en,
            gates=list(raw.get("gates", [])),
            aids=list(raw.get("aids", [])),
        ))
    return courses


def resolve_country(slug: str, timezone: str) -> tuple[str, str]:
    by_timezone = {
        "Asia/Tokyo": ("日本", "Japan"),
        "America/Vancouver": ("カナダ", "Canada"),
        "America/Toronto": ("カナダ", "Canada"),
        "America/Chicago": ("アメリカ", "United States"),
        "America/New_York": ("アメリカ", "United States"),
        "Europe/London": ("イギリス", "United Kingdom"),
        "Europe/Oslo": ("ノルウェー", "Norway"),
        "Europe/Stockholm": ("スウェーデン", "Sweden"),
        "Europe/Luxembourg": ("ルクセンブルク", "Luxembourg"),
    }
    if timezone in by_timezone:
        return by_timezone[timezone]
    return ("その他", "Other")


def is_public_race(slug: str, name_ja: str, name_en: str) -> bool:
    lowered = f"{slug} {name_ja} {name_en}".lower()
    blocked_tokens = ["sample", "beta", "check", "確認用"]
    return not any(token in lowered for token in blocked_tokens)


def load_races() -> list[Race]:
    index = load_yaml(RACE_DEFS_DIR / "race_index.yml")
    races: list[Race] = []
    for slug, meta in index.get("races", {}).items():
        definition_path = RACE_DEFS_DIR / meta["definition"]
        data = load_yaml(definition_path)
        display_name = data.get("display_name", {})
        name_ja = localized_name(display_name, "ja", slug)
        name_en = localized_name(display_name, "en", slug)
        race_info = data.get("race", {})
        public_slug = str(data.get("slug") or data.get("race_key") or slug)
        country_ja, country_en = resolve_country(public_slug, str(race_info.get("timezone") or ""))
        races.append(Race(
            slug=public_slug,
            name_ja=name_ja,
            name_en=name_en,
            date=str(race_info.get("date") or ""),
            timezone=str(race_info.get("timezone") or ""),
            country_ja=country_ja,
            country_en=country_en,
            courses=normalize_courses(data, name_ja, name_en),
        ))
    return races


def absolute_url(path: str) -> str:
    if path == "/":
        return BASE_URL + "/"
    return BASE_URL + path


def render_header(lang: str) -> str:
    if lang == "ja":
        nav_items = [
            ("/racenavi/", "RaceNavi"),
            ("/racenavi/custom/", "カスタム設定"),
            ("/gatechecker/", "関門ガイド"),
            ("/gatechecker/races/", "対応大会"),
            ("/en/", "English"),
        ]
    else:
        nav_items = [
            ("/en/racenavi/", "RaceNavi"),
            ("/en/racenavi/custom/", "Custom Setup"),
            ("/en/gatechecker/", "Cutoff Guide"),
            ("/en/gatechecker/races/", "Supported Races"),
            ("/", "日本語"),
        ]
    nav_html = "".join(f'<a href="{href}">{escape(label)}</a>' for href, label in nav_items)
    return f"""
  <header class="page-shell site-header">
    <a class="site-logo" href="{"/" if lang == "ja" else "/en/"}">
      <img class="site-logo-mark" src="{FAVICON_IMAGE}" alt="RaceNavi icon" />
      <span>RaceNavi</span>
    </a>
    <nav class="site-nav" aria-label="{"メインナビゲーション" if lang == "ja" else "Main navigation"}">
      {nav_html}
    </nav>
  </header>
"""


def render_footer(lang: str) -> str:
    if lang == "ja":
        links = [
            ("/", "トップ"),
            ("/racenavi/", "RaceNavi"),
            ("/racenavi/custom/", "カスタム設定"),
            ("/gatechecker/", "関門ガイド"),
            ("/gatechecker/races/", "対応大会"),
            ("/en/", "English"),
        ]
        title = "RaceNavi"
        summary = "マラソン中に見たい情報をGarminで確認するためのアプリ群。"
        disclaimer = "RaceNaviと関門ガイドはGarmin向けアプリです。Garmin公式、または各大会公式のアプリではありません。"
        contact = f'問い合わせ先: <a href="{X_URL}" target="_blank" rel="noreferrer">X のDM @racenavi_run</a>'
    else:
        links = [
            ("/en/", "Home"),
            ("/en/racenavi/", "RaceNavi"),
            ("/en/racenavi/custom/", "Custom Setup"),
            ("/en/gatechecker/", "Cutoff Guide"),
            ("/en/gatechecker/races/", "Supported Races"),
            ("/", "日本語"),
        ]
        title = "RaceNavi"
        summary = "Independent Garmin apps built for marathon race-day pacing, cutoff checks, and aid-station awareness."
        disclaimer = "RaceNavi and Cutoff Guide are independently developed Garmin apps. They are not official Garmin apps or official race apps."
        contact = f'Contact: <a href="{X_URL}" target="_blank" rel="noreferrer">X DM @racenavi_run</a>'
    link_html = "".join(f'<a href="{href}">{escape(label)}</a>' for href, label in links)
    return f"""
  <footer class="page-shell site-footer">
    <div class="footer-block">
      <strong>{escape(title)}</strong>
      <p>{escape(summary)}</p>
      <p>{escape(disclaimer)}</p>
      <p>{contact}</p>
    </div>
    <div class="footer-links">
      {link_html}
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


def render_top_page() -> str:
    body = f"""
  <main class="page-shell">
    <section class="hero">
      <div class="hero-card">
        <div>
          <span class="eyebrow">Garmin race support apps</span>
          <h1>Garminで、レース中に見たい情報を確認する。</h1>
          <p class="lead">RaceNaviは、Garmin向けアプリです。目的の違う2つのアプリを開発しています。</p>
        </div>
      </div>
    </section>

    <section class="page-section" aria-label="アプリ一覧">
      <div class="app-grid">
        <article class="app-card">
          <span class="app-label label-racenavi">RaceNavi</span>
          <h2>心拍・ペースを見るアプリ</h2>
          <p class="app-summary">フルマラソン中に、今の心拍・ペース・目標との差を確認するためのGarminアプリです。</p>
          <div class="app-image">
            <img src="{RACENAVI_IMAGE}" alt="RaceNaviの画面イメージ。心拍、ペース、目標との差、予測タイムを表示するGarminアプリ。" />
          </div>
          <div class="info-card">
            <h3>表示する情報</h3>
            <ul>
              <li>現在の心拍</li>
              <li>心拍の上限目安</li>
              <li>現在のペース</li>
              <li>目標との差</li>
              <li>予測ゴールタイム</li>
            </ul>
          </div>
          <div class="actions">
            <a class="button button-primary" href="/racenavi/">RaceNaviを見る</a>
            <a class="button button-secondary" href="/racenavi/custom/">カスタム設定</a>
          </div>
        </article>

        <article class="app-card">
          <span class="app-label label-gate">関門ガイド</span>
          <h2>関門・エイドを見るアプリ</h2>
          <p class="app-summary">マラソン中に、次の関門とエイドを確認するためのGarminアプリです。</p>
          <div class="app-image">
            <img src="{GATE_IMAGE_JA}" alt="関門ガイドの画面イメージ。次の関門とエイドまでの情報をGarminで確認するアプリ。" />
          </div>
          <div class="info-card">
            <h3>表示する情報</h3>
            <ul>
              <li>次の関門地点</li>
              <li>関門までの残り距離</li>
              <li>関門時刻</li>
              <li>関門までの残り時間</li>
              <li>次のエイド地点</li>
              <li>エイドまでの残り距離</li>
            </ul>
          </div>
          <div class="info-card">
            <h3>提供方法</h3>
            <ul>
              <li>大会ごとに関門・エイド情報を登録</li>
              <li>対応大会ページで対象レースを確認</li>
              <li>海外大会向けには英語名「Cutoff Guide」も想定</li>
            </ul>
          </div>
          <div class="actions">
            <a class="button button-primary" href="/gatechecker/">関門ガイドを見る</a>
            <a class="button button-secondary" href="/gatechecker/races/">対応大会を見る</a>
          </div>
        </article>
      </div>
    </section>

    <section class="page-section">
      <div class="notice">
        <strong>注意事項：</strong>
        RaceNaviと関門ガイドはGarmin向けアプリです。Garmin公式、または各大会公式のアプリではありません。関門・エイド情報は、必ず大会公式情報も確認してください。
      </div>
    </section>
  </main>
"""
    return build_page(
        lang="ja",
        title="RaceNavi | Garmin向けレース支援アプリ",
        description="RaceNaviはGarmin向けの個人開発レース支援アプリです。心拍・ペースを見るRaceNaviと、関門・エイドを見る関門ガイドを提供しています。",
        canonical_path="/",
        ja_path="/",
        en_path="/en/",
        body_html=body,
    )


def render_racenavi_page(lang: str) -> str:
    if lang == "ja":
        title = "RaceNavi | 心拍・ペースでレース中の判断を支えるGarminアプリ"
        description = "RaceNaviは、フルマラソン中に心拍・ペース・目標との差・予測ゴールタイムをGarminで確認するためのアプリです。"
        path = "/racenavi/"
        other = "/en/racenavi/"
        hero = (
            "RaceNavi",
            "心拍とペースで、レース中の判断を支える。",
            "RaceNaviは、フルマラソン本番で現在の心拍、ペース、目標との差、予測ゴールタイムを確認するためのGarmin向けデータフィールドです。",
        )
        sections = f"""
    <section class="page-section">
      <div class="info-grid">
        <article class="info-card">
          <h2>表示できる情報</h2>
          <ul>
            <li>現在の心拍</li>
            <li>心拍の上限目安</li>
            <li>現在のペース</li>
            <li>目標との差</li>
            <li>予測ゴールタイム</li>
            <li>距離</li>
            <li>経過時間</li>
          </ul>
        </article>
        <article class="info-card">
          <h2>こんな人向け</h2>
          <ul>
            <li>フルマラソンで序盤に突っ込みすぎる人</li>
            <li>心拍を見ながら走りたい人</li>
            <li>サブ4など目標タイムを狙いたい人</li>
            <li>Garminの通常画面だけでは判断しづらい人</li>
          </ul>
        </article>
      </div>
    </section>

    <section class="page-section">
      <div class="section-header">
        <span class="eyebrow">Screen</span>
        <h2>画面イメージ</h2>
      </div>
      <article class="info-card">
        <div class="app-image">
          <img src="{RACENAVI_IMAGE}" alt="RaceNaviの画面イメージ。心拍、ペース、目標との差、予測タイムを表示するGarminアプリ。" />
        </div>
      </article>
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <span class="badge badge-racenavi">Custom Setup</span>
        <h2>自分の目標に合わせて調整する</h2>
        <p class="page-copy">RaceNaviは通常設定でも使えますが、目標タイムや心拍情報に合わせたカスタム設定も検討しています。</p>
        <div class="actions">
          <a class="button button-primary" href="/racenavi/custom/">カスタム設定を見る</a>
        </div>
      </article>
    </section>

    <section class="page-section">
      <div class="notice">
        <strong>注意事項：</strong>
        RaceNaviはGarmin向けアプリです。Garmin公式アプリではありません。
      </div>
    </section>
"""
    else:
        title = "RaceNavi | Garmin App for Marathon Pacing and Heart Rate"
        description = "RaceNavi is an independently developed Garmin data field that helps runners check heart rate, pace, target gap, and estimated finish time during a marathon."
        path = "/en/racenavi/"
        other = "/racenavi/"
        hero = (
            "RaceNavi",
            "Heart rate and pacing on one Garmin screen.",
            "RaceNavi helps you check your current heart rate, pace, target gap, and estimated finish time during a marathon.",
        )
        sections = f"""
    <section class="page-section">
      <div class="info-grid">
        <article class="info-card">
          <h2>What it shows</h2>
          <ul>
            <li>Current heart rate</li>
            <li>Heart-rate cap</li>
            <li>Current pace</li>
            <li>Gap from target</li>
            <li>Estimated finish time</li>
            <li>Distance</li>
            <li>Elapsed time</li>
          </ul>
        </article>
        <article class="info-card">
          <h2>Who it is for</h2>
          <ul>
            <li>Runners who want to avoid going out too hard</li>
            <li>Runners who use heart rate during races</li>
            <li>Runners aiming for a target finish time</li>
            <li>Runners who want a simple Garmin race-day screen</li>
          </ul>
        </article>
      </div>
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <span class="badge badge-racenavi">Custom Setup</span>
        <h2>Custom setup</h2>
        <p class="page-copy">If you want to tune RaceNavi around your goal time and heart-rate profile, the Custom Setup page outlines the planned service.</p>
        <div class="actions">
          <a class="button button-primary" href="/en/racenavi/custom/">Custom Setup</a>
        </div>
      </article>
    </section>

    <section class="page-section">
      <div class="notice">
        <strong>Disclaimer:</strong>
        RaceNavi is independently developed. It is not medical advice and it is not an official Garmin app.
      </div>
    </section>
"""

    eyebrow_class = "eyebrow"
    body = f"""
  <main class="page-shell">
    <section class="hero">
      <div class="hero-card">
        <div>
          <span class="{eyebrow_class}">{escape(hero[0])}</span>
          <h1>{escape(hero[1])}</h1>
          <p class="lead">{escape(hero[2])}</p>
        </div>
      </div>
    </section>
{sections}
  </main>
"""
    return build_page(
        lang=lang,
        title=title,
        description=description,
        canonical_path=path,
        ja_path=other if lang == "en" else path,
        en_path=path if lang == "en" else other,
        body_html=body,
    )


def render_custom_page(lang: str) -> str:
    if lang == "ja":
        title = "RaceNaviカスタム設定 | 目標タイムと心拍に合わせたレース設定"
        description = "RaceNaviカスタム設定は、目標タイムや心拍情報をもとに、レース中に使う心拍上限やペース方針を整理するサービスです。"
        path = "/racenavi/custom/"
        other = "/en/racenavi/custom/"
        hero = (
            "Custom Setup",
            "RaceNaviを、自分のレース用に調整する。",
            "目標タイム、心拍情報、過去の走行データをもとに、RaceNaviで使う設定を整理します。",
        )
        body_sections = """
    <section class="page-section">
      <div class="info-grid">
        <article class="info-card">
          <h2>できること</h2>
          <ul>
            <li>目標タイムの確認</li>
            <li>心拍情報の整理</li>
            <li>CAP心拍の目安設定</li>
            <li>レース中の判断方針の整理</li>
            <li>RaceNavi用カスタムコードの作成予定</li>
          </ul>
        </article>
        <article class="info-card">
          <h2>必要な情報</h2>
          <ul>
            <li>目標タイム</li>
            <li>最大心拍</li>
            <li>安静時心拍</li>
            <li>LTHRがあればLTHR</li>
            <li>過去のレースデータまたはFITデータ</li>
            <li>出場予定レース</li>
          </ul>
        </article>
      </div>
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <span class="badge badge-racenavi">Status</span>
        <h2>価格・募集</h2>
        <ul class="link-list">
          <li>先着モニター募集予定</li>
          <li>通常価格は検討中</li>
          <li>以前検討した価格 4,980円 は、現時点では予定または検討中の扱いです。</li>
        </ul>
        <div class="actions">
          <span class="button button-secondary button-disabled" aria-disabled="true">準備中</span>
        </div>
      </article>
    </section>

    <section class="page-section">
      <div class="notice">
        <strong>注意事項：</strong>
        医療的助言ではありません。体調や気象条件によって適切な心拍は変わります。最終判断はランナー本人が行ってください。
      </div>
    </section>
"""
    else:
        title = "RaceNavi Custom Setup | Race Settings Based on Your Goal and Heart Rate"
        description = "RaceNavi Custom Setup helps prepare race-day settings based on your target time, heart-rate profile, and past running data."
        path = "/en/racenavi/custom/"
        other = "/racenavi/custom/"
        hero = (
            "Custom Setup",
            "Tune RaceNavi for your own race.",
            "Custom Setup helps prepare RaceNavi settings based on your target time, heart-rate profile, and past running data.",
        )
        body_sections = """
    <section class="page-section">
      <div class="info-grid">
        <article class="info-card">
          <h2>What is included</h2>
          <ul>
            <li>Target time review</li>
            <li>Heart-rate profile review</li>
            <li>Heart-rate cap suggestions</li>
            <li>Race-day pacing notes</li>
            <li>RaceNavi custom code, if available</li>
          </ul>
        </article>
        <article class="info-card">
          <h2>Information needed</h2>
          <ul>
            <li>Target time</li>
            <li>Max heart rate</li>
            <li>Resting heart rate</li>
            <li>LTHR if available</li>
            <li>Recent race or FIT data</li>
            <li>Target race</li>
          </ul>
        </article>
      </div>
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <span class="badge badge-racenavi">Status</span>
        <h2>Status</h2>
        <ul class="link-list">
          <li>Pilot / monitor program planned</li>
          <li>Fixed payment implementation is intentionally deferred for now</li>
        </ul>
      </article>
    </section>

    <section class="page-section">
      <div class="notice">
        <strong>Disclaimer:</strong>
        This is not medical advice. Race-day conditions vary by weather, course, and runner condition.
      </div>
    </section>
"""

    body = f"""
  <main class="page-shell">
    <section class="hero">
      <div class="hero-card">
        <div>
          <span class="eyebrow">{escape(hero[0])}</span>
          <h1>{escape(hero[1])}</h1>
          <p class="lead">{escape(hero[2])}</p>
        </div>
      </div>
    </section>
{body_sections}
  </main>
"""
    return build_page(
        lang=lang,
        title=title,
        description=description,
        canonical_path=path,
        ja_path=other if lang == "en" else path,
        en_path=path if lang == "en" else other,
        body_html=body,
    )


def render_gatechecker_page(lang: str) -> str:
    if lang == "ja":
        title = "関門ガイド | 関門・エイドをGarminで確認するアプリ"
        description = "関門ガイドは、マラソン中に次の関門地点、関門時刻、残り距離、残り時間、次のエイドをGarminで確認するためのアプリです。"
        path = "/gatechecker/"
        other = "/en/gatechecker/"
        hero = (
            "関門ガイド",
            "次の関門とエイドを、Garminで確認する。",
            "関門ガイドは、大会ごとの関門・エイド情報をもとに、レース中に次の関門とエイドを確認するためのGarmin向けアプリです。",
        )
        image = GATE_IMAGE_JA
        image_alt = "関門ガイドの画面イメージ。次の関門地点とエイドまでの情報をGarminで確認するアプリ。"
        body_sections = f"""
    <section class="page-section">
      <div class="info-grid">
        <article class="info-card">
          <h2>表示する情報</h2>
          <ul>
            <li>次の関門地点</li>
            <li>関門までの残り距離</li>
            <li>関門時刻</li>
            <li>関門までの残り時間</li>
            <li>次のエイド地点</li>
            <li>エイドまでの残り距離</li>
          </ul>
        </article>
        <article class="info-card">
          <h2>こんな人向け</h2>
          <ul>
            <li>関門が気になる人</li>
            <li>完走狙いの人</li>
            <li>ウルトラマラソンなど関門が多い大会に出る人</li>
            <li>次のエイドまでの距離を知りたい人</li>
            <li>大会別の関門情報をGarminで見たい人</li>
          </ul>
        </article>
      </div>
    </section>

    <section class="page-section">
      <div class="section-header">
        <span class="eyebrow eyebrow-gate">Race-specific</span>
        <h2>大会別対応</h2>
        <p class="section-intro">関門ガイドは、大会ごとに関門・エイド情報を登録して提供します。</p>
      </div>
      <article class="cta-panel">
        <div class="app-image">
          <img src="{image}" alt="{escape(image_alt)}" />
        </div>
        <div class="actions">
          <a class="button button-primary" href="/gatechecker/races/">対応大会を見る</a>
        </div>
      </article>
    </section>

    <section class="page-section">
      <div class="notice">
        <strong>注意事項：</strong>
        関門・エイド情報は参照時点の情報をもとに掲載しています。内容に誤りや更新漏れがある場合があります。必ず大会公式情報も確認してください。対応大会の追加リクエストは <a href="{X_URL}" target="_blank" rel="noreferrer">X のDM @racenavi_run</a> で連絡してください。関門ガイドは各大会公式アプリではありません。
      </div>
    </section>
"""
    else:
        title = "Cutoff Guide | Garmin App for Marathon Cutoff Times and Aid Stations"
        description = "Cutoff Guide is an independently developed Garmin app that helps runners check the next cutoff point, time left, and aid station during a race."
        path = "/en/gatechecker/"
        other = "/gatechecker/"
        hero = (
            "Cutoff Guide",
            "Check the next cutoff and aid station on your Garmin.",
            "Cutoff Guide uses race-specific cutoff and aid station data to help runners check what comes next during a race.",
        )
        image = GATE_IMAGE_EN
        image_alt = "Cutoff Guide screen image showing the next cutoff point and aid station on a Garmin watch."
        body_sections = f"""
    <section class="page-section">
      <div class="info-grid">
        <article class="info-card">
          <h2>What it shows</h2>
          <ul>
            <li>Next cutoff point</li>
            <li>Distance to cutoff</li>
            <li>Cutoff time</li>
            <li>Time left</li>
            <li>Next aid station</li>
            <li>Distance to aid station</li>
          </ul>
        </article>
        <article class="info-card">
          <h2>Who it is for</h2>
          <ul>
            <li>Runners worried about cutoff times</li>
            <li>Runners aiming to finish within the time limit</li>
            <li>Ultramarathon runners</li>
            <li>Runners who want aid station distances on their Garmin</li>
          </ul>
        </article>
      </div>
    </section>

    <section class="page-section">
      <article class="cta-panel">
        <div class="app-image">
          <img src="{image}" alt="{escape(image_alt)}" />
        </div>
        <div>
          <span class="badge badge-gate">Race-specific versions</span>
          <h2>Race-specific versions</h2>
          <p class="page-copy">Cutoff Guide supports race-specific pages for selected events.</p>
          <div class="actions">
            <a class="button button-primary" href="/en/gatechecker/races/">Supported Races</a>
          </div>
        </div>
      </article>
    </section>

    <section class="page-section">
      <div class="notice">
        <strong>Disclaimer:</strong>
        Cutoff and aid-station information is based on referenced race information and may include mistakes or outdated details. Always confirm official race information. If you want to request another supported race, contact <a href="{X_URL}" target="_blank" rel="noreferrer">X DM @racenavi_run</a>. Cutoff Guide is not an official race app.
      </div>
    </section>
"""

    eyebrow = "eyebrow eyebrow-gate"
    body = f"""
  <main class="page-shell">
    <section class="hero">
      <div class="hero-card">
        <div>
          <span class="{eyebrow}">{escape(hero[0])}</span>
          <h1>{escape(hero[1])}</h1>
          <p class="lead">{escape(hero[2])}</p>
        </div>
      </div>
    </section>
{body_sections}
  </main>
"""
    return build_page(
        lang=lang,
        title=title,
        description=description,
        canonical_path=path,
        ja_path=other if lang == "en" else path,
        en_path=path if lang == "en" else other,
        body_html=body,
    )


def course_summary(course: Course, lang: str) -> str:
    name = course.name_ja if lang == "ja" else course.name_en
    distance = course.distance_label_ja if lang == "ja" else course.distance_label_en
    if distance:
        return f"{escape(name)} ({escape(distance)})"
    return escape(name)


def race_course_list_label(race: Race, lang: str) -> str:
    if len(race.courses) == 1:
        course = race.courses[0]
        distance = course.distance_label_ja if lang == "ja" else course.distance_label_en
        return distance or (course.name_ja if lang == "ja" else course.name_en)
    parts = []
    for course in race.courses:
        name = course.name_ja if lang == "ja" else course.name_en
        distance = course.distance_label_ja if lang == "ja" else course.distance_label_en
        parts.append(f"{name} ({distance})" if distance else name)
    return " / ".join(parts)


def render_race_table_row(race: Race, lang: str) -> str:
    if lang == "ja":
        title = race.name_ja
        details_href = f"/gatechecker/races/{race.slug}/"
        button = "詳細を見る"
    else:
        title = race.name_en
        details_href = f"/en/gatechecker/races/{race.slug}/"
        button = "View guide"

    return f"<tr><td>{escape(race.date)}</td><td>{escape(title)}</td><td>{escape(race_course_list_label(race, lang))}</td><td><a class=\"button button-secondary\" href=\"{details_href}\">{button}</a></td></tr>"


def group_races_by_country(races: list[Race], lang: str) -> list[tuple[str, list[Race]]]:
    groups: dict[str, list[Race]] = {}
    for race in races:
        country = race.country_ja if lang == "ja" else race.country_en
        groups.setdefault(country, []).append(race)

    if lang == "ja":
        ordered_names = sorted(groups, key=lambda country: (0 if country == "日本" else 1, country))
    else:
        ordered_names = sorted(groups)

    ordered = []
    for country in ordered_names:
        ordered.append((country, sorted(groups[country], key=lambda item: (item.date, item.name_ja, item.slug))))
    return ordered


def render_races_index(races: list[Race], lang: str) -> str:
    if lang == "ja":
        title = "関門ガイド対応大会 | Garminで関門・エイドを確認"
        description = "関門ガイドで対応しているマラソン大会の一覧です。大会ごとに、関門・エイド情報をGarminで確認できます。"
        path = "/gatechecker/races/"
        other = "/en/gatechecker/races/"
        hero = ("Supported races", "関門ガイド対応大会", f"関門ガイドは、大会ごとの関門・エイド情報をもとに提供します。対応大会の追加リクエストは <a href=\"{X_URL}\" target=\"_blank\" rel=\"noreferrer\">X のDM @racenavi_run</a> で連絡してください。")
        notice = "この一覧は、ページ作成時に参照した大会情報をもとに作成しています。掲載内容に誤りや更新漏れがある場合があります。参加前には必ず大会公式サイトや大会案内で最新情報を確認してください。"
    else:
        title = "Supported Races | Cutoff Guide for Garmin"
        description = "Supported races for Cutoff Guide. Check race-specific cutoff and aid station pages for supported events."
        path = "/en/gatechecker/races/"
        other = "/gatechecker/races/"
        hero = ("Supported races", "Supported races", f"Cutoff Guide provides race-specific pages for supported events. To request another supported race, contact <a href=\"{X_URL}\" target=\"_blank\" rel=\"noreferrer\">X DM @racenavi_run</a>.")
        notice = "These pages are based on referenced race information and may include mistakes or outdated details. Always confirm official race information before race day."

    groups = []
    for country, country_races in group_races_by_country(races, lang):
        rows = "".join(render_race_table_row(race, lang) for race in country_races)
        if lang == "ja":
            headers = "<th>日付</th><th>大会名</th><th>コース</th><th>詳細</th>"
        else:
            headers = "<th>Date</th><th>Race</th><th>Course</th><th>Guide</th>"
        groups.append(f"""
        <section class="race-group">
          <span class="badge badge-gate">{escape(country)}</span>
          <h2>{escape(country)}</h2>
          <div class="table-wrap">
            <table class="data-table">
              <thead>
                <tr>{headers}</tr>
              </thead>
              <tbody>
                {rows}
              </tbody>
            </table>
          </div>
        </section>
""")
    groups_html = "".join(groups)
    body = f"""
  <main class="page-shell">
    <section class="hero">
      <div class="hero-card">
        <div>
          <span class="eyebrow eyebrow-gate">{escape(hero[0])}</span>
          <h1>{escape(hero[1])}</h1>
          <p class="lead">{hero[2]}</p>
        </div>
      </div>
    </section>

    <section class="page-section">
      <div class="race-group-grid">
{groups_html}
      </div>
    </section>

    <section class="page-section">
      <div class="notice">
        <strong>{"注意事項" if lang == "ja" else "Disclaimer"}:</strong>
        {notice}
      </div>
    </section>
  </main>
"""
    return build_page(
        lang=lang,
        title=title,
        description=description,
        canonical_path=path,
        ja_path=other if lang == "en" else path,
        en_path=path if lang == "en" else other,
        body_html=body,
    )


def render_gate_rows(gates: list[dict[str, Any]], lang: str) -> str:
    rows = []
    for index, gate in enumerate(gates, start=1):
        point = point_label(gate, lang)
        cutoff = str(gate.get("cutoff") or "")
        rows.append(
            f"<tr><td>{index}</td><td>{escape(point)}</td><td>{escape(point)}</td><td>{escape(cutoff)}</td></tr>"
        )
    return "".join(rows)


def render_aid_rows(aids: list[dict[str, Any]], lang: str) -> str:
    rows = []
    for index, aid in enumerate(aids, start=1):
        distance = aid_distance_label(aid, lang)
        note = localized_name(aid.get("name"), lang, "")
        rows.append(
            f"<tr><td>{index}</td><td>{escape(distance)}</td><td>{escape(note)}</td></tr>"
        )
    return "".join(rows)


def render_course_block(race: Race, course: Course, lang: str) -> str:
    if lang == "ja":
        name = course.name_ja
        distance = course.distance_label_ja
        gate_heading = "関門一覧"
        aid_heading = "エイド一覧"
        gate_empty = "現在、表示できる関門データを確認中です。"
        aid_empty = "現在、表示できるエイドデータを確認中です。"
        labels = ("距離", "関門数", "エイド数")
    else:
        name = course.name_en
        distance = course.distance_label_en
        gate_heading = "Cutoff points"
        aid_heading = "Aid stations"
        gate_empty = "Cutoff-point data is not currently available for this course."
        aid_empty = "Aid-station data is not currently available for this course."
        labels = ("Distance", "Cutoff points", "Aid stations")

    gates_html = (
        f"""
        <div>
          <h3>{gate_heading}</h3>
          <div class="table-wrap">
            <table class="data-table">
              <thead>
                <tr>
                  <th>No</th>
                  <th>{"地点" if lang == "ja" else "Point"}</th>
                  <th>{"距離" if lang == "ja" else "Distance"}</th>
                  <th>{"関門時刻" if lang == "ja" else "Cutoff time"}</th>
                </tr>
              </thead>
              <tbody>
                {render_gate_rows(course.gates, lang)}
              </tbody>
            </table>
          </div>
        </div>
"""
        if course.gates else f'<p class="empty-note">{escape(gate_empty)}</p>'
    )

    aids_html = (
        f"""
        <div>
          <h3>{aid_heading}</h3>
          <div class="table-wrap">
            <table class="data-table">
              <thead>
                <tr>
                  <th>No</th>
                  <th>{"距離" if lang == "ja" else "Distance"}</th>
                  <th>{"種別または内容" if lang == "ja" else "Type / note"}</th>
                </tr>
              </thead>
              <tbody>
                {render_aid_rows(course.aids, lang)}
              </tbody>
            </table>
          </div>
        </div>
"""
        if course.aids else f'<p class="empty-note">{escape(aid_empty)}</p>'
    )

    return f"""
        <article class="course-card">
          <span class="badge badge-gate">{escape(name)}</span>
          <div class="meta-stack">
            <div class="meta-row"><span class="meta-label">{labels[0]}:</span><span>{escape(distance) if distance else "-"}</span></div>
            <div class="meta-row"><span class="meta-label">{labels[1]}:</span><span>{len(course.gates)}</span></div>
            <div class="meta-row"><span class="meta-label">{labels[2]}:</span><span>{len(course.aids)}</span></div>
          </div>
          {gates_html}
          {aids_html}
        </article>
"""


def render_race_detail(race: Race, lang: str) -> str:
    if lang == "ja":
        title = f"{race.name_ja} 関門・エイド Garmin表示ガイド | 関門ガイド"
        description = f"{race.name_ja}の関門・エイド情報をGarminで確認するための関門ガイド対応ページです。次の関門、残り距離、関門時刻、次のエイドを確認できます。"
        path = f"/gatechecker/races/{race.slug}/"
        other = f"/en/gatechecker/races/{race.slug}/"
        hero = ("関門ガイド", f"{race.name_ja} 関門・エイド Garmin表示ガイド", f"{race.name_ja}を走るときに、次の関門とエイドをGarminで確認するためのページです。")
        about_title = "このページについて"
        about_copy = [
            "このページは、掲載している大会情報をもとに作成しています。",
            "レース中はGarmin上で次の関門・エイド情報を確認できます。",
        ]
        course_title = "対応コース"
        info_title = "Garminで見える情報"
        info_points = [
            "次の関門地点",
            "関門までの残り距離",
            "関門時刻",
            "関門までの残り時間",
            "次のエイド地点",
            "エイドまでの残り距離",
        ]
        notice = [
            "関門・エイド情報は、ページ作成時に参照した情報をもとに表示しています。",
            "記載内容に誤りや更新漏れがある場合があります。",
            "大会側の変更、天候、運営判断などにより、実際の情報と異なる場合があります。",
            "必ず大会公式サイト・大会案内で最新情報を確認してください。",
            f"対応大会の追加リクエストは X のDM @racenavi_run ({X_URL}) で連絡してください。",
            f"関門ガイドは{race.name_ja}公式アプリではありません。",
        ]
        back_label = "対応大会一覧へ戻る"
        back_href = "/gatechecker/races/"
        eyebrow = "eyebrow eyebrow-gate"
    else:
        title = f"{race.name_en} Cutoff & Aid Station Guide for Garmin | Cutoff Guide"
        description = f"Cutoff Guide page for {race.name_en}. Check race-specific cutoff points and aid stations on your Garmin watch."
        path = f"/en/gatechecker/races/{race.slug}/"
        other = f"/gatechecker/races/{race.slug}/"
        hero = ("Cutoff Guide", f"{race.name_en} Cutoff & Aid Station Guide for Garmin", f"This page shows the cutoff and aid station data used by Cutoff Guide for {race.name_en}.")
        about_title = "About this page"
        about_copy = [
            "This page is based on referenced race information for this event.",
        ]
        course_title = "Courses"
        info_title = "What Cutoff Guide shows"
        info_points = [
            "Next cutoff point",
            "Distance to cutoff",
            "Cutoff time",
            "Time left",
            "Next aid station",
            "Distance to aid station",
        ]
        notice = [
            "Cutoff and aid station data may change due to race operations, weather, or course changes. Always check the official race website before race day.",
            f"If you want to request another supported race, contact X DM @racenavi_run ({X_URL}).",
            f"Cutoff Guide is not an official app for {race.name_en}.",
        ]
        back_label = "Back to supported races"
        back_href = "/en/gatechecker/races/"
        eyebrow = "eyebrow eyebrow-gate"

    course_blocks = "".join(render_course_block(race, course, lang) for course in race.courses)
    about_list = "".join(f"<li>{escape(line)}</li>" for line in about_copy)
    info_list = "".join(f"<li>{escape(line)}</li>" for line in info_points)
    notice_list = "".join(f"<li>{escape(line)}</li>" for line in notice)

    body = f"""
  <main class="page-shell">
    <section class="hero">
      <div class="hero-card">
        <div>
          <span class="{eyebrow}">{escape(hero[0])}</span>
          <h1>{escape(hero[1])}</h1>
          <p class="lead">{escape(hero[2])}</p>
        </div>
      </div>
    </section>

    <section class="page-section">
      <div class="info-grid">
        <article class="info-card">
          <h2>{escape(about_title)}</h2>
          <ul>{about_list}</ul>
        </article>
        <article class="info-card">
          <h2>{"Race data" if lang == "en" else "大会データ"}</h2>
          <div class="meta-stack">
            <div class="meta-row"><span class="meta-label">{"開催日" if lang == "ja" else "Date"}:</span><span>{escape(race.date)}</span></div>
            <div class="meta-row"><span class="meta-label">Timezone:</span><span>{escape(race.timezone)}</span></div>
            <div class="meta-row"><span class="meta-label">{"コース数" if lang == "ja" else "Courses"}:</span><span>{len(race.courses)}</span></div>
          </div>
        </article>
      </div>
    </section>

    <section class="page-section">
      <div class="section-header">
        <span class="{eyebrow}">{escape(hero[0])}</span>
        <h2>{escape(course_title)}</h2>
      </div>
      <div class="course-grid">
        {course_blocks}
      </div>
    </section>

    <section class="page-section">
      <article class="info-card">
        <h2>{escape(info_title)}</h2>
        <ul>{info_list}</ul>
      </article>
    </section>

    <section class="page-section">
      <div class="notice">
        <strong>{"注意事項" if lang == "ja" else "Disclaimer"}:</strong>
        <ul class="link-list">{notice_list}</ul>
      </div>
      <div class="actions">
        <a class="button button-secondary" href="{back_href}">{escape(back_label)}</a>
      </div>
    </section>
  </main>
"""
    return build_page(
        lang=lang,
        title=title,
        description=description,
        canonical_path=path,
        ja_path=other if lang == "en" else path,
        en_path=path if lang == "en" else other,
        body_html=body,
    )


def render_en_top_page() -> str:
    body = f"""
  <main class="page-shell">
    <section class="hero">
      <div class="hero-card">
        <div>
          <span class="eyebrow">Garmin race support apps</span>
          <h1>Check the information you need during a race on your Garmin.</h1>
          <p class="lead">RaceNavi provides independently developed Garmin apps for race day. RaceNavi helps with heart rate and pacing. Cutoff Guide helps with cutoff times and aid stations.</p>
        </div>
      </div>
    </section>

    <section class="page-section" aria-label="App list">
      <div class="app-grid">
        <article class="app-card">
          <span class="app-label label-racenavi">RaceNavi</span>
          <h2>Heart rate and pacing</h2>
          <p class="app-summary">RaceNavi helps you check your heart rate, pace, target gap, and estimated finish time during a marathon.</p>
          <div class="app-image">
            <img src="{RACENAVI_IMAGE}" alt="RaceNavi screen image showing heart rate, pace, target gap, and estimated finish time on Garmin." />
          </div>
          <div class="info-card">
            <h3>Information</h3>
            <ul>
              <li>Current heart rate</li>
              <li>Heart-rate cap</li>
              <li>Current pace</li>
              <li>Gap from target</li>
              <li>Estimated finish time</li>
            </ul>
          </div>
          <div class="actions">
            <a class="button button-primary" href="/en/racenavi/">View RaceNavi</a>
            <a class="button button-secondary" href="/en/racenavi/custom/">Custom Setup</a>
          </div>
        </article>

        <article class="app-card">
          <span class="app-label label-gate">Cutoff Guide</span>
          <h2>Cutoff times and aid stations</h2>
          <p class="app-summary">Cutoff Guide helps you check the next cutoff point and aid station on your Garmin watch.</p>
          <div class="app-image">
            <img src="{GATE_IMAGE_EN}" alt="Cutoff Guide screen image showing the next cutoff point and aid station on Garmin." />
          </div>
          <div class="info-card">
            <h3>Information</h3>
            <ul>
              <li>Next cutoff point</li>
              <li>Distance to cutoff</li>
              <li>Cutoff time</li>
              <li>Time left</li>
              <li>Next aid station</li>
              <li>Distance to aid station</li>
            </ul>
          </div>
          <div class="actions">
            <a class="button button-primary" href="/en/gatechecker/">View Cutoff Guide</a>
            <a class="button button-secondary" href="/en/gatechecker/races/">Supported Races</a>
          </div>
        </article>
      </div>
    </section>

    <section class="page-section">
      <div class="notice">
        <strong>Disclaimer:</strong>
        RaceNavi and Cutoff Guide are independently developed Garmin apps. They are not official Garmin apps or official race apps. Always confirm cutoff and aid station information with the official race website.
      </div>
    </section>
  </main>
"""
    return build_page(
        lang="en",
        title="RaceNavi | Garmin Race Support Apps",
        description="RaceNavi provides independently developed Garmin race support apps: RaceNavi for heart rate and pacing, and Cutoff Guide for cutoff times and aid stations.",
        canonical_path="/en/",
        ja_path="/",
        en_path="/en/",
        body_html=body,
    )


def generate() -> None:
    races = load_races()
    public_races = [race for race in races if is_public_race(race.slug, race.name_ja, race.name_en)]

    pages = {
        SITE_DIR / "index.html": render_top_page(),
        SITE_DIR / "racenavi" / "index.html": render_racenavi_page("ja"),
        SITE_DIR / "racenavi" / "custom" / "index.html": render_custom_page("ja"),
        SITE_DIR / "gatechecker" / "index.html": render_gatechecker_page("ja"),
        SITE_DIR / "gatechecker" / "races" / "index.html": render_races_index(public_races, "ja"),
        SITE_DIR / "en" / "index.html": render_en_top_page(),
        SITE_DIR / "en" / "racenavi" / "index.html": render_racenavi_page("en"),
        SITE_DIR / "en" / "racenavi" / "custom" / "index.html": render_custom_page("en"),
        SITE_DIR / "en" / "gatechecker" / "index.html": render_gatechecker_page("en"),
        SITE_DIR / "en" / "gatechecker" / "races" / "index.html": render_races_index(public_races, "en"),
    }

    for race in public_races:
        pages[SITE_DIR / "gatechecker" / "races" / race.slug / "index.html"] = render_race_detail(race, "ja")
        pages[SITE_DIR / "en" / "gatechecker" / "races" / race.slug / "index.html"] = render_race_detail(race, "en")

    for path, html in pages.items():
        write_text(path, html)

    print(f"Generated {len(pages)} pages from {len(public_races)} public races ({len(races)} total definitions).")


if __name__ == "__main__":
    generate()
