---
name: cluster-kilic-workload
description: cluster-kilic-workload Create a workload deployment repo in the workloads group - kustomize structure with Helm charts, external secrets, Gateway API routing, databases, SSO. Use when a new application needs its own deployment manifests. Not for the ArgoCD service that points at such a repo, load balancer routing, or chart wrappers.
disableModelInvocation: true
argumentHint: '[workload-name] - e.g. ''seafile'', ''immich'''
references:
  - ../references/present-first.md
  - ../references/output-diff.md
  - ./references/kilic-argocd-pvc-restore.md
  - ./references/cluster-kilic-workload-kustomization.md
  - ./references/cluster-kilic-workload-external-secret.md
  - ./references/cluster-kilic-workload-s3.md
  - ./references/cluster-kilic-workload-routing.md
  - ./references/cluster-kilic-workload-sso.md
  - ./references/cluster-kilic-workload-postgresql.md
  - ./references/cluster-kilic-workload-mariadb.md
  - ./references/cluster-kilic-workload-monitoring-probe.md
---

## Cluster Workload Creator

Posture: `present-first`.
> **IMPORTANT: This skill creates or modifies a workload deployment repository in the `cluster/workloads` group on GitLab (`gitlab.kilic.dev`).**

## How Workloads Work in This System

Each application deployed to a cluster gets a workload repository at `cluster/workloads/<name>`. These repos contain **kustomize-based Kubernetes manifests** that ArgoCD syncs to the target cluster. The cluster's ArgoCD repo (`cluster/<cluster>/argocd-<cluster>`) has a workload service that points to this repo. The two cluster-wide roots sit at the group top level instead: `cluster/argocd-root` and `cluster/argocd-system`.

Workload repos are self-contained — they define everything the application needs: deployments, services, routes, secrets, databases, storage, and monitoring.

**One cluster or many.** Most workloads deploy to a single cluster and carry one `.deploy/<cluster>/` tree. A workload that runs on several clusters adds `.deploy/base/` for what is identical everywhere, and each `.deploy/<cluster>/` overlays only what differs — `monitoring` and `monitoring-ruler` do this across six clusters. Reach for `base` only on the second cluster; a single-cluster workload with a `base` is indirection with nothing on the other side.

## Directory Structure

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

## Gather Requirements

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

## Research Phase (MANDATORY)

**BEFORE writing any code**, use GitLab MCP to read a similar existing workload:

| If your workload needs...                   | Read this reference repo                                                                                |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| Plain manifests + routing                   | `cluster/workloads/gose` or `cluster/workloads/html-listr2`                                             |
| Helm chart via kustomize                    | `cluster/workloads/gitlab-runner`                                                                        |
| Helm + PostgreSQL (CNPG)                    | `cluster/workloads/immich` or `cluster/workloads/zitadel`                                               |
| Helm + MariaDB                              | `cluster/workloads/seafile`                                                                             |
| Multi-component (app + db + cache)          | `cluster/workloads/seafile` or `cluster/workloads/paperless-ngx`                                        |
| SSO via SecurityPolicy (gateway-level OIDC) | `cluster/workloads/gose`                                                                                |
| SSO via application config                  | `cluster/workloads/paperless-ngx` or `cluster/workloads/open-webui` (inside `cluster/workloads/ollama`) |
| GRPCRoute                                   | `cluster/workloads/zitadel`                                                                             |
| Kustomize base/overlay                      | `cluster/workloads/rustfs`                                                                              |

Read the `.deploy/<cluster>/` tree and key files from the reference repo to match patterns exactly.

## Present Before Writing

The scaffold writes several files at once. Present the plan per `output-diff` — workload name, target cluster, namespace, components, and the files to create — and write only on approval.

## Kustomization Patterns

Write the root, component and single-component kustomizations, and the upstream-defaults comment on every Helm `values.yaml`, per `cluster-kilic-workload-kustomization`.

## Common Patterns

The following patterns are **standardized** across all workloads. Use these exact patterns — do not invent alternatives. Each component takes only the pattern it needs:

