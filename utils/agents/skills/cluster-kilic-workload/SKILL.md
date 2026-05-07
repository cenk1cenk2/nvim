---
name: cluster-kilic-workload
description: Create a new workload deployment repository in the cluster/workloads group on GitLab. Scaffolds the kustomize structure with Helm charts, ExternalSecrets, Gateway API routing, databases, SSO, and other common patterns. Always manually invoked. Do NOT use for ArgoCD workloads (/argocd-kilic-workload), LB routing (/argocd-kilic-loadbalancer), or Helm chart wrappers (/cluster-kilic-chart).
interaction: chat
disable-model-invocation: true
argument-hint: "[workload-name] - e.g., 'seafile', 'immich', 'my-app'"
---

## system

### Cluster Workload Creator

> **IMPORTANT: This skill creates or modifies a workload deployment repository in the `cluster/workloads` group on GitLab (`gitlab.kilic.dev`).**

### How Workloads Work in This System

Each application deployed to a cluster gets a workload repository at `cluster/workloads/<name>`. These repos contain **kustomize-based Kubernetes manifests** that ArgoCD syncs to the target cluster. The cluster's ArgoCD repo (`cluster/<cluster>/argocd-kilic-<cluster>`) has a workload service that points to this repo.

Workload repos are self-contained — they define everything the application needs: deployments, services, routes, secrets, databases, storage, and monitoring.

### Directory Structure

The deployment root is always `.deploy/<cluster>/` where `<cluster>` is the target cluster name (e.g., `rubik`, `neutrino`, `overseer`).

**Single-component workload:**

```
.deploy/<cluster>/
  kustomization.yaml
  deployment.yaml
  service.yaml
  route-http.yaml
  es-*.yaml
  ...
```

**Multi-component workload** — split into subfolders, combined by a root kustomization:

```
.deploy/<cluster>/
  kustomization.yaml            # includes ./app/, ./postgresql/, ./valkey/, etc.
  <component-1>/
    kustomization.yaml
    ...resources...
  <component-2>/
    kustomization.yaml
    ...resources...
```

### Gather Requirements

Ask the user:

- **Workload name:** What application? (e.g., `immich`, `seafile`, `my-app`)
- **Target cluster:** Which cluster? (e.g., `rubik`, `neutrino`, `overseer`)
- **Components:** What does the application need?
  - Application deployment (plain manifests or Helm chart?)
  - Database? (PostgreSQL via CNPG, MariaDB via Bitnami Helm)
  - Cache? (Valkey/Redis)
  - S3 storage?
  - SSO/OIDC?
  - Public routing? (hostname, Gateway API)
  - Monitoring probe?
- **Helm chart?** Is there an upstream Helm chart, or plain Kubernetes manifests?
- **Secrets?** What Vault secrets are needed?

### Research Phase (MANDATORY)

**BEFORE writing any code**, use GitLab MCP to read a similar existing workload:

| If your workload needs...                   | Read this reference repo                                                                                |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| Plain manifests + routing                   | `cluster/workloads/gose` or `cluster/workloads/html-listr2`                                             |
| Helm chart via kustomize                    | `cluster/workloads/vouch` or `cluster/workloads/gitlab-runner`                                          |
| Helm + PostgreSQL (CNPG)                    | `cluster/workloads/immich` or `cluster/workloads/zitadel`                                               |
| Helm + MariaDB                              | `cluster/workloads/seafile`                                                                             |
| Multi-component (app + db + cache)          | `cluster/workloads/seafile` or `cluster/workloads/paperless-ngx`                                        |
| SSO via SecurityPolicy (gateway-level OIDC) | `cluster/workloads/gose`                                                                                |
| SSO via application config                  | `cluster/workloads/paperless-ngx` or `cluster/workloads/open-webui` (inside `cluster/workloads/ollama`) |
| GRPCRoute                                   | `cluster/workloads/zitadel`                                                                             |
| Kustomize base/overlay                      | `cluster/workloads/rustfs`                                                                              |

Read the `.deploy/<cluster>/` tree and key files from the reference repo to match patterns exactly.

### Kustomization Patterns

#### Root kustomization (multi-component)

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

labels:
  - includeSelectors: true
    includeTemplates: true
    pairs:
      app.kubernetes.io/part-of: <workload-name>

resources:
  - ./<component-1>/
  - ./<component-2>/
