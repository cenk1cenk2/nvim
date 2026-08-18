---
name: vault-kilic
description: vault-kilic Manual for the vault-kilic MCP server - metadata-only inspection of the kilic Vault, what it can answer, and where to send anything needing a secret value. Load before the first call to that server. Not for reading a secret value, and not for changing Vault configuration.
argumentHint: '[what you want to find in Vault]'
---

## The vault-kilic Server

Structure-only inspection of the kilic Vault (`vault.int.kilic.dev`), hosted at `https://vault.mcp.kilic.dev/mcp`. Vault is the `ClusterSecretStore` backend for every kilic cluster, so this is where an `ExternalSecret` ultimately resolves.

**Metadata only.** Secret values are not available through this server.

## What It Answers

| Tool | Answers |
|---|---|
| `list_mounts` | which secret engines exist |
| `list_secrets` | what paths exist under a mount |
| `list_pki_issuers` | which PKI issuers are configured |

`list_secrets` takes the mount and a path beneath it, and returns names.

That covers the usual question: an `ExternalSecret` is not resolving — does the path exist, is the key there, is the mount the one the manifest names.

## Values Belong To The Captain

A task that genuinely needs a secret's value is theirs to run — `vault kv get` over Tailscale, with their own credential. Name the exact path and why you need it, then stop.

Report paths, never payloads: `secret/legacy/hermes/mcp/vault exists, keys: url, token`.
