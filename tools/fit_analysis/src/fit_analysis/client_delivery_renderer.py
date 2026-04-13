"""Client-facing delivery generation with AI and deterministic fallback."""

from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from typing import Any, Callable, Dict, Optional

from .fallback_template_renderer import render_fallback_client_markdown
from .narrative_generator import NarrativeGenerationError, generate_narrative_markdown
from .narrative_validator import validate_narrative_markdown
from .prompt_builder import PROMPT_VERSION, build_narrative_input, build_prompt_bundle
from .schemas import ClientDeliveryArtifacts, NarrativeValidationResult, to_plain_dict


def build_client_delivery_artifacts(
    analysis_result: Dict[str, Any],
    llm_config: Dict[str, Any],
    mode: str,
    generated_at: str,
    model_override: str | None = None,
    timeout_override: int | None = None,
    save_llm_audit: bool = False,
    request_transport: Optional[Callable[[Dict[str, Any], Dict[str, str], int], Dict[str, Any]]] = None,
) -> ClientDeliveryArtifacts:
    narrative_input = build_narrative_input(analysis_result, llm_config)
    prompt_bundle = build_prompt_bundle(narrative_input, llm_config)
    input_hash = hashlib.sha256(
        json.dumps(narrative_input, ensure_ascii=False, sort_keys=True).encode("utf-8")
    ).hexdigest()

    fallback_used = False
    raw_response = None
    error_message = None
    markdown = ""

    if mode == "template":
        markdown = render_fallback_client_markdown(narrative_input)
    else:
        try:
            llm_result = generate_narrative_markdown(
                prompt_bundle=prompt_bundle,
                llm_config=llm_config,
                model_override=model_override,
                timeout_override=timeout_override,
                request_transport=request_transport,
            )
            raw_response = llm_result.raw_response
            markdown = llm_result.markdown
        except NarrativeGenerationError as exc:
            error_message = str(exc)
            if mode == "ai":
                raise
            fallback_used = True
            markdown = render_fallback_client_markdown(narrative_input)

    validation = validate_narrative_markdown(markdown, narrative_input, llm_config)
    if not validation.ok:
        if mode == "ai" and not fallback_used:
            raise NarrativeGenerationError("LLM narrative validation failed: " + "; ".join(validation.issues))
        if mode == "auto" and not fallback_used:
            fallback_used = True
            error_message = "LLM narrative validation failed: " + "; ".join(validation.issues)
            markdown = render_fallback_client_markdown(narrative_input)
            validation = validate_narrative_markdown(markdown, narrative_input, llm_config)

    audit = None
    if save_llm_audit:
        audit = {
            "mode": mode,
            "provider": None if mode == "template" else llm_config.get("provider", "openai"),
            "model": model_override or llm_config.get("model"),
            "prompt_version": PROMPT_VERSION,
            "prompt": {
                "system": prompt_bundle.system_prompt,
                "user": prompt_bundle.user_prompt,
            },
            "input_hash": input_hash,
            "narrative_input": narrative_input,
            "raw_response": raw_response if llm_config.get("save_raw_response", True) else None,
            "validation_result": to_plain_dict(validation),
            "fallback_used": fallback_used,
            "generated_at": generated_at,
            "error": error_message,
        }

    html = render_client_delivery_html(markdown)
    return ClientDeliveryArtifacts(markdown=markdown, html=html, audit=audit, narrative_input=narrative_input, validation=validation)


def render_client_delivery_html(markdown: str) -> str:
    body = markdown_to_html(markdown)
    return (
        "<!doctype html><html lang=\"ja\"><head><meta charset=\"utf-8\">"
        "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
        "<title>Client Delivery</title>"
        "<style>"
        ":root{--bg:#faf8f3;--paper:#fffdf9;--ink:#222;--line:#ddd3c4;--accent:#8b5d33;}"
        "body{margin:0;background:var(--bg);color:var(--ink);font-family:'Hiragino Sans','Yu Gothic',sans-serif;line-height:1.7;}"
        "main{max-width:900px;margin:24px auto;padding:28px;background:var(--paper);border:1px solid var(--line);border-radius:16px;}"
        "h1,h2{line-height:1.3;} h2{margin-top:28px;border-bottom:1px solid var(--line);padding-bottom:6px;}"
        "table{width:100%;border-collapse:collapse;margin:12px 0;} th,td{border:1px solid var(--line);padding:10px;text-align:left;vertical-align:top;}"
        "th{background:#f4eee4;} code{background:#f3eee5;padding:2px 6px;border-radius:6px;} ul{padding-left:20px;}"
        "</style></head><body><main>"
        + body
        + "</main></body></html>\n"
    )


def markdown_to_html(markdown: str) -> str:
    lines = markdown.splitlines()
    html_lines = []
    in_list = False
    in_table = False
    table_rows = []

    def flush_list() -> None:
        nonlocal in_list
        if in_list:
            html_lines.append("</ul>")
            in_list = False

    def flush_table() -> None:
        nonlocal in_table, table_rows
        if not in_table:
            return
        html_lines.append(_table_to_html(table_rows))
        table_rows = []
        in_table = False

    for line in lines:
        stripped = line.strip()
        if stripped.startswith("|") and stripped.endswith("|"):
            flush_list()
            in_table = True
            table_rows.append(stripped)
            continue
        flush_table()

        if stripped.startswith("# "):
            flush_list()
            html_lines.append(f"<h1>{_escape_inline(stripped[2:])}</h1>")
            continue
        if stripped.startswith("## "):
            flush_list()
            html_lines.append(f"<h2>{_escape_inline(stripped[3:])}</h2>")
            continue
        if stripped.startswith("- "):
            if not in_list:
                html_lines.append("<ul>")
                in_list = True
            html_lines.append(f"<li>{_escape_inline(stripped[2:])}</li>")
            continue
        flush_list()
        if stripped:
            html_lines.append(f"<p>{_escape_inline(stripped)}</p>")

    flush_table()
    flush_list()
    return "".join(html_lines)


def _table_to_html(rows: list[str]) -> str:
    parsed = []
    for row in rows:
        cells = [cell.strip() for cell in row.strip("|").split("|")]
        parsed.append(cells)
    if len(parsed) >= 2 and all(cell.startswith("---") for cell in parsed[1]):
        header = parsed[0]
        body_rows = parsed[2:]
    else:
        header = parsed[0]
        body_rows = parsed[1:]

    parts = ["<table><thead><tr>"]
    parts.extend(f"<th>{_escape_inline(cell)}</th>" for cell in header)
    parts.append("</tr></thead><tbody>")
    for row in body_rows:
        parts.append("<tr>")
        parts.extend(f"<td>{_escape_inline(cell)}</td>" for cell in row)
        parts.append("</tr>")
    parts.append("</tbody></table>")
    return "".join(parts)


def _escape_inline(text: str) -> str:
    escaped = (
        text.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
    )
    escaped = escaped.replace("`", "")
    return escaped
