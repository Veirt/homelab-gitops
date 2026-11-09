"""SearXNG external plugin adapter for SerpAPI."""

from __future__ import annotations

import os
import threading
from dataclasses import dataclass
from typing import Any, Mapping

from .core import (
    BACKEND_AUTO,
    BACKEND_GOOGLE,
    BACKEND_GOOGLE_IMAGES,
    BASE_URL,
    build_params,
    default_results_per_page,
    parse_api_key_value,
    parse_api_keys,
    parse_results,
    validate_backend,
)

try:  # pragma: no cover - exercised only when SearXNG is installed.
    from searx.plugins import Plugin, PluginInfo  # pyright: ignore[reportMissingImports]
except Exception:  # pragma: no cover - keeps package importable without SearXNG.

    @dataclass
    class PluginInfo:  # type: ignore[no-redef]
        """Small compatibility stand-in for tests outside SearXNG."""

        id: str
        name: str
        description: str
        preference_section: str | None = "general"

    class Plugin:  # type: ignore[no-redef]
        """Small compatibility stand-in for tests outside SearXNG."""

        id = ""
        active = False

        def __init__(self, plg_cfg: Any) -> None:
            for name, value in getattr(plg_cfg, "__dict__", {}).items():
                setattr(self, name, value)

        def init(self, app: Any) -> bool:
            return True


class SXNGPlugin(Plugin):  # pyright: ignore[reportGeneralTypeIssues]
    """SearXNG plugin that appends SerpAPI Google or Google Images results."""

    id = "serpapi"
    info = PluginInfo(
        id=id,
        name="SerpAPI Google results",
        description="Fetches Google web or image results from SerpAPI and adds them to SearXNG results.",
    )

    def __init__(self, plg_cfg: Any) -> None:
        super().__init__(plg_cfg)
        self.info = PluginInfo(
            id=self.id,
            name="SerpAPI Google results",
            description="Fetches Google web or image results from SerpAPI and adds them to SearXNG results.",
        )

        self.api_key = ""
        self.api_keys: list[str] = []
        self.backend = BACKEND_AUTO
        self.timeout = 10.0
        self.results_per_page: int | None = None
        self._config_valid = False
        self._api_key_lock = threading.Lock()
        self._api_key_cursor = 0

    def init(self, app: Any) -> bool:
        """Load top-level SerpAPI settings and activate only when valid."""
        try:
            from searx import settings as searx_settings  # pyright: ignore[reportAttributeAccessIssue]
        except Exception:
            return False

        try:
            config = searx_settings.get("serpapi", {})
        except AttributeError:
            config = {}
        if not isinstance(config, Mapping):
            self._config_valid = False
            return False
        return self.configure(config)

    def configure(self, config: Mapping[str, Any]) -> bool:
        """Apply SerpAPI options from the top-level SearXNG settings section."""
        # Explicit settings win. The single-key env var accepts either one
        # legacy key or a JSON-encoded array of keys.
        self.api_keys = parse_api_keys(config.get("api_keys"))
        if not self.api_keys:
            self.api_keys = parse_api_key_value(config.get("api_key"))
        if not self.api_keys:
            self.api_keys = parse_api_key_value(os.environ.get("SERPAPI_API_KEY", ""))
        self.api_key = self.api_keys[0] if self.api_keys else ""
        with self._api_key_lock:
            self._api_key_cursor = 0
        self.backend = config.get("backend", BACKEND_AUTO) or BACKEND_AUTO
        self.timeout = config.get("timeout", 10.0)
        self.results_per_page = config.get("results_per_page")
        self._config_valid = bool(self.api_keys and self._validate_config())
        return self._config_valid

    def post_search(self, request: Any, search: Any) -> list[dict[str, Any]]:
        """Fetch SerpAPI results for the current SearXNG search query."""
        if not self._config_valid or not self.api_key:
            return []

        query = _search_query_value(search)
        if not query or not query.strip():
            return []

        backend = self._backend_for_search(search)
        pageno = _search_page_value(search)
        try:
            from searx.network import get, raise_for_httperror  # pyright: ignore[reportMissingImports]
        except Exception:
            return []

        for api_key in self._next_api_key_order():
            try:
                params = build_params(
                    query=query,
                    api_key=api_key,
                    backend=backend,
                    pageno=pageno,
                    results_per_page=self.results_per_page,
                )
                response = _network_get(get, BASE_URL, params=params, timeout=self.timeout)
                status_code = getattr(response, "status_code", 200)
                if status_code in {401, 403, 429}:
                    continue

                data = response.json()
                if not isinstance(data, dict):
                    return []
                if "error" in data:
                    if _retryable_key_error(status_code, data):
                        continue
                    return []

                raise_for_httperror(response)
                results = parse_results(data, backend)
                if results:
                    _ensure_plugin_score_metric(self.id)
                return results
            except Exception:
                return []
        return []

    def _backend_for_search(self, search: Any) -> str:
        if self.backend != BACKEND_AUTO:
            return self.backend

        search_query = getattr(search, "search_query", None)
        categories = getattr(search_query, "categories", ())
        if isinstance(categories, str):
            categories = (categories,)
        try:
            if "images" in categories:
                return BACKEND_GOOGLE_IMAGES
        except TypeError:
            pass
        return BACKEND_GOOGLE

    def _next_api_key_order(self) -> list[str]:
        """Rotate the first key per query and order the remaining fallbacks."""
        with self._api_key_lock:
            count = len(self.api_keys)
            if not count:
                return []
            first = self._api_key_cursor % count
            self._api_key_cursor = (first + 1) % count
            return [self.api_keys[(first + offset) % count] for offset in range(count)]

    def _validate_config(self) -> bool:
        try:
            self.backend = str(self.backend)
            if self.backend != BACKEND_AUTO:
                self.backend = validate_backend(self.backend)
            if self.results_per_page in (None, 0, "0"):
                self.results_per_page = None
            else:
                self.results_per_page = default_results_per_page(BACKEND_GOOGLE, self.results_per_page)
            self.timeout = float(self.timeout)
        except (TypeError, ValueError):
            return False

        if self.timeout <= 0:
            return False
        return True


