---
name: linear-kilic-project-argocd-workload
description: linear-kilic-project-argocd-workload Create a Linear project for deploying an application workload to Kubernetes through ArgoCD. Use on "deploy my-app", "add a workload". Not for system components such as operators or controllers, or for an ordinary project.
references:
  - ../references/present-first.md
  - ../references/output-diff.md
  - ../references/linear/linear-mandatory-fields.md
argumentHint: '[workload] - e.g. ''my-app'', ''postgres-cluster'''
---

## ArgoCD Workload Deployment Project Generator

Posture: `present-first`.
**PREREQUISITE: The `linear-kilic` workspace skill MUST be active before this skill runs.** If no workspace context exists, auto-invoke it via the `linear-kilic` skill. This skill is kilic-dev workspace specific.

## Overview

This skill creates a Linear project for deploying application workloads through ArgoCD. Workloads are application deployments, CRDs, or services that run on target clusters (not system-level operators).

## Architecture Pattern

All repositories are on `gitlab.kilic.dev`. **A workload spans two repositories, and confusing them is the most common mistake.**

```
cluster/workloads/<workload>/                     # The actual Kubernetes manifests
└── .deploy/<cluster>/                            # Hand-written kustomize, one tree per cluster
    ├── kustomization.yaml
    └── <component>/{kustomization,values,es,route-http}.yaml

cluster/<cluster>/argocd-<cluster>/               # Target cluster ArgoCD config (NestJS + Pulumi)
├── src/workloads/<workload>/<workload>.service.ts   # Namespace + ArgoCD Application only
└── apps/1-manifest/                              # Pulumi-GENERATED Application manifest

cluster/<lb-cluster>/argocd-<lb-cluster>/         # Load balancer cluster (if exposure is needed)
└── src/workloads/cluster-<target>/cluster-<target>.service.ts

infrastructure/pulumi-config-gitlab               # ArgoCD repository access (new repos only)
Vault: secret/<cluster>/<namespace>/...           # Secrets (if needed)
```

**The cluster ArgoCD repo does NOT contain the workload's manifests.** Its Pulumi service emits only a Namespace and an ArgoCD Application whose source points at `cluster/workloads/<workload>`. Everything under `1-manifest/` there is generated output, never hand-edited. Anyone looking for a workload's Deployment or values in the cluster repo will not find it.

**Known clusters:** `moon`, `nailbed`, `neutrino`, `overseer`, `rubik`, `sun`. Each has its ArgoCD repo at `cluster/<cluster>/argocd-<cluster>`; the two cluster-wide roots sit at the group top level as `cluster/argocd-root` and `cluster/argocd-system`.

Load `cluster-kilic-workload` when writing the manifest repo's contents, and `argocd-kilic-workload` when writing the Pulumi service.

## Workflow

**1. Gather Requirements from User:**

- **Workload name:** What application/service? (e.g., `renovate-jobs`, `my-app`)
- **Target clusters:** Which clusters need this workload?
- **Namespace:** Where should it deploy? (workload-specific namespace)
- **Repository:** Where is the workload config? (or should we create one?)
- **Secrets needed:** What Vault secrets are required?
- **Load balancer needed:** Does it need HTTPRoute/DNSEndpoint exposure? If yes, which cluster(s) serve as load balancer?
- **CRDs or standard deployment:** Is this CRD-based or standard Kubernetes resources?

**2. Research Existing Patterns:**

Use GitLab MCP to analyze existing deployments for reference:

- **Target cluster:** Browse `cluster/<cluster>/argocd-<cluster>` repo — workloads directory structure, existing Pulumi services
- **Existing workloads:** Browse `workloads/<similar-workload>/1-manifest/` — manifest patterns, namespace setup, ExternalSecret examples
- **Pulumi services:** Browse `src/workloads/<similar-workload>/<similar-workload>.service.ts` — WorkloadsService injection, namespace creation, ArgoCD Application setup
- **Routes:** Browse `workloads/routes/1-manifest/` — HTTPRoute and DNSEndpoint patterns
- **Load balancer:** Browse `cluster/<lb-cluster>/argocd-<lb-cluster>` repo — Gateway definitions, route manifests

