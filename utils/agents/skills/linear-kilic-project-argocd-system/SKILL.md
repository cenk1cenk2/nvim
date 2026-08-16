---
name: linear-kilic-project-argocd-system
description: linear-kilic-project-argocd-system Create a Linear project for deploying a system component - an operator, controller, or infrastructure tool - to Kubernetes through ArgoCD. Use on "deploy cert-manager", "set up a system component". Not for application workloads, or for an ordinary project.
references:
  - ../references/present-first.md
  - ../references/output-diff.md
argumentHint: '[component] - e.g. ''cert-manager'', ''velero'''
---

## ArgoCD System Deployment Project Generator

Posture: `present-first`.
**PREREQUISITE: The `linear-kilic` workspace skill MUST be active before this skill runs.** If no workspace context exists, auto-invoke it via the `linear-kilic` skill. This skill is kilic-dev workspace specific.

## Overview

This skill creates a Linear project for deploying system-level Kubernetes components through ArgoCD. System components are operators, controllers, and infrastructure tools deployed to `cluster-system` or operator-specific namespaces (e.g., `cert-manager-system`, `operator-external-secrets-system`).

## Architecture Pattern

All repositories are on `gitlab.kilic.dev`. The deployment involves these repository groups:

```
cluster/charts/chart-<component>                                        # Helm chart wrapper
cluster/argocd-system/base/<component>/applicationset.yaml              # ApplicationSet definition
cluster/argocd-root/src/argocd/assets/cluster/<cluster>/labels.yml      # Feature labels
cluster/argocd-root/src/argocd/assets/cluster/<cluster>/annotations.yml # Values injection
infrastructure/pulumi-config-gitlab                                     # ArgoCD repository access
cluster/<lb-cluster>/argocd-<lb-cluster>                                # Load balancer routes (if needed)
Vault: secret/<cluster>/<namespace>/...                                 # Secrets (optional)
```

**Known clusters:** `moon`, `nailbed`, `neutrino`, `overseer`, `rubik`, `sun`

Each cluster has its own ArgoCD repo at `cluster/<cluster>/argocd-<cluster>` and label/annotation files at `cluster/argocd-root/src/argocd/assets/cluster/<cluster>/`.

## Workflow

**1. Gather Requirements from User:**

- **Component name:** What operator/tool? (e.g., `renovate-operator`, `cert-manager`, `velero`)
- **Target clusters:** Which clusters need this? (e.g., `rubik`, `sun`, `all production`)
- **Namespace:** Where should it deploy? (default: `<component>-system` or `cluster-system`)
- **Secrets needed:** Does it need Vault secrets? If yes, what paths?
- **Load balancer needed:** Does it need HTTPRoute/DNSEndpoint? If yes, which cluster(s) serve as load balancer?
- **Chart source:** Is there an upstream Helm chart? What repository?

**2. Research Existing Patterns:**

Use GitLab MCP to analyze existing deployments for reference:

- **Charts:** Browse `cluster/charts` group for `chart-<similar-component>` repos — check `Chart.yaml` (upstream dependency), `values.yaml` (defaults), `Taskfile.yml` (release automation), `renovate.json` (dependency updates)
- **ApplicationSets:** Browse `cluster/argocd-system` repo → `base/<similar-component>/applicationset.yaml` — label selectors, namespace, sync policy, values injection
- **Labels/Annotations:** Browse `cluster/argocd-root` at `src/argocd/assets/cluster/<cluster>/labels.yml` for feature flags and `annotations.yml` for values injection patterns
- **Pulumi:** Browse `infrastructure/pulumi-config-gitlab` repo → `src/modules/` for ArgoCD deploy key and webhook setup
- **Load balancer:** Browse `cluster/<lb-cluster>/argocd-<lb-cluster>` repo → `src/cluster/gateway.service.ts` for gateway definitions, `src/workloads/cluster-<target>/` for route service patterns

**3. Create Project and Issues:**

Create the Linear project with issues based on the template below, presented per `output-diff` for approval before writing to Linear. **Only include optional issues if the user confirmed they are needed during requirements gathering.**

## Issue Template

**Project:** `<Component-Name> Deployment`

The following issues form the deployment pipeline. Adjust based on what's actually needed — not every deployment requires secrets or load balancer routes.

**Issue 1: Create Helm Chart in cluster/charts**

> **Repo:** `cluster/charts/chart-<component>` (new GitLab repo in the `cluster/charts` group)
> **Purpose:** Thin wrapper around the upstream Helm chart. ArgoCD pulls from this repo to deploy the component. Each system component gets its own chart repo that pins the upstream version and provides default values.

