"""Pure SerpAPI query and result helpers for the SearXNG plugin."""

from __future__ import annotations

import json
from typing import Any

BASE_URL = "https://serpapi.com/search.json"

BACKEND_GOOGLE = "google"
BACKEND_GOOGLE_IMAGES = "google_images"
BACKEND_AUTO = "auto"
VALID_BACKENDS = frozenset({BACKEND_GOOGLE, BACKEND_GOOGLE_IMAGES})

DEFAULT_WEB_RESULTS_PER_PAGE = 10
DEFAULT_IMAGE_RESULTS_PER_PAGE = 50


def parse_api_keys(value: Any) -> list[str]:
    """Normalize a Python key list or a JSON-encoded environment value."""
    if isinstance(value, str):
        try:
            value = json.loads(value)
        except json.JSONDecodeError:
            return []

    if not isinstance(value, (list, tuple)):
        return []

    keys: list[str] = []
    seen: set[str] = set()
    for item in value:
        if not isinstance(item, str):
            continue
        key = item.strip()
        if key and key not in seen:
            keys.append(key)
            seen.add(key)
    return keys


def parse_api_key_value(value: Any) -> list[str]:
    """Accept a legacy scalar key or a JSON-encoded array in one setting."""
    if not isinstance(value, str):
        return parse_api_keys(value)

    normalized = value.strip()
    if not normalized:
        return []
    if normalized.startswith("["):
        return parse_api_keys(normalized)
    return [normalized]


def validate_backend(backend: str) -> str:
    """Return a supported SerpAPI backend or raise ``ValueError``."""
    if backend in VALID_BACKENDS:
        return backend
    raise ValueError(f"unsupported SerpAPI backend: {backend!r}")


def default_results_per_page(backend: str, results_per_page: int | None = None) -> int:
    """Return an explicit positive result count or the backend default."""
    backend = validate_backend(backend)
    if results_per_page is None or results_per_page == 0:
        if backend == BACKEND_GOOGLE_IMAGES:
            return DEFAULT_IMAGE_RESULTS_PER_PAGE
        return DEFAULT_WEB_RESULTS_PER_PAGE

    try:
        page_size = int(results_per_page)
    except (TypeError, ValueError) as exc:
        raise ValueError("results_per_page must be a positive integer") from exc

    if page_size < 1:
        raise ValueError("results_per_page must be a positive integer")
    return page_size


def pagination_params(backend: str, pageno: int, results_per_page: int) -> dict[str, int]:
    """Build SerpAPI pagination parameters for SearXNG's 1-based page number."""
    backend = validate_backend(backend)
    page = _positive_int(pageno, "pageno")
    page_size = _positive_int(results_per_page, "results_per_page")

    if backend == BACKEND_GOOGLE_IMAGES:
        return {"ijn": page - 1}
    return {"start": (page - 1) * page_size}


def build_params(
    query: str,
    api_key: str,
    backend: str = BACKEND_GOOGLE,
    pageno: int = 1,
    results_per_page: int | None = None,
) -> dict[str, Any]:
    """Build the SerpAPI request parameters for one SearXNG query page."""
    backend = validate_backend(backend)
    page_size = default_results_per_page(backend, results_per_page)
    params: dict[str, Any] = {
        "engine": backend,
        "q": query,
        "api_key": api_key,
        **pagination_params(backend, pageno, page_size),
    }

    # SerpAPI's Google web API defaults to 10; only send num when overridden.
    if backend == BACKEND_GOOGLE and page_size != DEFAULT_WEB_RESULTS_PER_PAGE:
        params["num"] = page_size

    return params


def parse_results(data: dict[str, Any], backend: str = BACKEND_GOOGLE) -> list[dict[str, Any]]:
    """Parse SerpAPI JSON into SearXNG legacy result dictionaries."""
    backend = validate_backend(backend)
    if backend == BACKEND_GOOGLE_IMAGES:
        return parse_image_results(data)
    return parse_web_results(data)


def parse_web_results(data: dict[str, Any]) -> list[dict[str, Any]]:
    """Parse ``organic_results`` from the Google web backend."""
    results: list[dict[str, Any]] = []
    for item in data.get("organic_results", []):
        if not isinstance(item, dict):
            continue
        url = item.get("link", "")
        title = item.get("title", "")
        if url and title:
            results.append({"url": url, "title": title, "content": item.get("snippet", "")})
    return results


def parse_image_results(data: dict[str, Any]) -> list[dict[str, Any]]:
    """Parse ``images_results`` from the Google Images backend."""
    results: list[dict[str, Any]] = []
    for item in data.get("images_results", []):
        if not isinstance(item, dict):
            continue
        url = item.get("link", "")
        img_src = item.get("original", "")
        if url and img_src:
            results.append(
                {
                    "template": "images.html",
                    "url": url,
                    "title": item.get("title", ""),
                    "img_src": img_src,
                    "thumbnail_src": item.get("thumbnail", ""),
                    "source": item.get("source", ""),
                }
            )
    return results


def _positive_int(value: int, name: str) -> int:
    try:
        number = int(value)
    except (TypeError, ValueError) as exc:
        raise ValueError(f"{name} must be a positive integer") from exc

    if number < 1:
        raise ValueError(f"{name} must be a positive integer")
    return number