**3. Create Project and Issues:**

Create the Linear project with issues based on the template below, presented per `output-diff` for approval before writing to Linear. **Only include optional issues if the user confirmed they are needed during requirements gathering.**

> **CRITICAL:** Every issue MUST have `state: "Backlog"` set explicitly. The Linear API defaults to `Triage` which is WRONG. All required fields per `linear-mandatory-fields`.

> **Blocking relations:** Use `blockedBy` to set dependency order between issues in a project. Think through the dependency graph and set blocking relations so work order is clear.

## Issue Template

**Project:** `<Workload-Name> Deployment`

The following issues form the deployment pipeline. Adjust based on what's actually needed — not every workload requires secrets or load balancer routes.

**Issue 1: Create the workload Pulumi service**

> **Repo:** `cluster/<cluster>/argocd-<cluster>`
> **Purpose:** Registers the workload with the cluster — a Namespace and an ArgoCD Application whose source points at the manifest repo. It defines any Gateway listener the workload needs. It does NOT contain the workload's own manifests.

- Create `src/workloads/<workload>/<workload>.service.ts`
- Define the namespace and the ArgoCD Application, sourcing `cluster/workloads/<workload>` at `.deploy/<cluster>`
- Register the service in `src/workloads/workloads.module.ts`
- Run the synth and commit the generated Application under `apps/1-manifest/`

**Issue 2: Run pulumi-config-gitlab for ArgoCD Access**

> **Repo:** `infrastructure/pulumi-config-gitlab`
> **Purpose:** Central Pulumi project that manages GitLab configuration including deploy keys and webhooks. ArgoCD needs a deploy key on the workload repo to pull manifests, and a webhook to trigger syncs on push. Only needed if a new repository was created.

- Grant ArgoCD deploy key access to workload repository (if new repo)
- Run Pulumi stack update
- Verify deploy key and webhook creation
- **Blocked by:** Issue 1

**Issue 3 (Optional — if secrets are needed): Configure Secrets in Vault**

> **Purpose:** Some workloads need secrets (API keys, database credentials, etc.). These are stored in Vault and synced to Kubernetes via ExternalSecret CRDs that reference a ClusterSecretStore.

- Create secrets at `secret/<cluster>/<namespace>/...`
- Create the ExternalSecret in `cluster/workloads/<workload>/.deploy/<cluster>/`
- Reference the cluster's ClusterSecretStore
- Confirm the namespace's `default` service account carries the `system:auth-delegator` binding Vault auth needs
- **Blocked by:** Issue 1

**Issue 4: Create the workload manifests**

> **Repo:** `cluster/workloads/<workload>`
> **Purpose:** The actual application manifests — Deployments, CRDs, ConfigMaps, Helm values via kustomize — that define how the workload runs. Hand-written kustomize under `.deploy/<cluster>/`, synced by the Application created in Issue 1.

- Create `.deploy/<cluster>/kustomization.yaml` and the per-component directories
- Configure resource limits and security contexts
- Add the HTTPRoute if the workload is exposed in-cluster
- **Blocked by:** Issue 2 (and Issue 3 if secrets are needed)

Load `cluster-kilic-workload` for this issue — it owns the directory conventions and the reference repos to copy from.

**Issue 5 (Optional — if load balancer is needed): Configure Load Balancer Routes**

> **Repo:** `cluster/<lb-cluster>/argocd-<lb-cluster>`
> **Purpose:** The LB cluster acts as the ingress point. Its Pulumi services create Gateway listeners, TLSRoute/HTTPRoute resources, EnvoyGateway Backends (pointing to target cluster gateway FQDNs), and DNSEndpoint resources for DNS registration. Each target cluster that needs external/internal routing gets a dedicated service file.