- Create repository `cluster/charts/chart-<component>`
- Chart.yaml wrapping upstream chart as a dependency
- values.yaml with default configuration
- Taskfile.yml for release automation (chart packaging and publishing)
- renovate.json for automated upstream version updates

**Issue 2: Run pulumi-config-gitlab for ArgoCD Access**

> **Repo:** `infrastructure/pulumi-config-gitlab`
> **Purpose:** Provisions the shared `argocd` deploy key and the push webhook on the new chart repository. Without it ArgoCD cannot read the chart.

- Run the `pulumi-config-gitlab` pipeline
- Verify the shared `argocd` deploy key is enabled on the new project
- Verify the push webhook exists
- **Blocked by:** Issue 1

**No code change is needed.** `src/modules/argocd/argocd.service.ts` discovers `cluster/charts` by **group**, so a new repo in that group is picked up automatically — the stack simply has to be re-run, and nothing triggers it on project creation. Skipping this fails later, at Issue 3 or 4, as a repository-access error that looks like a chart problem.

**Issue 3: Create the base ApplicationSet in cluster/argocd-system**

> **Repo:** `cluster/argocd-system`
> **Purpose:** ApplicationSet definitions telling ArgoCD how to deploy system components across clusters, selecting clusters by the `system.feature.kilic.dev/<component>` label and reading per-cluster values from cluster annotations.

- Use the repo's own `.claude/skills/add-base-application` skill rather than hand-writing the YAML
- Create `base/<component>/applicationset.yaml` and its `kustomization.yaml`
- Confirm the `system.kilic.dev/values-layers: "true"` label is present
- **Blocked by:** Issue 2

Adding to `base/` deploys nothing anywhere — `base/` is referenced only through environment overlays. The repo's skill encodes conventions that fail **silently** when missed, so use it instead of restating them.

**Issue 4: Promote to the target environment**

> **Repo:** `cluster/argocd-system`
> **Purpose:** Adds the component to an environment overlay (`development`, `load-balancer`, `platform`, `production`), pinning the chart repository's release tag. This is the step that actually deploys.

- Use the repo's own `.claude/skills/promote-application` skill
- Add the component to `<environment>/kustomization.yaml` in alphabetical order
- Create `<environment>/<component>/kustomization.yaml` and `patch-applicationset.yaml`
- Pin `targetRevision` to the **chart repository's** semantic-release tag, fetched with `gitlab__list_tags` rather than from a local clone
- **Blocked by:** Issue 3

**Issue 5 (Optional — if secrets are needed): Configure Secrets in Vault**

> **Purpose:** Some system components need secrets (API keys, certificates, credentials). These are stored in Vault and synced to Kubernetes via ExternalSecret CRDs that reference a ClusterSecretStore.

- Create secrets at `secret/<cluster>/<namespace>/...`
- Set up ExternalSecret CRD in target clusters
- Configure Vault access for the namespace
- **Blocked by:** Issue 1

**Issue 6: Enable Feature Label for Target Clusters**

> **Repo:** `cluster/argocd-root`
> **Purpose:** Defines per-cluster metadata. Each cluster has `labels.yml` (feature flags that ApplicationSets match on) and `annotations.yml` (values injected into Helm releases). Adding the feature label makes the ApplicationSet generate an Application for that cluster.

- Add `system.feature.kilic.dev/<component>: "true"` to `labels.yml` for each target cluster
- Re-run the Pulumi synth and **commit the regenerated manifests** under `argocd/1-manifest/`
- Configure values via `annotations.yml` only if per-cluster values are genuinely needed
- **Blocked by:** Issue 4 (and Issue 5 if secrets are needed)

This repo commits generated output, and the generated file is what ArgoCD reads. Editing `labels.yml` alone has no effect.

**Issue 7: Enable automated sync**

> **Repo:** `cluster/argocd-system`
> **Purpose:** New base ApplicationSets ship with `syncPolicy.automated` commented out by convention. Until it is enabled, the Application exists and never syncs.

- Uncomment `automated: {enabled: true, prune: true, selfHeal: true}`, or perform a deliberate manual first sync and record that choice
- Confirm the Application reaches Synced and Healthy
- Confirm any CRDs the chart ships report Established
- **Blocked by:** Issue 6

**Issue 8 (Optional — if load balancer is needed): Configure Load Balancer Routes**

