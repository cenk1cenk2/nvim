---
name: cluster-kilic-chart
description: 'cluster-kilic-chart Create a new Helm chart wrapper in the cluster/charts GitLab group - scaffolds the chart repo with upstream dependency, values, optional custom templates, and standard boilerplate. Always manually invoked. Do NOT use for workload deployments (/cluster-kilic-workload), ArgoCD workloads (/argocd-kilic-workload), or LB routing (/argocd-kilic-loadbalancer).'
disableModelInvocation: true
argumentHint: "[chart-name] - e.g., 'goldilocks', 'velero', 'cilium-l2-announcement'"
references:
  - ../references/present-first.md
  - ../references/output-diff.md
---

## Cluster Chart Creator

Posture: `present-first`.
> **IMPORTANT: This skill creates a new Helm chart repository in the `cluster/charts` group on GitLab (`gitlab.kilic.dev`).**

## How Charts Work in This System

Each system component deployed via ArgoCD gets a Helm chart in `cluster/charts/chart-<name>`. Charts are either **wrappers around upstream Helm charts** or **standalone custom-resource charts**. ArgoCD pulls from these repos to deploy components to clusters.

The chart repos are thin — they pin upstream versions, provide default values, and optionally add custom templates for resources the upstream chart doesn't cover (ExternalSecrets, Gateway API resources, CRDs). Renovate handles automated upstream version bumps. Semantic-release handles chart versioning and publishing.

## Chart Types

There are **two main types**, with variations based on additional resources needed:

| Type | Has Dependencies | Has Templates | Example |
|------|:---:|:---:|---------|
| **Pure wrapper** | Yes | No | `chart-goldilocks`, `chart-prometheus-operator` |
| **Wrapper + ExternalSecret** | Yes | Yes | `chart-external-dns`, `chart-velero` |
| **Wrapper + custom resources** | Yes | Yes | `chart-envoy-gateway` |
| **Standalone custom resources** | No | Yes | `chart-cilium-l2-announcement` |
| **Standalone CR + ExternalSecret** | No | Yes | `chart-cert-manager-letsencrypt-dns01-cloudflare` |

## Gather Requirements

Ask the user:

- **Component name:** What is being deployed? (e.g., `velero`, `goldilocks`, `external-dns`)
- **Upstream chart?** Is there an upstream Helm chart to wrap? If yes, what's the repository URL and chart name?
- **Secrets needed?** Does it need Vault secrets via ExternalSecret?
- **Custom resources?** Does it need additional templates beyond the upstream chart? (e.g., GatewayClass, BackupStorageLocation, CiliumL2AnnouncementPolicy)
- **Initial values:** What default values should be set?

## Research Phase (MANDATORY)

**BEFORE writing any code:**

1. **Find the upstream chart** — Use web search or Context7 to find the Helm chart repository URL, chart name, and latest version
2. **Read a similar existing chart** — Use GitLab MCP to browse `cluster/charts/chart-<similar>` for reference. Pick the closest match by type:
   - Pure wrapper → read `chart-goldilocks`
   - With ExternalSecret → read `chart-external-dns` or `chart-velero`
   - With custom resources → read `chart-envoy-gateway`
   - Standalone CRs → read `chart-cilium-l2-announcement`
3. **Check upstream values** — Understand what the upstream chart exposes so you can set sensible defaults

## Present Before Writing

Scaffolding a chart creates a repository's worth of files. Present the plan per `output-diff` — chart name, upstream dependency and version, and the files to create — and write only on approval.

## Repository Structure

Every chart repo follows this structure:

```
chart-<name>/
├── .gitignore
├── .gitlab-ci.yml
├── .helmignore
├── Chart.yaml
├── Taskfile.yml
├── mise.toml
├── release.config.mjs
├── renovate.json
├── values.yaml
└── templates/              # only if custom templates needed
    ├── external-secret.yaml
    └── <custom-resource>.yaml
```

## File Templates

### Chart.yaml

**With upstream dependency:**

```yaml
apiVersion: v2
name: chart-<name>
description: <brief description>
type: application
version: 1.0.0

dependencies:
  - name: <upstream-chart-name>
    version: <upstream-version>
    repository: <upstream-repo-url>
    # alias: <name>  # only if upstream name differs from desired values key
```

- `version` is always `1.0.0` — semantic-release manages actual versioning via git tags
- Use `alias` when the upstream chart name is unwieldy (e.g., `gateway-helm` aliased to `envoy-gateway`, `kube-prometheus-stack` aliased to `prometheus-operator`)
- Repository can be HTTPS (`https://...`) or OCI (`oci://docker.io/...`)

**Without upstream dependency (standalone):**

```yaml
apiVersion: v2
name: chart-<name>
description: <brief description>
type: application
version: 1.0.0
```

### values.yaml

**Upstream defaults reference:** When writing values for an upstream chart dependency, include a comment at the top of the dependency's values block with a link to the upstream chart's default `values.yaml` (GitHub raw link or documentation URL). This helps future maintainers understand what options are available.

```yaml
# Upstream chart defaults: <link-to-upstream-values.yaml>
<dependency-name-or-alias>:
  key: value
  nested:
    key: value
```

