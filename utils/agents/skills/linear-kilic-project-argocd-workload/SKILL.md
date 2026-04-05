---
name: linear-kilic-project-argocd-workload
description: Create a Linear project for deploying application workloads to Kubernetes clusters via ArgoCD. Use when user says "deploy my-app", "add a workload", or "deploy this service to the cluster". Do NOT use for system components (linear-kilic-project-argocd-system) or generic projects (linear-project-create).
interaction: chat
references:
  - ../references/plan-mode.md
  - ../references/output-diff.md
  - ../references/linear-mandatory-fields.md
argument-hint: "[workload-name] - e.g., 'renovate-jobs', 'my-app', 'postgres-cluster'"
---

## system

### ArgoCD Workload Deployment Project Generator

> **PREREQUISITE: The `linear-kilic` workspace skill MUST be active before this skill runs.** If no workspace context exists, auto-invoke it via `ReadMcpResourceTool({ server: "mcphub", uri: "skills://skill/linear-kilic" })`. This skill is kilic-dev workspace specific.

> **ALWAYS enter plan mode.** Read the `plan-mode` reference (strict variant) for full directives — resolve references from the `<References>` block via MCP filesystem tools.
>
> - Use `EnterPlanMode` tool immediately.
> - Create plan file in `~/.claude/plans/YYYY-MM-DD-workload-<name>.md`.
> - Research the workload, existing patterns, and cluster requirements.
> - Present the plan for user approval before creating issues.

> Read the `output-diff` reference for chat output conventions before writing to external systems — present reasoning and content in logical chunks for user approval.

### Overview

This skill creates a Linear project for deploying application workloads through ArgoCD. Workloads are application deployments, CRDs, or services that run on target clusters (not system-level operators). They are deployed via `cluster/<cluster>/argocd-kilic-<cluster>` and optionally expose services through the load balancer cluster.

### Architecture Pattern

All repositories are on `gitlab.kilic.dev`. Workload deployments involve these repository groups:

```
cluster/<cluster>/argocd-kilic-<cluster>/                          # Target cluster ArgoCD config
├── src/workloads/<workload>/<workload>.service.ts           # Pulumi workload definition
├── workloads/<workload>/1-manifest/                         # Generated manifests
│   ├── namespace.yaml
│   ├── externalsecret.yaml (if needed)
│   └── <workload>-crds.yaml
└── workloads/routes/1-manifest/ (if LB on same cluster)    # Route manifests
    └── httproute-<workload>.yaml

cluster/<lb-cluster>/argocd-kilic-<lb-cluster>/                    # Load balancer cluster (if needed)
└── workloads/routes/1-manifest/
    └── httproute-<workload>.yaml

infrastructure/pulumi-config-gitlab                          # ArgoCD repository access
Vault: secret/<cluster>/<namespace>/...                      # Secrets (if needed)
```

**Known clusters:** `moon`, `nailbed`, `neutrino`, `overseer`, `rubik`, `sun`

Each cluster has its own ArgoCD repo at `cluster/<cluster>/argocd-kilic-<cluster>`.

### Workflow

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

- **Target cluster:** Browse `cluster/<cluster>/argocd-kilic-<cluster>` repo — workloads directory structure, existing Pulumi services
- **Existing workloads:** Browse `workloads/<similar-workload>/1-manifest/` — manifest patterns, namespace setup, ExternalSecret examples
- **Pulumi services:** Browse `src/workloads/<similar-workload>/<similar-workload>.service.ts` — WorkloadsService injection, namespace creation, ArgoCD Application setup
- **Routes:** Browse `workloads/routes/1-manifest/` — HTTPRoute and DNSEndpoint patterns
- **Load balancer:** Browse `cluster/<lb-cluster>/argocd-kilic-<lb-cluster>` repo — Gateway definitions, route manifests

**3. Create Project and Issues:**

Create the Linear project with issues based on the template below. **Only include optional issues if the user confirmed they are needed during requirements gathering.**

> **CRITICAL:** Every issue MUST have `state: "Backlog"` set explicitly. The Linear API defaults to `Triage` which is WRONG. See the `linear-mandatory-fields` reference for all required fields.

> **Blocking relations:** Use `blockedBy` to set dependency order between issues in a project. Think through the dependency graph and set blocking relations so work order is clear.

### Issue Template

**Project:** `<Workload-Name> Deployment`

The following issues form the deployment pipeline. Adjust based on what's actually needed — not every workload requires secrets or load balancer routes.

**Issue 1: Create Workload Pulumi Service**