```

#### Component kustomization (with Helm chart)

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

labels:
  - includeSelectors: true
    includeTemplates: true
    pairs:
      app.kubernetes.io/name: <component-name>

helmCharts:
  - name: <chart-name>
    releaseName: <release-name>
    repo: <chart-repo-url>
    version: <chart-version>
    additionalValuesFiles:
      - values.yaml

resources:
  - ./es.yaml
  - ./route-http.yaml
```

**Helm chart values.yaml reference:** When writing a `values.yaml` for a Helm chart (whether in a component subfolder or top-level), include a comment at the top with a link to the upstream chart's default `values.yaml` (GitHub raw link or documentation URL). This helps future maintainers understand what options are available.

```yaml
# Upstream chart defaults: <link-to-upstream-values.yaml>
key: value
```

Find the link during the Research Phase — check the chart's GitHub/GitLab repository for the `values.yaml` file, or the chart's documentation page listing all configurable values. For custom charts from the `cluster/charts` group, link to that chart's `values.yaml` in GitLab.

#### Component kustomization (plain manifests)

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

labels:
  - includeSelectors: true
    includeTemplates: true
    pairs:
      app.kubernetes.io/name: <component-name>

resources:
  - ./deployment.yaml
  - ./service.yaml
  - ./route-http.yaml
```

#### Single-component kustomization (top-level, no subfolders)

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ./deployment.yaml
  - ./service.yaml
  - ./route-http.yaml
  - ./es-s3.yaml
  - ./probe.yaml
```

Can also have `helmCharts:` directly at the top level, and `configMapGenerator:` for config files.

### Common Patterns

The following patterns are **standardized** across all workloads. Use these exact patterns — do not invent alternatives.

---

#### ExternalSecret (Vault)

All secrets come from Vault via `ClusterSecretStore: secret.vault.int.kilic.dev`. Vault path convention: `<cluster>/<workload>/<component>`.

**Simple extract (all keys from one Vault path):**

```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: <secret-name>
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: secret.vault.int.kilic.dev
  target:
    name: <secret-name>
    deletionPolicy: Delete
  dataFrom:
    - extract:
        conversionStrategy: Default
        decodingStrategy: None
        metadataPolicy: None
        key: <cluster>/<workload>/<component>
```

**Templated (remap keys to env vars):**

```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: <secret-name>
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: secret.vault.int.kilic.dev
  target:
    name: <secret-name>
    deletionPolicy: Delete
    template:
      data:
        APP_ACCESS_KEY: "{{ .username }}"
        APP_SECRET_KEY: "{{ .password }}"
        APP_ENDPOINT: "{{ .endpoint }}"
  dataFrom:
    - extract:
        key: <cluster>/<workload>/<component>
```

**Individual key references:**

```yaml
spec:
  data:
    - secretKey: OAUTH_CLIENT_ID
      remoteRef:
        key: <cluster>/<workload>/sso
        property: client_id
    - secretKey: OAUTH_CLIENT_SECRET
      remoteRef:
        key: <cluster>/<workload>/sso
        property: client_secret
```

---

#### S3 Credentials

Always via ExternalSecret with templated key mapping. Vault path: `<cluster>/<workload>/s3`.

```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: s3-<workload>
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: secret.vault.int.kilic.dev
  target:
    name: s3-<workload>
    deletionPolicy: Delete
    template:
      data:
        ACCESS_KEY: "{{ .username }}"
        SECRET_KEY: "{{ .password }}"
        ENDPOINT: "{{ .endpoint }}"
        BUCKET: "{{ .bucket }}"
        REGION: "{{ .region }}"
  dataFrom:
    - extract:
        key: <cluster>/<workload>/s3
```

Adjust the template key names to match what the application expects (e.g., `GOSE_ACCESS_KEY`, `AWS_ACCESS_KEY_ID`, etc.).

---

#### Gateway API Routing (HTTPRoute)

All public-facing workloads use Gateway API. The parent gateway reference is always to the cluster's gateway in `cluster-system` namespace.

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: <workload>
spec:
  hostnames:
    - <hostname>.kilic.dev
  parentRefs:
    - group: gateway.networking.k8s.io
      kind: Gateway
      name: kilic-dev # ← check cluster's gateway name
      namespace: cluster-system
  rules:
    - backendRefs:
        - kind: Service
          name: <service-name>
          port: <port>
