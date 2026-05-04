---
name: linear-kilic-project-argocd-system
description: Create a Linear project for deploying system-level components (operators, controllers, infrastructure tools) to Kubernetes clusters via ArgoCD. Use when user says "deploy cert-manager", "add renovate-operator", or "set up a system component". Do NOT use for application workloads (linear-kilic-project-argocd-workload) or generic projects (linear-project-create).
interaction: chat
references:
  - ../references/plan-mode.md
  - ../references/output-diff.md
argument-hint: "[component-name] - e.g., 'renovate-operator', 'cert-manager', 'velero'"
---

## system

### ArgoCD System Deployment Project Generator

> **PREREQUISITE: The `linear-kilic` workspace skill MUST be active before this skill runs.** If no workspace context exists, auto-invoke it via the `linear-kilic` skill (load it as defined in `load-skills`). This skill is kilic-dev workspace specific.

> **ALWAYS enter plan mode.** Read the `plan-mode` reference (strict variant) for full directives
>
> - Use `EnterPlanMode` tool immediately.
> - Create plan file in `~/.claude/plans/YYYY-MM-DD-argocd-system-<component>.md`.
> - Research the component, existing patterns, and cluster requirements.
> - Present the plan for user approval before creating issues.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

### Overview

This skill creates a Linear project for deploying system-level Kubernetes components through ArgoCD. System components are operators, controllers, and infrastructure tools deployed to `cluster-system` or operator-specific namespaces (e.g., `cert-manager-system`, `operator-external-secrets-system`).

### Architecture Pattern

All repositories are on `gitlab.kilic.dev`. The deployment involves these repository groups:

```
cluster/charts/chart-<component>                                        # Helm chart wrapper
cluster/argocd-kilic-system/base/<component>/applicationset.yaml              # ApplicationSet definition
cluster/argocd-kilic-root/src/argocd-kilic/assets/cluster/<cluster>/labels.yml      # Feature labels
cluster/argocd-kilic-root/src/argocd-kilic/assets/cluster/<cluster>/annotations.yml # Values injection
infrastructure/pulumi-config-gitlab                                     # ArgoCD repository access
cluster/<lb-cluster>/argocd-kilic-<lb-cluster>                                # Load balancer routes (if needed)
Vault: secret/<cluster>/<namespace>/...                                 # Secrets (optional)
```

**Known clusters:** `moon`, `nailbed`, `neutrino`, `overseer`, `rubik`, `sun`

Each cluster has its own ArgoCD repo at `cluster/<cluster>/argocd-kilic-<cluster>` and label/annotation files at `cluster/argocd-kilic-root/src/argocd-kilic/assets/cluster/<cluster>/`.

### Workflow

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
- **ApplicationSets:** Browse `cluster/argocd-kilic-system` repo → `base/<similar-component>/applicationset.yaml` — label selectors, namespace, sync policy, values injection
- **Labels/Annotations:** Browse `cluster/argocd-kilic-root` repo → `src/argocd-kilic/assets/cluster/<cluster>/labels.yml` for feature flags and `annotations.yml` for values injection patterns
- **Pulumi:** Browse `infrastructure/pulumi-config-gitlab` repo → `src/modules/` for ArgoCD deploy key and webhook setup
- **Load balancer:** Browse `cluster/<lb-cluster>/argocd-kilic-<lb-cluster>` repo → `src/cluster/gateway.service.ts` for gateway definitions, `src/workloads/cluster-<target>/` for route service patterns

**3. Create Project and Issues:**

Create the Linear project with issues based on the template below. **Only include optional issues if the user confirmed they are needed during requirements gathering.**

### Issue Template

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
> **Purpose:** Central Pulumi project that manages GitLab configuration including deploy keys and webhooks. ArgoCD needs a deploy key on the new chart repo to pull manifests, and a webhook to trigger syncs on push.

- Grant ArgoCD deploy key access to new chart repository
- Run Pulumi stack update
- Verify deploy key and webhook creation
- **Blocked by:** Issue 1

**Issue 3: Create ApplicationSet in cluster/argocd-kilic-system**

