"""MCP tool conditions: call one tool on a remote MCP server every poll.

The truth for some waits lives only behind an MCP server - a labrat session, a
Slack thread through a hosted bridge. A shell loop cannot use the agent's own
MCP connection, but a streamable-HTTP server is plain JSON-RPC over POST, so the
watcher speaks it directly with the same URL and headers the agent's config
carries.

Header values expand `${VAR}` from the environment at call time, so a secret is
named on the command line and never written there, where `ps` would show it.
"""

from __future__ import annotations

import json
import os
import re
from collections.abc import Iterable
from dataclasses import dataclass, field

import httpx
from agentlib.cli import ScriptError
from agentlib.models import Expectations
from jsonpath_ng.exceptions import JSONPathError

from probes import USER_AGENT, CannotRun, json_walk, truncate

PROTOCOL_VERSION = "2025-06-18"
MCP_TIMEOUT = 60
ENV_REFERENCE = re.compile(r"\$\{([A-Za-z_][A-Za-z0-9_]*)\}")


class CallFailed(Exception):
    """One tool call failed in a way the next poll may not repeat: a timeout, a 5xx, a tool error."""


@dataclass(frozen=True)
class Server:
    url: str
    headers: dict[str, str] = field(default_factory=dict)

    def resolved_headers(self) -> dict[str, str]:
        def expand(value: str) -> str:
            def lookup(match: re.Match) -> str:
                name = match.group(1)
                if not os.environ.get(name):
                    raise CannotRun(f"header references ${{{name}}}, which is unset or empty")
                return os.environ[name]

            return ENV_REFERENCE.sub(lookup, value)

        return {name: expand(value) for name, value in self.headers.items()}


def parse_header(raw: str) -> tuple[str, str]:
    name, sep, value = raw.partition(":")
    if not sep or not name.strip():
        raise ScriptError(f"--header must be 'Name: value', got: {raw}")
    return name.strip(), value.strip()


def server_from_config(config: str, name: str) -> Server:
    """Read one server out of an `mcpServers` config, the shape every agent runtime here uses."""
    try:
        with open(config, encoding="utf-8") as handle:
            servers = json.load(handle).get("mcpServers", {})
    except (OSError, json.JSONDecodeError) as err:
        raise ScriptError(f"cannot read --config: {err}") from err
    entry = servers.get(name)
    if entry is None:
        raise ScriptError(f"--server {name} is not in {config}; known: {', '.join(sorted(servers))}")
    if "url" not in entry:
        raise ScriptError(f"--server {name} is a stdio server; only HTTP servers can be watched")
    return Server(entry["url"], dict(entry.get("headers") or {}))


def unwrap(node):
    """Parse any JSON document nested inside a value as a string.

    Servers that wrap their payload as `{"result": "<json>"}` would otherwise hand
    a path nothing to walk into past the first key.
    """
    if isinstance(node, str) and node.lstrip()[:1] in ("{", "["):
        try:
            return unwrap(json.loads(node))
        except json.JSONDecodeError:
            return node
    if isinstance(node, dict):
        return {key: unwrap(item) for key, item in node.items()}
    if isinstance(node, list):
        return [unwrap(item) for item in node]
    return node


class Client:
    """A minimal streamable-HTTP MCP client: initialize once, then one `tools/call` per poll."""

    def __init__(self, server: Server, tool: str, arguments: dict):
        self.server = server
        self.tool = tool
        self.arguments = arguments
        self.session: str | None = None
        self.initialized = False
        self.ids = iter(range(1, 1_000_000))

    def _post(self, body: dict) -> dict | None:
        headers = {
            "Content-Type": "application/json",
            "Accept": "application/json, text/event-stream",
            "User-Agent": USER_AGENT,
            "MCP-Protocol-Version": PROTOCOL_VERSION,
            **self.server.resolved_headers(),
        }
        if self.session:
            headers["Mcp-Session-Id"] = self.session
        try:
            response = httpx.post(self.server.url, json=body, headers=headers, timeout=MCP_TIMEOUT)
        except httpx.HTTPError as err:
            raise CallFailed(f"connection error: {err}") from None
        if response.status_code in (401, 403):
            raise CannotRun(f"{self.server.url} refused the credentials: HTTP {response.status_code}")
        if response.status_code == 404 and self.session:
            self.session = None
            self.initialized = False
            raise CallFailed("the server dropped the session; re-initializing next poll")
        if response.status_code >= 400:
            raise CallFailed(f"HTTP {response.status_code}: {truncate(response.text)}")
        self.session = response.headers.get("Mcp-Session-Id", self.session)
        if "id" not in body or not response.content:
            return None
        text = response.text
        if "text/event-stream" in response.headers.get("Content-Type", ""):
            events = [line[5:].strip() for line in text.splitlines() if line.startswith("data:")]
            text = next((event for event in events if f'"id":{body["id"]}' in event.replace(" ", "")), "")
        try:
            message = json.loads(text)
        except json.JSONDecodeError:
            raise CallFailed(f"no JSON-RPC reply: {truncate(text)}") from None
        if "error" in message:
            error = message["error"]
            raise CannotRun(f"JSON-RPC error {error.get('code')}: {error.get('message')}")
        return message.get("result")

    def _initialize(self) -> None:
        self._post(
            {
                "jsonrpc": "2.0",
                "id": next(self.ids),
                "method": "initialize",
                "params": {
                    "protocolVersion": PROTOCOL_VERSION,
                    "capabilities": {},
                    "clientInfo": {"name": "agent-background-watch", "version": "1.0.0"},
                },
            }
        )
        self._post({"jsonrpc": "2.0", "method": "notifications/initialized"})
        self.initialized = True

    def call(self):
        """Return the tool's result as decoded JSON."""
        if not self.initialized:
            self._initialize()
        result = self._post(
            {
                "jsonrpc": "2.0",
                "id": next(self.ids),
                "method": "tools/call",
                "params": {"name": self.tool, "arguments": self.arguments},
            }
        )
        result = result or {}
        texts = [item.get("text", "") for item in result.get("content", []) if item.get("type") == "text"]
        if result.get("isError"):
            raise CallFailed(f"tool error: {truncate(' '.join(texts))}")
        if result.get("structuredContent") is not None:
            return unwrap(result["structuredContent"])
        return unwrap("\n".join(texts))