```

**The gateway name varies per cluster** — read the target cluster's ArgoCD repo (`src/cluster/cluster.constants.ts`) to find the correct gateway name.

**Robots.txt filter** — commonly added to prevent search engine indexing:

```yaml
# route-filter-robots.yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: HTTPRouteFilter
metadata:
  name: <workload>-robots
spec:
  directResponse:
    contentType: text/plain
    statusCode: 200
    body:
      type: Inline
      inline: |
        User-agent: *
        Disallow: /
```

Then add a rule to the HTTPRoute:

```yaml
rules:
  - matches:
      - path:
          type: Exact
          value: /robots.txt
    filters:
      - type: ExtensionRef
        extensionRef:
          group: gateway.envoyproxy.io
          kind: HTTPRouteFilter
          name: <workload>-robots
  - backendRefs:
      - kind: Service
        name: <service-name>
        port: <port>
```

**GRPCRoute** — for gRPC services (e.g., zitadel):

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GRPCRoute
metadata:
  name: <workload>-grpc
spec:
  hostnames:
    - <hostname>.kilic.dev
  parentRefs:
    - group: gateway.networking.k8s.io
      kind: Gateway
      name: kilic-dev
      namespace: cluster-system
  rules:
    - backendRefs:
        - kind: Service
          name: <service-name>
          port: <port>
      matches:
        - method:
            service: <grpc.service.Name>
```

---

#### SSO/OIDC

Two approaches depending on whether the application natively supports OIDC:

**1. Gateway-level OIDC (SecurityPolicy)** — when the app does NOT support OIDC natively. Envoy Gateway handles authentication before traffic reaches the app.

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: SecurityPolicy
metadata:
  name: <workload>-oidc
spec:
  oidc:
    clientID: "<zitadel-client-id>"
    clientSecret:
      kind: Secret
      name: sso-<workload> # ← from ExternalSecret
      group: ""
    provider:
      issuer: https://sso.kilic.dev
  targetRefs:
    - group: gateway.networking.k8s.io
      kind: HTTPRoute
      name: <workload>
```

With corresponding ExternalSecret for the SSO client secret:

```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: sso-<workload>
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: secret.vault.int.kilic.dev
  target:
    name: sso-<workload>
    deletionPolicy: Delete
    template:
      data:
        client-id: "{{ .client_id }}"
        client-secret: "{{ .client_secret }}"
  dataFrom:
    - extract:
        key: <cluster>/<workload>/sso
```

**2. Application-level OIDC** — when the app supports OIDC configuration via env vars or config files. Pass credentials via ExternalSecret, configure in app's values/config.

Vault path: `<cluster>/<workload>/sso` with keys: `client_id`, `client_secret`, `discovery_url`.

The SSO provider is always **Zitadel** at `https://sso.kilic.dev`.

---

#### PostgreSQL (CNPG)

Always deployed via CloudNativePG `Cluster` CRD with S3 barman backup.

```yaml
# db.yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: <workload>-db
spec:
  instances: 3
  imageName: ghcr.io/cloudnative-pg/postgresql:17
  postgresql:
    parameters:
      timezone: Europe/Vienna
  bootstrap:
    initdb:
      database: <db-name>
      owner: <db-user>
      secret:
        name: postgresql-user
  storage:
    size: 1Gi
    storageClass: proxmox-zfs
  walStorage:
    size: 4Gi
    storageClass: proxmox-zfs
  backup:
    barmanObjectStore:
      destinationPath: s3://cloudnativepg-<cluster>/<workload>
      s3Credentials:
        accessKeyId:
          name: postgresql-backup
          key: AWS_ACCESS_KEY_ID
        secretAccessKey:
          name: postgresql-backup
          key: AWS_SECRET_ACCESS_KEY
    retentionPolicy: 14d
```

```yaml
# db-backup.yaml
apiVersion: postgresql.cnpg.io/v1
kind: ScheduledBackup
metadata:
  name: <workload>-db-backup
spec:
  schedule: "@every 12h"
  backupOwnerReference: self
  cluster:
    name: <workload>-db
```

ExternalSecrets needed:

- `postgresql-user` — DB credentials from `<cluster>/<workload>/postgresql` (keys: `username`, `password`)
- `postgresql-backup` — S3 backup credentials from `<cluster>/<workload>/postgresql-backup` (keys: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)

Place in a `postgresql/` subfolder with its own `kustomization.yaml`.

---

#### MariaDB (Bitnami Helm)