> **Repo:** `cluster/<lb-cluster>/argocd-<lb-cluster>`
> **Purpose:** Each cluster's ArgoCD repo contains Pulumi code that generates Kubernetes manifests. The LB cluster acts as the ingress point — its Pulumi services create Gateway listeners, TLSRoute/HTTPRoute resources, EnvoyGateway Backends (pointing to target cluster gateway FQDNs), and DNSEndpoint resources for DNS registration.

- Add route Pulumi service in LB cluster: `src/workloads/cluster-<target>/cluster-<target>.service.ts`
- Define TLSRoute/HTTPRoute → Backend pointing to target cluster gateway FQDN
- Create DNSEndpoint for DNS (Cloudflare for external, OPNSense for internal)
- Configure target cluster gateway listener if needed
- Repeat for each load balancer cluster if multiple are needed
- **Blocked by:** Issue 7

## Routing Architecture

Routes, DNS, and gateway configuration are **all managed via Pulumi** in each cluster's argocd repo. The YAML manifests in `workloads/*/1-manifest/` are Pulumi-generated output — not hand-written.

**Traffic flow for exposed services:**

```
Internet/LAN → LB cluster gateway → TLSRoute/HTTPRoute (LB cluster)
  → Backend (FQDN pointing to target cluster gateway) → Target cluster gateway
  → HTTPRoute (target cluster) → Service
```

**LB cluster (`argocd-<lb-cluster>`)** handles:
- Gateway definitions (`src/cluster/gateway.service.ts`) with `default` (external) and `internal` gateways
- Per-target-cluster route services (`src/workloads/cluster-<target>/cluster-<target>.service.ts`)
- TLSRoute/HTTPRoute → EnvoyGateway Backend pointing to target cluster gateway FQDN
- DNSEndpoint resources for both OPNSense (internal) and Cloudflare (external)

**Target cluster (`argocd-<cluster>`)** handles:
- Its own gateway definitions (`src/cluster/gateway.service.ts`) — cluster-specific gateway names/IPs
- In-cluster HTTPRoutes from gateway to services

**DNS providers:**
- **External (Cloudflare):** label `provider.kilic.dev/external-dns-cloudflare: "true"`, annotation `external-dns.alpha.kubernetes.io/cloudflare-proxied: "true"`
- **Internal (OPNSense):** label `provider.kilic.dev/external-dns-opnsense-loki: "true"`, FQDN pattern `<name>.lb.int.loki.arpa`

## Label Naming Convention

Feature labels in `labels.yml`:

```yaml
system.feature.kilic.dev/<component>: "true"
```

Values injection in `annotations.yml`:

```yaml
values.system.feature.kilic.dev/<component>: |
  key: value
  nested:
    key: value
```

Both files are located at `cluster/argocd-root/src/argocd/assets/cluster/<cluster>/`.

## Namespace Convention

System operators typically use:

- `<component>-system` for operators (e.g., `operator-external-secrets-system`)
- `cluster-system` for cluster-wide tools
- `<component>` for some operators (e.g., `renovate-operator`)

## Key Principles

- **Use `gitlab` MCP** for researching existing patterns
- **Always create Helm chart first** — ApplicationSet depends on it, and promotion pins a tag the chart repo must already have released
- **Run Pulumi after chart creation** — ArgoCD cannot read the repo without the deploy key, and the failure surfaces later as a chart error
- **Promotion is the deploy** — `base/` is referenced only through environment overlays, so nothing reaches a cluster until the environment merge lands
- **Sync is off by default** — new base ApplicationSets ship with `automated` commented out; enabling it is its own step
- **`argocd-root` commits generated output** — edit the asset file, then re-run the synth and commit the regenerated manifest
- **Cluster labels enable selective deployment** — not all clusters need every component
- **Load balancer cluster is separate** — routes are Pulumi-managed in `cluster/<lb-cluster>/argocd-<lb-cluster>` (ask user which cluster(s) serve as load balancer)
- **All routes are Pulumi-managed** — manifests in `workloads/*/1-manifest/` are generated output, not hand-written
- **Two DNS providers:** Cloudflare (external, `provider.kilic.dev/external-dns-cloudflare`) and OPNSense (internal, `provider.kilic.dev/external-dns-opnsense-loki`)
- **Two LB gateways:** `default` for external traffic, `internal` for internal-only services
- **Only create issues that are needed** — skip optional issues unless confirmed by user
- **Reference existing skills** — ApplicationSet creation uses `.claude/skills/add-base-application`, promotion uses `.claude/skills/promote-application`
- **Set dependency relations** with `blockedBy` for sequential issues