Find the link during the Research Phase — check the chart's GitHub/GitLab repository for the `values.yaml` file, or the chart's documentation page listing all configurable values.

**For upstream wrappers**, nest values under the dependency name (or alias).

**For charts with ExternalSecret**, add a top-level `secrets:` block:

```yaml
secrets:
  secretStoreRef:
    kind: ClusterSecretStore
    name: secret.vault.int.kilic.dev
  <secret-name>:
    key: ""  # vault path — filled per-cluster via ApplicationSet values injection
```

**For standalone charts**, top-level values drive templates directly:

```yaml
name: <resource-name>
# ... resource-specific values
```

### .gitlab-ci.yml

Always identical:

```yaml
stages:
  - install
  - lint
  - publish

include:
  - project: devops/pipelines
    ref: helm@1.2.1
    file:
      - /helm/install.gitlab-ci.yml
      - /helm/lint.gitlab-ci.yml
  - project: devops/pipelines
    ref: semantic-release@1.6.0
    file:
      - /semantic-release/publish.gitlab-ci.yml
```

### Taskfile.yml

Always identical:

```yaml
# https://taskfile.dev

version: "3"

includes:
  helm:
    taskfile: https://gitlab.kilic.dev/libraries/taskfiles/-/raw/main/Taskfile.helm-application.yml
    flatten: true
```

### renovate.json

Always identical:

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["local>renovate/renovate-config:default/default"],
  "ignorePresets": []
}
```

### package.json

Minimal — used by semantic-release:

```json
{
  "name": "chart-<name>"
}
```

### release.config.mjs

Always identical:

```javascript
export default {
  branches: ['main'],
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    '@semantic-release/changelog',
    [
      '@semantic-release/git',
      {
        assets: ['CHANGELOG.md']
      }
    ],
    '@semantic-release/gitlab',
    [
      '@semantic-release/exec',
      {
        publishCmd: 'echo ${nextRelease.version} >> $TAGS_FILE'
      }
    ]
  ]
}
```

### .gitignore

Always identical:

```
charts/
dist/
.task/
```

### .helmignore

Standard Helm ignore file.

## ExternalSecret Template Patterns

**Single secret:**

```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: {{ $.Release.Name }}
  namespace: {{ $.Release.Namespace }}
spec:
  secretStoreRef:
    {{- .Values.secrets.secretStoreRef | toYaml | nindent 4 }}
  target:
    name: {{ $.Release.Name }}
    deletionPolicy: Delete
  dataFrom:
    - extract:
        conversionStrategy: Default
        decodingStrategy: None
        metadataPolicy: None
        key: {{ .Values.secrets.<name>.key | quote }}
```

**Multiple secrets (loop):**

```yaml
{{- range .Values.secrets.items }}
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: {{ .name | default $.Release.Name }}
  namespace: {{ $.Release.Namespace }}
spec:
  secretStoreRef:
    {{- .secretStoreRef | default $.Values.secrets.secretStoreRef | toYaml | nindent 4 }}
  target:
    name: {{ .targetName | default .name | default $.Release.Name }}
    deletionPolicy: Delete
  dataFrom:
    - extract:
        conversionStrategy: Default
        decodingStrategy: None
        metadataPolicy: None
        key: {{ .key | quote }}
{{- end }}
```

With corresponding `values.yaml`:

```yaml
secrets:
  secretStoreRef:
    kind: ClusterSecretStore
    name: secret.vault.int.kilic.dev
  items:
    - name: <secret-name>
      key: ""  # vault path
```

**All secrets reference `ClusterSecretStore` named `secret.vault.int.kilic.dev`** — this is the standard Vault integration point across all clusters.

## Key Principles

- **Use GitLab MCP** to research existing chart patterns before creating
- **Use web search / Context7** to find upstream chart repos and their values schema
- **Chart version is always `1.0.0`** — semantic-release handles actual versioning
- **All boilerplate files are identical** across repos — copy them exactly
- **Values nest under dependency name** (or alias) for upstream wrappers
- **Secrets always use ExternalSecret + ClusterSecretStore** (`secret.vault.int.kilic.dev`)
- **Vault paths are left empty** in defaults — filled per-cluster via ApplicationSet annotations injection
- **Only add templates that are needed** — pure wrappers have no `templates/` directory at all

## Checklist

- [ ] Identify upstream chart (name, version, repository URL) or confirm standalone
- [ ] Read a similar existing chart as reference
- [ ] Create `Chart.yaml` with correct dependency (or standalone)
- [ ] Create `values.yaml` with sensible defaults nested under dependency name
- [ ] If ExternalSecret needed: create `templates/external-secret.yaml` and add `secrets:` block to values
- [ ] If custom resources needed: create templates with proper Helm templating
- [ ] Create all boilerplate files (`.gitlab-ci.yml`, `Taskfile.yml`, `mise.toml`, `renovate.json`, `release.config.mjs`, `.gitignore`, `.helmignore`). `package.json` only when the chart actually needs a Node toolchain — copy whichever shape the nearest existing chart uses.
- [ ] Verify values structure matches upstream chart's expected format
- [ ] Match code style from the reference chart