> **Repo:** `cluster/argocd-kilic-system`
> **Purpose:** Contains ApplicationSet definitions that tell ArgoCD how to deploy system components across clusters. An ApplicationSet uses cluster label selectors (`system.feature.kilic.dev/<component>`) to determine which clusters get the component, and reads values from cluster annotations for per-cluster configuration.

- Use the `.claude/skills/add-base-application` skill in the cluster repository to create the ApplicationSet
- Create `base/<component>/applicationset.yaml`
- Configure cluster label selector
- Set up values injection from cluster annotations
- Define namespace and sync policy
- **Blocked by:** Issue 2

**Issue 4 (Optional — if secrets are needed): Configure Secrets in Vault**

> **Purpose:** Some system components need secrets (API keys, certificates, credentials). These are stored in Vault and synced to Kubernetes via ExternalSecret CRDs that reference a ClusterSecretStore.

- Create secrets at `secret/<cluster>/<namespace>/...`
- Set up ExternalSecret CRD in target clusters
- Configure Vault access for the namespace
- **Blocked by:** Issue 1

**Issue 5: Enable Feature Label for Target Clusters**

> **Repo:** `cluster/argocd-kilic-root`
> **Purpose:** Central repo that defines per-cluster metadata. Each cluster has `labels.yml` (feature flags that ApplicationSets match on) and `annotations.yml` (values injected into Helm releases). Adding the feature label here triggers the ApplicationSet to deploy the component to that cluster.

- Use the `.claude/skills/promote-application` skill in the cluster repository to promote the application to target clusters
- Add `system.feature.kilic.dev/<component>: "true"` to `labels.yml`
- Update for each target cluster in `cluster/argocd-kilic-root/src/argocd-kilic/assets/cluster/`
- Configure values via `annotations.yml` if needed
- **Blocked by:** Issue 3 (and Issue 4 if secrets are needed)

**Issue 6 (Optional — if load balancer is needed): Configure Load Balancer Routes**

> **Repo:** `cluster/<lb-cluster>/argocd-kilic-<lb-cluster>`
> **Purpose:** Each cluster's ArgoCD repo contains Pulumi code that generates Kubernetes manifests. The LB cluster acts as the ingress point — its Pulumi services create Gateway listeners, TLSRoute/HTTPRoute resources, EnvoyGateway Backends (pointing to target cluster gateway FQDNs), and DNSEndpoint resources for DNS registration.

- Add route Pulumi service in LB cluster: `src/workloads/cluster-<target>/cluster-<target>.service.ts`
- Define TLSRoute/HTTPRoute → Backend pointing to target cluster gateway FQDN
- Create DNSEndpoint for DNS (Cloudflare for external, OPNSense for internal)
- Configure target cluster gateway listener if needed
- Repeat for each load balancer cluster if multiple are needed
- **Blocked by:** Issue 5

### Routing Architecture

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

### Label Naming Convention

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

Both files are located at `cluster/argocd-kilic-root/src/argocd-kilic/assets/cluster/<cluster>/`.

### Namespace Convention

System operators typically use:

- `<component>-system` for operators (e.g., `operator-external-secrets-system`)
- `cluster-system` for cluster-wide tools
- `<component>` for some operators (e.g., `renovate-operator-system`)

### Key Principles

- **Use `gitlab` MCP** for researching existing patterns
- **Always create Helm chart first** — ApplicationSet depends on it
- **Run Pulumi after chart creation** — ArgoCD needs repository access
- **Cluster labels enable selective deployment** — not all clusters need every component
- **Load balancer cluster is separate** — routes are Pulumi-managed in `cluster/<lb-cluster>/argocd-kilic-<lb-cluster>` (ask user which cluster(s) serve as load balancer)
- **All routes are Pulumi-managed** — manifests in `workloads/*/1-manifest/` are generated output, not hand-written
- **Two DNS providers:** Cloudflare (external, `provider.kilic.dev/external-dns-cloudflare`) and OPNSense (internal, `provider.kilic.dev/external-dns-opnsense-loki`)
- **Two LB gateways:** `default` for external traffic, `internal` for internal-only services
- **Only create issues that are needed** — skip optional issues unless confirmed by user
- **Reference existing skills** — ApplicationSet creation uses `.claude/skills/add-base-application`, promotion uses `.claude/skills/promote-application`
- **Set dependency relations** with `blockedBy` for sequential issues