> **Repo:** `cluster/<cluster>/argocd-kilic-<cluster>`
> **Purpose:** Each cluster's ArgoCD repo contains Pulumi code that generates Kubernetes manifests. A workload service defines the namespace, ArgoCD Application, and any in-cluster routing. Pulumi outputs generated manifests to `workloads/<workload>/1-manifest/` which ArgoCD then syncs to the cluster.

- Create `src/workloads/<workload>/<workload>.service.ts`
- Define Pulumi workload with namespace, ArgoCD Application
- Create namespace manifest in `workloads/<workload>/1-manifest/`

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
- Create ExternalSecret CRD in `workloads/<workload>/1-manifest/`
- Configure Vault access for the namespace
- Reference ClusterSecretStore for the cluster
- **Blocked by:** Issue 1

**Issue 4: Create Workload Manifests**

> **Repo:** `cluster/<cluster>/argocd-kilic-<cluster>`
> **Purpose:** The actual application manifests (Deployments, CRDs, ConfigMaps, etc.) that define how the workload runs. These go into `workloads/<workload>/1-manifest/` and are synced by the ArgoCD Application created in Issue 1.

- Create deployment/CRD manifests in `workloads/<workload>/1-manifest/`
- Configure resource limits, security contexts
- Set up ConfigMaps/Secrets references
- Add kustomization.yaml if needed
- **Blocked by:** Issue 2 (and Issue 3 if secrets are needed)

**Issue 5 (Optional — if load balancer is needed): Configure Load Balancer Routes**

> **Repo:** `cluster/<lb-cluster>/argocd-kilic-<lb-cluster>`
> **Purpose:** The LB cluster acts as the ingress point. Its Pulumi services create Gateway listeners, TLSRoute/HTTPRoute resources, EnvoyGateway Backends (pointing to target cluster gateway FQDNs), and DNSEndpoint resources for DNS registration. Each target cluster that needs external/internal routing gets a dedicated service file.

- Add route Pulumi service in LB cluster: `src/workloads/cluster-<target>/cluster-<target>.service.ts`
- Define TLSRoute/HTTPRoute → Backend pointing to target cluster gateway FQDN
- Create DNSEndpoint for DNS (Cloudflare for external, OPNSense for internal)
- Configure target cluster gateway listener if needed
- Repeat for each load balancer cluster if multiple are needed
- **Blocked by:** Issue 4

### Namespace Convention

Workloads typically use:

- `<workload-name>` for simple workloads (e.g., `renovate`)
- `<application>-<environment>` for multi-environment deployments
- Application-specific namespaces (e.g., `mailrise`, `grafana`)

### Workload Service Pattern (Pulumi)

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

### Routing Architecture

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

### Key Principles

- **Use `gitlab` MCP** for researching existing patterns
- **Workloads go to target cluster** — deployed via `cluster/<cluster>/argocd-kilic-<cluster>`, not `argocd-system`
- **Load balancer cluster is separate** — routes are configured in `cluster/<lb-cluster>/argocd-kilic-<lb-cluster>` (ask user which cluster(s) serve as load balancer)
- **All routes are Pulumi-managed** — manifests in `workloads/*/1-manifest/` are generated output, not hand-written
- **Two DNS providers:** Cloudflare (external, `provider.kilic.dev/external-dns-cloudflare`) and OPNSense (internal, `provider.kilic.dev/external-dns-opnsense-loki`)
- **Two LB gateways:** `default` for external traffic, `internal` for internal-only services
- **Only create issues that are needed** — skip optional issues unless confirmed by user
- **Set dependency relations** with `blockedBy` for sequential issues
- **Workload repository** can be existing or created — clarify with user

### Directory Structure Reference

**Target Cluster (e.g., `cluster/rubik/argocd-kilic-rubik`):**

```
src/workloads/my-workload/my-workload.service.ts  # Pulumi definition
workloads/my-workload/1-manifest/                  # Generated manifests
  ├── namespace.yaml
  ├── externalsecret.yaml
  └── my-crds.yaml
```

**Load Balancer Cluster (`cluster/<lb-cluster>/argocd-kilic-<lb-cluster>`):**

```
src/cluster/gateway.service.ts                              # Gateway definitions (default + internal)
src/cluster/cluster.constants.ts                            # Gateway enum + IPs
src/workloads/routes/routes.service.ts                      # Direct route definitions (on LB itself)
src/workloads/cluster-<target>/cluster-<target>.service.ts  # Routes to target cluster services
workloads/routes/1-manifest/                                # Generated route manifests
workloads/cluster-<target>/1-manifest/                      # Generated target cluster route manifests
```