- Add route Pulumi service in LB cluster: `src/workloads/cluster-<target>/cluster-<target>.service.ts`
- Define TLSRoute/HTTPRoute → Backend pointing to target cluster gateway FQDN
- Create DNSEndpoint for DNS (Cloudflare for external, OPNSense for internal)
- Configure target cluster gateway listener if needed
- Repeat for each load balancer cluster if multiple are needed
- **Blocked by:** Issue 4

## Namespace Convention

Workloads typically use:

- `<workload-name>` for simple workloads (e.g., `renovate`)
- `<application>-<environment>` for multi-environment deployments
- Application-specific namespaces (e.g., `mailrise`, `grafana`)

## Workload Service Pattern (Pulumi)

```typescript
@Injectable()
export class MyWorkloadService implements OnModuleInit {
  constructor(
    @InjectWorkloadsService() private readonly workloads: WorkloadsService,
    @InjectGatewayAPIService() private readonly gateway: GatewayAPIService
    // ... other services
  ) {}

  public async onModuleInit(): Promise<void> {
    const workload = this.workloads.create({
      name: "my-workload",
      namespace: "my-namespace" // optional, defaults to workload name
    })

    // Create namespace, ArgoCD Application, etc.
    await this.deploy(workload)
  }
}
```

## Routing Architecture

Routes, DNS, and gateway configuration are **all managed via Pulumi** in each cluster's argocd repo. The YAML manifests in `workloads/routes/1-manifest/` are Pulumi-generated output — not hand-written.

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
- In-cluster HTTPRoutes from gateway to services (defined in workload's Pulumi service)

**DNS providers:**
- **External (Cloudflare):** label `provider.kilic.dev/external-dns-cloudflare: "true"`, annotation `external-dns.alpha.kubernetes.io/cloudflare-proxied: "true"`
- **Internal (OPNSense):** label `provider.kilic.dev/external-dns-opnsense-loki: "true"`, FQDN pattern `<name>.lb.int.loki.arpa`

## Key Principles

- **Use `gitlab` MCP** for researching existing patterns
- **Workloads go to target cluster** — deployed via `cluster/<cluster>/argocd-<cluster>`, not `argocd-system`
- **Load balancer cluster is separate** — routes are configured in `cluster/<lb-cluster>/argocd-<lb-cluster>` (ask user which cluster(s) serve as load balancer)
- **All routes are Pulumi-managed** — manifests in `workloads/*/1-manifest/` are generated output, not hand-written
- **Two DNS providers:** Cloudflare (external, `provider.kilic.dev/external-dns-cloudflare`) and OPNSense (internal, `provider.kilic.dev/external-dns-opnsense-loki`)
- **Two LB gateways:** `default` for external traffic, `internal` for internal-only services
- **Only create issues that are needed** — skip optional issues unless confirmed by user
- **Set dependency relations** with `blockedBy` for sequential issues
- **Workload repository** can be existing or created — clarify with user

## Directory Structure Reference

**Manifest repo (e.g., `cluster/workloads/my-workload`)** — hand-written kustomize:

```
.deploy/<cluster>/
  ├── kustomization.yaml
  └── my-workload/
      ├── kustomization.yaml
      ├── values.yaml
      ├── es.yaml
      └── route-http.yaml
```

**Target Cluster (e.g., `cluster/rubik/argocd-rubik`)** — the Pulumi source is hand-written, everything under `1-manifest/` is generated:

```
src/workloads/my-workload/my-workload.service.ts  # Pulumi definition
src/workloads/workloads.module.ts                 # Service registration
apps/1-manifest/                                  # Generated Application manifest
```

**Load Balancer Cluster (`cluster/<lb-cluster>/argocd-<lb-cluster>`):**

```
src/cluster/gateway.service.ts                              # Gateway definitions (default + internal)
src/cluster/cluster.constants.ts                            # Gateway enum + IPs
src/workloads/routes/routes.service.ts                      # Direct route definitions (on LB itself)
src/workloads/cluster-<target>/cluster-<target>.service.ts  # Routes to target cluster services
workloads/routes/1-manifest/                                # Generated route manifests
workloads/cluster-<target>/1-manifest/                      # Generated target cluster route manifests
```
