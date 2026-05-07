# Slack Workspace Prerequisite

A Slack workspace skill **MUST** be active before any Slack message/channel skill runs.

If no workspace context exists in the current session, auto-invoke the appropriate workspace skill:

- **kilic workspace:** Load skill `slack-kilic` via the `slack-kilic` skill (load it as defined in `load-skills`)
- **Laravel workspace:** Load skill `slack-laravel` via the `slack-laravel` skill (load it as defined in `load-skills`)

## Workspace Identifiers

| Workspace | Name | Slack subdomain | URL pattern |
|-----------|------|-----------------|-------------|
| kilic | kilic.dev | `kilic-dev.slack.com` | `https://kilic-dev.slack.com/...` |
| Laravel | Laravel | `laravel.slack.com` | `https://laravel.slack.com/...` |

## Deduction Rules

| Signal | Workspace | Skill |
|--------|-----------|-------|
| Slack URL contains `kilic-dev.slack.com` | kilic | `slack-kilic` |
| Slack URL contains `laravel.slack.com` | Laravel | `slack-laravel` |
| Channel related to GitLab (`gitlab-publish`, `gitlab-pipelines`, `gitlab-deployments`) | kilic | `slack-kilic` |
| Channel related to GitHub or Laravel projects | Laravel | `slack-laravel` |
| User says "personal" or "kilic" | kilic | `slack-kilic` |
| User says "work" or "laravel" or "enterprise" | Laravel | `slack-laravel` |
| No signal available | — | Ask the user |

If a full Slack message URL is provided, match the subdomain against the table above.
