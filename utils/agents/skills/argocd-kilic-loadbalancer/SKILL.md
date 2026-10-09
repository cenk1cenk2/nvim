---
name: argocd-kilic-loadbalancer
description: argocd-kilic-loadbalancer Create or extend routing workloads in a load balancer cluster's ArgoCD repo - Pulumi services for VM routing or direct LB routes, and the operator-lb relay that exposes a target Kubernetes cluster through it. Use when adding or changing how traffic reaches a VM or an in-cluster service on the LB cluster. Not for ordinary workloads in a target cluster, standalone deployment repos, or chart wrappers.
disableModelInvocation: true
argumentHint: '[workload-name or ''add route to <existing>''] - e.g. ''vm-gitlab'''
references:
  - ../references/present-first.md
  - ../references/output-diff.md
  - ./references/argocd-kilic-loadbalancer-dns.md
  - ./references/argocd-kilic-loadbalancer-cross-cluster.md
  - ./references/argocd-kilic-loadbalancer-tcproute.md
  - ./references/argocd-kilic-loadbalancer-vm-routing.md
  - ./references/argocd-kilic-loadbalancer-direct-routes.md
---

## LB Cluster Routing Workload Creator

Posture: `present-first`.
> **IMPORTANT: This skill assumes you are already inside a load balancer cluster ArgoCD repository** (e.g., `cluster/sun/argocd-sun`).

## How This Repository Works

This is a NestJS + Pulumi monorepo that generates Kubernetes manifests for a **load balancer cluster**. Unlike target cluster repos where workloads are application deployments, here workloads are **routing services** — they define how traffic reaches target clusters, VMs, or services.

When Pulumi runs, it executes all registered services which output YAML manifests to `workloads/*/1-manifest/`. ArgoCD watches this repo and syncs those manifests to the LB cluster.

Key files:
- **`src/constants.ts`** — Cluster identity: `ARGOCD_REPOSITORY`, `ARGOCD_CLUSTER`, `ArgoCDProjects`, `EnvoyGatewayPolicyLabels`, `ENVOY_GATEWAY_POLICY_LABEL_ENABLED`
- **`src/cluster/cluster.constants.ts`** — Gateway enum names and IPs (e.g., `ClusterGateways.DEFAULT`, `ClusterGateways.INTERNAL`)
- **`src/cluster/gateway.service.ts`** — Defines the actual gateways (external + internal), EnvoyProxy, BackendTrafficPolicy, L2 DNSEndpoints for gateway IPs
- **`src/workloads/workloads.module.ts`** — NestJS module registering all workload services

## After It Syncs

Once merged, ArgoCD syncs the Application automatically — the same `newApplication()` pattern used by `argocd-kilic-workload` sets `syncPolicy.automated.prune: true` with the cascade-delete finalizer already attached and no `Prune=confirm` gate (verified against a rendered manifest in a target-cluster `apps/1-manifest/`). Removing a route or resource from `.deploy/<cluster>/` therefore deletes it on the LB cluster on the next automated sync, with no human confirmation step — the opposite of `argocd-system`'s own chart-pin components, which hold every prune for a human to confirm in the ArgoCD UI. Do not assume that gate applies here.

This pattern is never Kargo-promoted; a routing Application syncs straight from its own repository's `HEAD`. Load `argocd-kilic` to check sync status or investigate after merge.

## Workload Types

There are three types of routing workloads in an LB cluster:

1. **`vm-<name>`** — Routes traffic to a VM or host (e.g., `vm-gitlab`). Uses Backend pointing to VM FQDN. Typically external-only with Cloudflare DNS. Build it as VM/host routing per `argocd-kilic-loadbalancer-vm-routing`.

2. **`routes`** — Direct HTTPRoutes handled by the LB cluster itself (e.g., domain redirects). No Backend needed — routes go directly to in-cluster services. Build it as direct routes per `argocd-kilic-loadbalancer-direct-routes`.

3. **`monitoring`** — Routes for the monitoring stack, same shape as `routes` (verified on `argocd-sun`).