- **ExternalSecret (Vault):** `cluster-kilic-workload-external-secret`.
- **S3 credentials:** `cluster-kilic-workload-s3`.
- **Gateway API routing (HTTPRoute, robots.txt filter, GRPCRoute):** `cluster-kilic-workload-routing`.
- **SSO/OIDC:** `cluster-kilic-workload-sso`.
- **PostgreSQL (CNPG):** `cluster-kilic-workload-postgresql`.
- **MariaDB (Bitnami Helm):** `cluster-kilic-workload-mariadb`.
- **Restore (data and databases):** restore is the counterpart to the backup patterns and uses the same tooling. Restore jobs are **always** `suspend: true` — they ship dormant via kustomize and are triggered by hand. Build them from the templates and S3 conventions in `kilic-argocd-pvc-restore`.
- **Monitoring probe:** `cluster-kilic-workload-monitoring-probe`.

## Deployment Conventions

- **Version pins promote through Kargo:** every long-running image (including init containers, sidecars and image volumes) and every Helm chart is pinned in `.deploy/<cluster>/` and promoted by a Warehouse, a `warehouses` entry in the repository's `.promote/values.yaml`, with Renovate disabled for it in `renovate.json`. Pin a versioned image as `<registry>/<repo>:<tag>`, and an image on a moving tag (`latest`, `stable`) as `<registry>/<repo>:<tag>@sha256:<digest>` from the currently published digest. Load `kargo-kilic` before writing the first pin. One-off Jobs (restores, migrations) stay unpinned.

- **Revision history:** `revisionHistoryLimit: 0` on Deployments unless specified.

- **Security context:** Prefer non-root where possible:

  ```yaml
  securityContext:
    runAsUser: 65534
    runAsNonRoot: true
    readOnlyRootFilesystem: true
  ```

- **Labels:** Use `app.kubernetes.io/part-of` at root kustomization level, `app.kubernetes.io/name` at component level via kustomize `labels:` block with `includeSelectors: true` and `includeTemplates: true`.

- **Storage class:** `proxmox-zfs` for persistent volumes.

- **Helm chart patches:** Use kustomize `patches:` with JSON patch operations to modify Helm-generated resources (add volumes, sidecars, etc.).

- **Kustomize nameReference:** When using `configMapGenerator` or `secretGenerator` with hash suffixes, add a `configurations:` entry pointing to a `config.yaml` that maps the generated name through ExternalSecret `templateFrom` or CronJob references.

## Key Principles

- **All secrets through ExternalSecret + Vault** — never hardcode secrets.
- **All routing through Gateway API** — never use Ingress.
- **Vault path convention:** `<cluster>/<workload>/<component>`.

## Checklist

- [ ] Determine workload structure (single vs multi-component).
- [ ] Read similar existing workload as reference.
- [ ] Create `.deploy/<cluster>/kustomization.yaml` with correct labels.
- [ ] If multi-component: create subfolder per component with own `kustomization.yaml`.
- [ ] If Helm chart: add `helmCharts:` to kustomization with `additionalValuesFiles`.
- [ ] If secrets: create ExternalSecret(s) referencing `ClusterSecretStore: secret.vault.int.kilic.dev`.
- [ ] If S3: create S3 ExternalSecret with standard template mapping.
- [ ] If routing: create HTTPRoute referencing correct cluster gateway.
- [ ] If robots.txt needed: create HTTPRouteFilter with directResponse.
- [ ] If SSO (gateway-level): create SecurityPolicy + SSO ExternalSecret.
- [ ] If SSO (app-level): create ExternalSecret with OIDC credentials, configure in app values.
- [ ] If PostgreSQL: create CNPG Cluster + ScheduledBackup + ExternalSecrets in `postgresql/` subfolder.
- [ ] If MariaDB: create Bitnami Helm + CronJob backup + ExternalSecrets in `db/` subfolder.
- [ ] If monitoring: create Probe resource.
- [ ] Onboard every pinned image and chart into Kargo (`.promote/` `kustomization.yaml` and `values.yaml`, `kargo-root` registry, `authorized-stage`, Renovate disable).
- [ ] Verify kustomize labels (`part-of` at root, `name` at component).
- [ ] Match code style from reference workload.
