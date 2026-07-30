# Harness Connectors

Integrations the running agent harness provides itself, and the rule that they outrank standalone MCP servers for the same service.

The rule is harness-agnostic. The inventory below is per harness and grows as integrations are confirmed — today only Claude Code's connectors are established.

## ⛔ ABSOLUTE: the harness-provided integration wins

**When the running harness provides an integration for a service, use it. Do NOT use an external or self-hosted MCP server for that same service.** On Claude Code that means a `mcp__claude_ai_<Connector>__*` connector takes precedence over the equivalent standalone server (`slack-kilic`, `notion-laravel`, and so on) for every read and every write.

Why it is absolute rather than a preference:

- **One integration, one auth path.** Two servers on one service means two token sets, two permission scopes, and results that silently disagree about what the user can see.
- **The harness one is the supported path.** It is authorized where the user manages it, it stays current with the harness, and it is what the operator expects to be in play.
- **Mixing them corrupts state.** Reading through one and writing through the other produces edits attributed to the wrong identity and reactions or replies that land where nobody is looking.

How to apply it:

1. **Check what the harness offers first**, before reaching for a server name a skill happens to mention. Deferred connector tools still count as available — load them first.
2. **Use the external server only when the harness provides nothing for that service**, or when it is genuinely missing a capability the task needs.
3. **When you do fall back, say so in one line** — which capability was missing and which server you used instead. Never switch silently, and never mix the two inside one flow.
4. **A skill naming one server is not an override.** Skill bodies name a server for identification; this precedence rule outranks that name at call time.

## What counts as harness-provided

- **Yes:** an integration the agent runtime ships or brokers itself, authorized where the user administers the harness — Claude Code's claude.ai connectors are the current example.
- **No:** a standalone MCP server configured in hyprpilot (`slack-kilic`, `notion-laravel`, `linear-kilic`, …), however reliably present it is. Those are the fallback tier.
- **Unsure:** treat it as harness-provided only if the harness itself surfaces and authorizes it. If you cannot tell, say so rather than guessing at precedence.

## Inventory

### Claude Code — claude.ai connectors

Services authorized through claude.ai. These tools are **deferred**: their schemas are not loaded at startup and must be fetched before use.

All follow the pattern `mcp__claude_ai_<Connector>__<tool_name>`:

| Connector | Full prefix                | Example                                    |
| --------- | -------------------------- | ------------------------------------------ |
| Slack     | `mcp__claude_ai_Slack__`   | `mcp__claude_ai_Slack__slack_send_message` |
| Notion    | `mcp__claude_ai_Notion__`  | `mcp__claude_ai_Notion__notion-search`     |
| Linear    | `mcp__claude_ai_Linear__`  | `mcp__claude_ai_Linear__get_issue`         |
| Plain     | `mcp__claude_ai_Plain__`   | `mcp__claude_ai_Plain__getThreads`         |
| Granola   | `mcp__claude_ai_Granola__` | `mcp__claude_ai_Granola__list_meetings`    |

**Loading.** Use `ToolSearch` before calling. Keyword search finds tools by connector name; `select:` loads exact names:

```
ToolSearch({ query: "+Slack send message" })
ToolSearch({ query: "select:mcp__claude_ai_Slack__slack_send_message,mcp__claude_ai_Slack__slack_read_channel" })
```

Load only what the current task needs — one call can load several tools.

#### Slack (`mcp__claude_ai_Slack__`)

| Tool                              | Purpose                                             |
| --------------------------------- | --------------------------------------------------- |
| `slack_search_public`             | Search messages in public channels.                 |
| `slack_search_public_and_private` | Search messages across public and private channels. |
| `slack_search_channels`           | Search for channels by name or topic.               |
| `slack_search_users`              | Search for users by name or email.                  |
| `slack_read_channel`              | Read recent messages from a channel.                |
| `slack_read_thread`               | Read all replies in a message thread.               |
| `slack_read_user_profile`         | Get detailed profile for a specific user.           |
| `slack_send_message`              | Send a message to a channel or thread.              |
| `slack_send_message_draft`        | Draft and format a message before sending.          |
| `slack_schedule_message`          | Schedule a message for later delivery.              |
| `slack_create_canvas`             | Create a new Slack canvas document.                 |
| `slack_read_canvas`               | Read an existing canvas.                            |
| `slack_update_canvas`             | Update an existing canvas.                          |
| `slack_add_reaction`              | Add an emoji reaction to a message.                 |
| `slack_get_reactions`             | Get the reactions on a message.                     |

See the `slack` reference for the mapping between these and the workspace-server tool names.

#### Notion (`mcp__claude_ai_Notion__`)

| Tool                        | Purpose                             |
| --------------------------- | ----------------------------------- |
| `notion-search`             | Find pages by query.                |
| `notion-fetch`              | Retrieve page content by URL or ID. |
| `notion-update-page`        | Modify page properties and content. |
| `notion-create-pages`       | Create new pages.                   |
| `notion-create-comment`     | Add comments to pages.              |
| `notion-get-comments`       | Read comments on a page.            |
| `notion-get-users`          | List workspace users.               |
| `notion-get-teams`          | List workspace teams.               |
| `notion-create-database`    | Create a new database.              |
| `notion-create-view`        | Create a database view.             |
| `notion-update-view`        | Update a database view.             |
| `notion-update-data-source` | Update a data source.               |
| `notion-duplicate-page`     | Duplicate an existing page.         |
| `notion-move-pages`         | Move pages to a different parent.   |

### Other harnesses

Nothing confirmed for OpenCode or Codex. Check the running build's own tool list before assuming either way — if one turns out to broker a service directly, the rule above applies to it unchanged, and it belongs in this inventory. Do not infer a connector's existence from another harness having one.

## Key Rules

- **Always load before use.** Calling a deferred tool without loading it first fails with `InputValidationError`.
- **Load per task.** Load only what you need — do not bulk-load a connector.
- **Tool names vary.** Connector names differ from server-direct equivalents (`mcp__claude_ai_Notion__notion-fetch` vs `notion-laravel__notion-fetch`, `mcp__claude_ai_Slack__slack_read_channel` vs `slack-kilic__slack_get_channel_history`). The differing name is a mapping exercise, never a reason to fall back.
- **Deferred is not unavailable.** A connector tool whose schema is not loaded yet still takes precedence — load it and use it.
