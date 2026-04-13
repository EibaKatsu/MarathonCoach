"""LLM-based narrative generation using provider-specific clients."""

from __future__ import annotations

import json
import os
import socket
import urllib.error
import urllib.request
from dataclasses import asdict
from typing import Any, Callable, Dict, Optional

from .schemas import LLMRequestResult, PromptBundle


class NarrativeGenerationError(RuntimeError):
    """Raised when the LLM narrative generation flow fails."""


def generate_narrative_markdown(
    prompt_bundle: PromptBundle,
    llm_config: Dict[str, Any],
    model_override: str | None = None,
    timeout_override: int | None = None,
    request_transport: Optional[Callable[[Dict[str, Any], Dict[str, str], int], Dict[str, Any]]] = None,
) -> LLMRequestResult:
    provider = str(llm_config.get("provider", "openai"))
    if provider != "openai":
        raise NarrativeGenerationError(f"Unsupported LLM provider: {provider}")

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        raise NarrativeGenerationError("OPENAI_API_KEY is not set")

    model = model_override or os.environ.get("OPENAI_MODEL") or str(llm_config.get("model", "gpt-5"))
    timeout = timeout_override or int(llm_config.get("timeout_sec", 30))
    payload = {
        "model": model,
        "instructions": prompt_bundle.system_prompt,
        "input": [
            {
                "role": "user",
                "content": prompt_bundle.user_prompt,
            }
        ],
        "max_output_tokens": int(llm_config.get("max_output_tokens", 1800)),
    }
    reasoning = llm_config.get("reasoning")
    if reasoning:
        payload["reasoning"] = reasoning
    text_config = llm_config.get("text")
    if text_config:
        payload["text"] = text_config
    temperature = llm_config.get("temperature")
    if temperature is not None and _supports_temperature(model):
        payload["temperature"] = float(temperature)
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }
    if os.environ.get("OPENAI_ORGANIZATION"):
        headers["OpenAI-Organization"] = os.environ["OPENAI_ORGANIZATION"]
    if os.environ.get("OPENAI_PROJECT"):
        headers["OpenAI-Project"] = os.environ["OPENAI_PROJECT"]

    transport = request_transport or _openai_request
    raw_response = transport(payload, headers, timeout)
    markdown = _extract_output_text(raw_response)
    if not markdown.strip():
        raise NarrativeGenerationError("LLM returned an empty narrative")
    return LLMRequestResult(provider=provider, model=model, markdown=markdown.rstrip() + "\n", raw_response=raw_response)


def _openai_request(payload: Dict[str, Any], headers: Dict[str, str], timeout: int) -> Dict[str, Any]:
    base_url = os.environ.get("OPENAI_BASE_URL", "https://api.openai.com/v1")
    url = base_url.rstrip("/") + "/responses"
    data = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(url=url, data=data, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", errors="replace")
        raise NarrativeGenerationError(f"OpenAI API returned HTTP {exc.code}: {body}") from exc
    except urllib.error.URLError as exc:
        raise NarrativeGenerationError(f"OpenAI API request failed: {exc}") from exc
    except socket.timeout as exc:
        raise NarrativeGenerationError(f"OpenAI API request timed out after {timeout} seconds") from exc


def _extract_output_text(response_json: Dict[str, Any]) -> str:
    if response_json.get("status") == "incomplete":
        reason = response_json.get("incomplete_details", {}).get("reason", "unknown")
        raise NarrativeGenerationError(f"OpenAI response incomplete: {reason}")
    outputs = response_json.get("output", [])
    parts = []
    for item in outputs:
        if item.get("type") != "message":
            continue
        for content in item.get("content", []):
            if content.get("type") == "output_text":
                parts.append(content.get("text", ""))
    if parts:
        return "\n".join(part for part in parts if part)
    if response_json.get("output_text"):
        return str(response_json["output_text"])
    raise NarrativeGenerationError("Could not extract output_text from OpenAI response")


def _supports_temperature(model: str) -> bool:
    normalized = str(model).strip().lower()
    return not normalized.startswith("gpt-5")