def _network_get(get_func: Any, url: str, params: dict[str, Any], timeout: float) -> Any:
    """Call SearXNG's network.get across compatible signatures."""
    try:
        return get_func(url, params=params, timeout=timeout, raise_for_httperror=False)
    except TypeError:
        return get_func(url, params=params, timeout=timeout)


def _retryable_key_error(status_code: int, data: dict[str, Any]) -> bool:
    """Identify API responses for which another key may succeed."""
    if status_code in {401, 403, 429}:
        return True
    error = data.get("error")
    if not isinstance(error, str):
        return False
    error = error.casefold()
    return any(
        marker in error
        for marker in (
            "api key",
            "api_key",
            "invalid key",
            "unauthorized",
            "authentication",
            "quota",
            "rate limit",
            "too many requests",
            "run out of searches",
            "searches limit",
            "search limit",
            "monthly limit",
        )
    )


def _ensure_plugin_score_metric(plugin_id: str) -> None:
    """Register the score counter used by SearXNG for plugin-added results.

    SearXNG initializes score counters for search engines, but post-search
    plugin results use an engine label like ``plugin: serpapi``. Without this
    extra counter, ResultContainer.close() raises KeyError while scoring and
    the entire search response fails.
    """
    from searx import metrics  # pyright: ignore[reportMissingImports]

    labels = ("engine", f"plugin: {plugin_id}", "score")
    try:
        metrics.counter(*labels)
    except KeyError:
        metrics.counter_storage.configure(*labels)


def _search_query_value(search: Any) -> str:
    search_query = getattr(search, "search_query", None)
    query = getattr(search_query, "query", "")
    if query is None:
        return ""
    return str(query)


def _search_page_value(search: Any) -> int:
    search_query = getattr(search, "search_query", None)
    pageno = getattr(search_query, "pageno", 1)
    try:
        page = int(pageno)
    except (TypeError, ValueError):
        return 1
    return max(page, 1)
