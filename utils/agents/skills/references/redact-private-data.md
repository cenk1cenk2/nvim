# Redact Private Data

Read this when authoring or editing any skill, reference, repo knowledge base, or example. It governs what real-world specifics may appear in that content.

## Rule

Do NOT write real specifics of private or sensitive things into skills, references, knowledge-base files, or their examples — unless the user has explicitly allowed that specific value. When in doubt, use a placeholder and ask.

## Treat as private (do not hardcode without explicit permission)

- Customer / client / company names and anything derived from them (stack names, env names, buckets containing the name).
- Account and org identifiers — AWS account IDs, project IDs, tenant IDs.
- Secrets — tokens, API keys, passwords, connection strings. (config-mcp already forbids these; use `${ENV_VAR}` references.)
- Internal hostnames, private domains, and private IP addresses.
- Real resource identifiers — AMI IDs, ARNs, instance IDs, cluster codenames, specific stack/pipeline names.
- Personal data — employee names, emails, handles tied to real people.
- Real ticket / PR / MR numbers tied to confidential work.

## Use instead

- Angle-bracket placeholders that name the slot: `<owner>`, `<repo>`, `<account-id>`, `<customer>`, `<stack-name>`, `<region>`.
- Conventional dummy values where a real-looking shape helps: AWS account `123456789012`, `ami-0123456789abcdef0`, `acme` for a customer.
- Describe the shape/format, not a real instance — examples teach structure.

## Keep (functional, not private)

Identifiers a skill genuinely needs to operate may stay: the specific channel it posts to, the repository it targets, MCP server / tool names, and well-known open-source component names (Karpenter, envoy, nginx). Prefer the user's explicit blessing for these, and never mix in the confidential specifics above.