class ToolValue:
    """Compare a tool's result, optionally narrowed by a JSON path, to an expected set."""

    reports_first_value = True

    def __init__(self, client: Client, expect: Expectations):
        self.client = client
        self.expect = expect
        self.answered = False

    def describe(self) -> str:
        via = f" via json path {self.expect.json_path}" if self.expect.json_path else ""
        test = "contains" if self.expect.contains else "equals"
        negation = "does not " if self.expect.negate else ""
        values = " | ".join(repr(value) for value in self.expect.values)
        return f"mcp {self.client.tool} on {self.client.server.url}{via} {negation}{test} {values}"

    def __call__(self) -> tuple[bool, str | None]:
        try:
            result = self.client.call()
        except CallFailed as err:
            # A call that never once succeeded is a broken watch - an unknown
            # tool, wrong arguments - not a state still on its way.
            if not self.answered:
                raise CannotRun(f"the first call failed: {err}") from None
            return False, str(err)
        self.answered = True
        observed = result if isinstance(result, str) else json.dumps(result, sort_keys=True)
        if self.expect.json_path:
            try:
                observed = json_walk(json.dumps(result), self.expect.json_path)
            except (ValueError, KeyError, IndexError, TypeError, JSONPathError) as err:
                return False, f"json path {self.expect.json_path} unresolved ({err.__class__.__name__})"
        return self.expect.matches(observed), observed


def parse_match(raw: str) -> tuple[str, str]:
    key, sep, value = raw.partition("=")
    if not sep or not key:
        raise ScriptError(f"--match must be KEY=VALUE, got: {raw}")
    return key, value


class NewItem:
    """Probe: the first call records the item ids, every later call fires on the first id not seen before."""

    reports_first_value = True

    def __init__(
        self,
        client: Client,
        items: str,
        id_key: str,
        matches: Iterable[tuple[str, str]],
        show: str | None,
    ):
        self.client = client
        self.items = items
        self.id_key = id_key
        self.matches = tuple(matches)
        self.show = show
        self.baseline: set[str] | None = None
        self.outcome: str | None = None

    def describe(self) -> str:
        where = "".join(f", {key}={value}" for key, value in self.matches)
        return f"new item in {self.items} of mcp {self.client.tool} on {self.client.server.url}{where}"

    def _fetch(self) -> list[dict]:
        result = self.client.call()
        try:
            found = json.loads(json_walk(json.dumps(result), self.items))
        except (ValueError, KeyError, IndexError, TypeError, JSONPathError) as err:
            raise CallFailed(f"items path {self.items} unresolved ({err.__class__.__name__})") from None
        if not isinstance(found, list):
            raise CallFailed(f"items path {self.items} is not a list")
        return [
            item
            for item in found
            if isinstance(item, dict) and all(str(item.get(key)) == value for key, value in self.matches)
        ]

    def __call__(self) -> tuple[bool, str | None]:
        try:
            current = self._fetch()
        except CallFailed as err:
            if self.baseline is None:
                raise CannotRun(f"cannot take the baseline: {err}") from None
            return False, f"poll failed, retrying: {err}"
        ids = [str(item.get(self.id_key)) for item in current]
        if self.baseline is None:
            self.baseline = set(ids)
            return False, f"{len(ids)} item(s) at baseline"
        fresh = next((item for item, item_id in zip(current, ids, strict=True) if item_id not in self.baseline), None)
        if fresh is None:
            return False, f"{len(ids)} item(s), none new"
        summary = ""
        if self.show:
            shown = str(fresh.get(self.show, "")).strip().splitlines()
            summary = f": {truncate(shown[0])}" if shown else ""
        self.outcome = f"new item {fresh.get(self.id_key)} in mcp {self.client.tool}{summary}"
        return True, f"{len(ids)} item(s), 1+ new"