Deployed via Bitnami Helm chart through kustomize with `namePrefix`:

```yaml
# db/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namePrefix: <workload>-

helmCharts:
  - name: mariadb
    releaseName: mariadb
    repo: oci://registry-1.docker.io/bitnamicharts
    version: <version>
    additionalValuesFiles:
      - values.yaml

resources:
  - ./es-user.yaml
  - ./es-backup.yaml
  - ./cronjob-mariadb-backup.yaml
```

Backup is handled by a CronJob using `jkaninda/mysql-bkup` image, backing up to S3.

ExternalSecrets needed:

- `es-user.yaml` — DB root/user passwords from `<cluster>/<workload>/mariadb`
- `es-backup.yaml` — DB creds + S3 creds for the backup CronJob

Place in a `db/` subfolder with its own `kustomization.yaml`.

**Read the reference repo** (`cluster/workloads/seafile`) for the full MariaDB pattern including CronJob, backup ConfigMap, and ExternalSecret details.

---

#### Monitoring Probe

Blackbox exporter probe for uptime monitoring:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: Probe
metadata:
  name: <workload>
  labels:
    release: prometheus-operator
spec:
  interval: 60s
  module: http_2xx
  prober:
    url: blackbox-exporter.monitoring.svc:9115
  targets:
    staticConfig:
      static:
        - https://<hostname>.kilic.dev
```

---

### Deployment Conventions

- **Keel auto-update:** For container images that should auto-update, add annotations:

  ```yaml
  annotations:
    keel.sh/policy: force
    keel.sh/trigger: poll
    keel.sh/match-tag: "true"
  ```

- **Revision history:** `revisionHistoryLimit: 0` on Deployments unless specified

- **Security context:** Prefer non-root where possible:

  ```yaml
  securityContext:
    runAsUser: 65534
    runAsNonRoot: true
    readOnlyRootFilesystem: true
  ```

- **Labels:** Use `app.kubernetes.io/part-of` at root kustomization level, `app.kubernetes.io/name` at component level via kustomize `labels:` block with `includeSelectors: true` and `includeTemplates: true`

- **Storage class:** `proxmox-zfs` for persistent volumes

- **Helm chart patches:** Use kustomize `patches:` with JSON patch operations to modify Helm-generated resources (add volumes, sidecars, etc.)

- **Kustomize nameReference:** When using `configMapGenerator` or `secretGenerator` with hash suffixes, add a `configurations:` entry pointing to a `config.yaml` that maps the generated name through ExternalSecret `templateFrom` or CronJob references

### Key Principles

- **Use GitLab MCP** to research existing workload patterns before creating
- **Match the existing pattern exactly** — consistency across repos is critical
- **One subfolder per component** for multi-component workloads
- **All secrets through ExternalSecret + Vault** — never hardcode secrets
- **All routing through Gateway API** — never use Ingress
- **SSO always via Zitadel** at `https://sso.kilic.dev`
- **PostgreSQL always via CNPG** with S3 barman backup
- **MariaDB always via Bitnami Helm** with CronJob backup
- **Vault path convention:** `<cluster>/<workload>/<component>`

### Checklist

- [ ] Determine workload structure (single vs multi-component)
- [ ] Read similar existing workload as reference
- [ ] Create `.deploy/<cluster>/kustomization.yaml` with correct labels
- [ ] If multi-component: create subfolder per component with own `kustomization.yaml`
- [ ] If Helm chart: add `helmCharts:` to kustomization with `additionalValuesFiles`
- [ ] If secrets: create ExternalSecret(s) referencing `ClusterSecretStore: secret.vault.int.kilic.dev`
- [ ] If S3: create S3 ExternalSecret with standard template mapping
- [ ] If routing: create HTTPRoute referencing correct cluster gateway
- [ ] If robots.txt needed: create HTTPRouteFilter with directResponse
- [ ] If SSO (gateway-level): create SecurityPolicy + SSO ExternalSecret
- [ ] If SSO (app-level): create ExternalSecret with OIDC credentials, configure in app values
- [ ] If PostgreSQL: create CNPG Cluster + ScheduledBackup + ExternalSecrets in `postgresql/` subfolder
- [ ] If MariaDB: create Bitnami Helm + CronJob backup + ExternalSecrets in `db/` subfolder
- [ ] If monitoring: create Probe resource
- [ ] Verify kustomize labels (`part-of` at root, `name` at component)
- [ ] Match code style from reference workload