**A target Kubernetes cluster is reached through the operator-lb relay**, not an LB-cluster workload. The target cluster declares relay ListenerSets (GatewayAPI, parented to the LB cluster's gateway, annotated `lb.kilic.dev/upstream`) in `cluster/<c>/argocd-<c>/src/cluster/relay.service.ts`, and its Upstreams with their DNSEndpoints in `src/cluster/operator-lb.service.ts`; the workload repos author the TLSRoutes/TCPRoutes/UDPRoutes parented to that ListenerSet plus their DNSEndpoints. The operator-lb operator on the LB cluster copies everything into the `lb-<target>` namespace and owns the Envoy Backend side. Build it per `argocd-kilic-loadbalancer-cross-cluster`.

A TCP service on a dedicated gateway port (SMTP, databases) in any of these adds a listener, Backend, TCPRoute, and CNAME per `argocd-kilic-loadbalancer-tcproute`.

## Two Modes of Operation

This skill supports both **creating new workload services** and **adding routes to existing ones**:

- **New workload:** Create the full service file, register in module
- **Add to existing:** Read the existing service, add new Backend/Route/DNSEndpoint entries to the `deploy()` method

When adding to an existing service, **do NOT create a new file** — modify the existing `src/workloads/<workload>/<workload>.service.ts` directly.

## Gather Requirements

Ask the user:

- **New or existing?** Creating a new workload service, or adding routes to an existing one?
- **Workload type:** `vm-<name>` or `routes`, or a target Kubernetes cluster (operator-lb relay, declared in the target cluster's repos)?
- **Backend target:** What FQDN does traffic go to? (e.g., `rubik-gw.int.loki.arpa:443`, `gitlab.loki.arpa:443`)
- **Routes needed:** What hostnames/domains need routing?
- **External or internal (or both)?** See DNS Configuration below
- **OPNSense instances:** Which OPNSense instances? (`loki`, `thor`, or both)
- **Protocol:** TLS passthrough (TLSRoute), HTTP (HTTPRoute), or TCP (TCPRoute)?

## Research Phase (MANDATORY)

**BEFORE writing any code**, read these files from the current repository:

1. **`src/constants.ts`** — Note `ARGOCD_CLUSTER`, `ArgoCDProjects`, `EnvoyGatewayPolicyLabels`
2. **`src/cluster/cluster.constants.ts`** — Note `ClusterGateways` enum values (e.g., `DEFAULT`, `INTERNAL`)
3. **`src/cluster/gateway.service.ts`** — Understand gateway definitions and IPs
4. **`src/workloads/workloads.module.ts`** — See current registrations
5. **The target workload service** — If adding to existing, read the current service file. If creating new, read a similar existing one as template.

This is mandatory because **each LB cluster has different gateway names, IPs, and OPNSense configurations**.

## Present Before Writing

Routing workloads span DNS, certificates, and cross-cluster services, and the scaffold writes many files at once. Present the plan per `output-diff` — service name, target cluster, hostnames, and the files to create — and write only on approval.

## DNS Configuration

### How DNS Works in This System

There are **two separate mechanisms** for creating DNS records:

1. **Route-based DNS (automatic):** When a TLSRoute/HTTPRoute has an `external-dns-cloudflare` label, external-dns watches the Gateway API route and **automatically creates DNS records** for each hostname on that route. No explicit DNSEndpoint CRD needed. The DNS target is determined by the gateway's `external-dns.alpha.kubernetes.io/target` annotation.

2. **DNSEndpoint-based DNS (explicit):** For internal DNS (OPNSense), L2 announcements, and TCP CNAME records, you create explicit `DNSEndpoint` CRDs. External-dns watches these and creates the corresponding records.

Provider labels, Cloudflare and OPNSense record patterns, wildcard handling, and FQDN naming per `argocd-kilic-loadbalancer-dns`.

**The `loki.kilic.dev` pivot point:** The DEFAULT gateway has annotation `external-dns.alpha.kubernetes.io/target: 'loki.kilic.dev'`. This tells external-dns: "when creating Cloudflare DNS records for routes on this gateway, point them at `loki.kilic.dev`". `loki.kilic.dev` resolves to the WAN/public IP that NATs to the DEFAULT gateway's Cilium LB IP. The INTERNAL gateway has **no such annotation** — routes on it don't get Cloudflare records through this mechanism.

### Gateway ↔ DNS Decision Matrix

| Traffic Type | Gateway | DNS Mechanism | Provider Labels on Route | Annotations on Route | Separate DNSEndpoint? |
|-------------|---------|--------------|--------------------------|---------------------|-----------------------|
| External, proxied | `DEFAULT` | Route-based (auto) | `external-dns-cloudflare` | `cloudflare-proxied: "true"` | No |
| External, direct | `DEFAULT` | Route-based (auto) | `external-dns-cloudflare` | None | No |
| External, TCP | `DEFAULT` | Explicit DNSEndpoint | None on route | None | Yes (CNAME → `loki.kilic.dev`) |
| Internal service | `INTERNAL` | Explicit DNSEndpoint | None on route | None | Yes (A record, OPNSense loki/thor) |
| L2 announcement | N/A | Explicit DNSEndpoint | N/A | N/A | Yes (A record, OPNSense loki) |

## Adding Routes to an Existing Service

When adding a new route to an existing workload service (e.g., adding a new domain to `vm-gitlab`):

1. **Read the existing service file** — understand current Backends, routes, and DNS configuration
2. **Determine what's needed:**
   - New Backend? Only if routing to a different upstream than existing ones
   - New L2 DNSEndpoint? Only if the target has a new gateway IP not yet registered
   - New TLSRoute/HTTPRoute/TCPRoute? Usually yes — this is the new route
   - New Cloudflare/OPNSense DNSEndpoint? If the route needs its own DNS record (TCP services)
3. **Add to the `deploy()` method** — follow the ordering pattern: DNSEndpoints first, then Backends, then Routes
4. **For internal routes:** Ask which OPNSense instances (loki, thor, or both) should handle DNS
5. **For TCP routes:** Remember to add a `clusterGateway.listen()` call for the new port

## Key API Methods

| Method | Purpose |
|--------|---------|
| `clusterGateway.reflect(workload)` | Creates BackendTrafficPolicy with proxy protocol in workload namespace |
| `clusterGateway.listen(gateway, listeners)` | Adds listener definitions to a gateway (TCP ports, HTTPS termination) |
| `clusterGateway.reference(gateway)` | Returns gateway reference for `parentRefs` |
| `clusterGateway.readTargets(gateway)` | Reads Cilium LB-IPAM IPs from gateway annotations |
| `envoy.newBackend(name, spec, opts)` | Creates EnvoyGateway Backend pointing to upstream FQDN |
| `gateway.newTLSRoute(name, spec, gateway, opts)` | Creates TLS passthrough route |
| `gateway.newHTTPRoute(name, spec, gateway, opts)` | Creates HTTP route (redirects, path-based routing) |
| `gateway.newTCPRoute(name, spec, opts)` | Creates TCP route (custom ports) |
| `gateway.newDNSEndpoint(name, spec, opts)` | Creates DNSEndpoint for external-dns |

## Registration

After creating a **new** service, register it in `src/workloads/workloads.module.ts`:

1. Add import: `import { MyService } from './<workload>/<workload>.service'`
2. Add to `providers` array

**Not needed when adding routes to an existing service.**

## Checklist

- [ ] Read `src/constants.ts` and `src/cluster/cluster.constants.ts`
- [ ] Read `src/cluster/gateway.service.ts` for gateway definitions and IPs
- [ ] Read the target workload service (existing or similar reference)
- [ ] If new service: create `src/workloads/<workload>/<workload>.service.ts`
- [ ] If new service: register in `src/workloads/workloads.module.ts`
- [ ] If existing service: add new entries to the `deploy()` method
- [ ] Use correct `ClusterGateways` enum for external vs internal routes
- [ ] Configure correct DNS labels per provider (Cloudflare, OPNSense loki, OPNSense thor)
- [ ] For Cloudflare routes: add `cloudflare-proxied` annotation (except TCP)
- [ ] For OPNSense DNSEndpoints: include `providerSpecific` description
- [ ] For TCP routes: use CNAME DNS (no Cloudflare proxy), add gateway listener
- [ ] For dual OPNSense: include both loki and thor labels when requested
- [ ] Add `BACKEND_TRAFFIC_POLICY_PROXY_PROTOCOL_V2` label on routes
- [ ] Use `clusterGateway.reflect(workload)` for BackendTrafficPolicy
- [ ] L2 announcements: register target gateway IPs as `.lb.int.loki.arpa` FQDNs
- [ ] Match code style from the reference workload
