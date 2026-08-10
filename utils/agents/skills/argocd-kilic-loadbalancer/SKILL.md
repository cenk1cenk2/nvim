---
name: argocd-kilic-loadbalancer
description: argocd-kilic-loadbalancer Create or extend routing workloads in a load balancer cluster's ArgoCD repo - Pulumi services for cross-cluster routing, VM routing, or direct LB routes. Use when adding or changing how traffic reaches a target cluster, a VM, or an in-cluster service. Not for ordinary workloads in a target cluster, standalone deployment repos, or chart wrappers.
disableModelInvocation: true
argumentHint: '[workload-name or ''add route to <existing>''] - e.g. ''cluster-rubik'', ''vm-gitlab'''
references:
  - ../references/present-first.md
  - ../references/output-diff.md
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

## Workload Types

There are three types of routing workloads in an LB cluster:

1. **`cluster-<target>`** — Routes traffic to a target Kubernetes cluster's gateway (e.g., `cluster-rubik`). Uses Backend pointing to target cluster gateway FQDN. Can have external (Cloudflare), internal (OPNSense) routes, and TCP routes.

2. **`vm-<name>`** — Routes traffic to a VM or host (e.g., `vm-gitlab`). Uses Backend pointing to VM FQDN. Typically external-only with Cloudflare DNS.

3. **`routes`** — Direct HTTPRoutes handled by the LB cluster itself (e.g., domain redirects). No Backend needed — routes go directly to in-cluster services.

## Two Modes of Operation

This skill supports both **creating new workload services** and **adding routes to existing ones**:

- **New workload:** Create the full service file, register in module
- **Add to existing:** Read the existing service, add new Backend/Route/DNSEndpoint entries to the `deploy()` method

When adding to an existing service, **do NOT create a new file** — modify the existing `src/workloads/<workload>/<workload>.service.ts` directly.

## Gather Requirements

Ask the user:

- **New or existing?** Creating a new workload service, or adding routes to an existing one?
- **Workload type:** `cluster-<target>`, `vm-<name>`, or `routes`?
- **Backend target:** What FQDN does traffic go to? (e.g., `rubik-gw.int.loki.arpa:443`, `gitlab.loki.arpa:443`)
- **Routes needed:** What hostnames/domains need routing?
- **External or internal (or both)?** See DNS Configuration section below
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

**The `loki.kilic.dev` pivot point:** The DEFAULT gateway has annotation `external-dns.alpha.kubernetes.io/target: 'loki.kilic.dev'`. This tells external-dns: "when creating Cloudflare DNS records for routes on this gateway, point them at `loki.kilic.dev`". `loki.kilic.dev` resolves to the WAN/public IP that NATs to the DEFAULT gateway's Cilium LB IP. The INTERNAL gateway has **no such annotation** — routes on it don't get Cloudflare records through this mechanism.

### DNS Providers

There are **three** external-dns provider instances, each controlled by a label:

| Provider | Label | Purpose |
|----------|-------|---------|
| **Cloudflare** | `provider.kilic.dev/external-dns-cloudflare: "true"` | External/public DNS. Can be used on both routes (automatic) and DNSEndpoints (explicit CNAME). |
| **OPNSense (loki)** | `provider.kilic.dev/external-dns-opnsense-loki: "true"` | Internal DNS on loki appliance. Primary instance for L2 announcements and internal service records. |
| **OPNSense (thor)** | `provider.kilic.dev/external-dns-opnsense-thor: "true"` | Internal DNS on thor appliance. Secondary instance, often used alongside loki for redundancy. |

A DNSEndpoint can target **multiple OPNSense instances** simultaneously by including both labels:

```typescript
labels: {
  'provider.kilic.dev/external-dns-opnsense-thor': 'true',
  'provider.kilic.dev/external-dns-opnsense-loki': 'true'
}
```

### Cloudflare DNS Patterns

There are **three** Cloudflare DNS patterns depending on the use case:

**1. Cloudflare-proxied (orange cloud):** For HTTP(S) services that benefit from Cloudflare CDN/WAF. External-dns creates a proxied record pointing to `loki.kilic.dev`.

```typescript
// On TLSRoute or HTTPRoute — DNS record created automatically from hostnames
labels: {
  'provider.kilic.dev/external-dns-cloudflare': 'true'
},
annotations: {
  'external-dns.alpha.kubernetes.io/cloudflare-proxied': 'true'
}
// hostnames: ['cenk.kilic.dev', 'sync.kilic.dev']
// → Creates proxied A/CNAME records for each hostname → loki.kilic.dev
```

**2. Cloudflare direct (grey cloud):** For services that need direct DNS without Cloudflare proxy (e.g., S3/MinIO where TLS must pass through, or wildcard records on free plans). Same label, but **no** `cloudflare-proxied` annotation.

```typescript
// On TLSRoute — DNS record created automatically, but NOT proxied
labels: {
  'provider.kilic.dev/external-dns-cloudflare': 'true'
}
// annotations: {}  ← no cloudflare-proxied annotation
// hostnames: ['s3.kilic.dev', '*.s3.kilic.dev', 'up.kilic.dev']
// → Creates un-proxied CNAME records → loki.kilic.dev
```

**3. Cloudflare CNAME (explicit DNSEndpoint):** For TCP services that can't use Cloudflare proxy. Create an explicit DNSEndpoint CRD with a CNAME record.

```typescript
// Explicit DNSEndpoint — for TCP services (SMTP, databases, etc.)
this.gateway.newDNSEndpoint(
  'mailrise',
  {
    labels: { 'provider.kilic.dev/external-dns-cloudflare': 'true' },
    endpoints: [
      {
        dnsName: 'mailrise.kilic.dev',
        recordType: 'CNAME',
        targets: ['loki.kilic.dev']
      }
    ]
  },
  { provider: this.provider }
)
// → Creates un-proxied CNAME: mailrise.kilic.dev → loki.kilic.dev
```

### Wildcard Hostnames and DNS

- **Specific hostnames** on routes create individual DNS records (e.g., `cenk.kilic.dev`, `gitlab.kilic.dev`)
- **Wildcard hostnames** like `*.s3.kilic.dev` create wildcard DNS records — these **must be un-proxied** (Cloudflare free plan doesn't proxy wildcards)
- **Internal wildcards** like `*.rubik.int.kilic.dev` on the INTERNAL gateway have **no external-dns labels** on the route — internal DNS for these is handled via separate OPNSense DNSEndpoints

### OPNSense DNS Patterns

**1. L2 Announcement records:** Register target cluster gateway IPs in OPNSense DNS. These enable the LB cluster to resolve target cluster gateways by FQDN.

```typescript
this.gateway.newDNSEndpoint(
  'cluster-rubik-opnsense-loki',
  {
    labels: { 'provider.kilic.dev/external-dns-opnsense-loki': 'true' },
    endpoints: [
      {
        dnsName: 'cluster-rubik-gateway-kilic-dev.lb.int.loki.arpa',
        recordTTL: 300,
        recordType: 'A',
        targets: ['192.168.195.16'],
        providerSpecific: [
          {
            name: 'external-dns.alpha.kubernetes.io/opnsense-description',
            value: '[sun] cluster rubik gateway l2 announcement for kilic.dev'
          }
        ]
      },
      // Multiple endpoints in one DNSEndpoint for the same target cluster:
      {
        dnsName: 'cluster-rubik-gateway-monitoring-kilic-dev.lb.int.loki.arpa',
        recordTTL: 300,
        recordType: 'A',
        targets: ['192.168.195.17'],
        providerSpecific: [
          {
            name: 'external-dns.alpha.kubernetes.io/opnsense-description',
            value: '[sun] cluster rubik gateway l2 announcement for monitoring.kilic.dev'
          }
        ]
      }
    ]
  },
  { provider: this.provider }
)
```

**2. Internal service records:** Register internal service FQDNs pointing to the LB INTERNAL gateway IP. Used for services reachable only within the network. Can target both OPNSense instances for redundancy.

```typescript
this.gateway.newDNSEndpoint(
  'cluster-rubik-opnsense',
  {
    labels: {
      'provider.kilic.dev/external-dns-opnsense-thor': 'true',  // both instances
      'provider.kilic.dev/external-dns-opnsense-loki': 'true'
    },
    endpoints: [
      {
        dnsName: 'keel.rubik.int.kilic.dev',
        recordTTL: 300,
        recordType: 'A',
        targets: ['192.168.195.3'],  // INTERNAL gateway IP via readTargets()
        providerSpecific: [
          {
            name: 'external-dns.alpha.kubernetes.io/opnsense-description',
            value: '[sun] cluster rubik proxied service'
          }
        ]
      }
    ]
  },
  { provider: this.provider }
)
```

**OPNSense description convention:** Always include `providerSpecific` with `external-dns.alpha.kubernetes.io/opnsense-description` for human-readable context. Format: `[<lb-cluster>] <purpose>`.

### Gateway ↔ DNS Decision Matrix

| Traffic Type | Gateway | DNS Mechanism | Provider Labels on Route | Annotations on Route | Separate DNSEndpoint? |
|-------------|---------|--------------|--------------------------|---------------------|-----------------------|
| External, proxied | `DEFAULT` | Route-based (auto) | `external-dns-cloudflare` | `cloudflare-proxied: "true"` | No |
| External, direct | `DEFAULT` | Route-based (auto) | `external-dns-cloudflare` | None | No |
| External, TCP | `DEFAULT` | Explicit DNSEndpoint | None on route | None | Yes (CNAME → `loki.kilic.dev`) |
| Internal service | `INTERNAL` | Explicit DNSEndpoint | None on route | None | Yes (A record, OPNSense loki/thor) |
| L2 announcement | N/A | Explicit DNSEndpoint | N/A | N/A | Yes (A record, OPNSense loki) |

### FQDN Naming Conventions

| Pattern | Format | Example | Used For |
|---------|--------|---------|----------|
| L2 announcement | `cluster-<cluster>-gateway-<domain-slug>.lb.int.loki.arpa` | `cluster-rubik-gateway-kilic-dev.lb.int.loki.arpa` | Registering target cluster gateway IPs in OPNSense DNS |
| Internal service | `<service>.<cluster>.int.kilic.dev` or `*.<cluster>.int.kilic.dev` | `keel.rubik.int.kilic.dev` | Internal service discovery via OPNSense |
| VM backend | `<hostname>.loki.arpa` | `gitlab.loki.arpa` | Backend FQDN for VM targets (pre-existing DNS, not managed here) |
| External domain | Direct domain name | `gitlab.kilic.dev`, `s3.kilic.dev` | Public-facing hostnames via Cloudflare |
| WAN endpoint | `loki.kilic.dev` | `loki.kilic.dev` | Gateway target for all Cloudflare DNS — resolves to public IP |

## L2 Announcements

Target cluster gateways have L2-announced IPs (via Cilium LB-IPAM). The LB cluster needs to know these IPs to route traffic. The flow:

1. Target cluster gateway has a Cilium LB-IPAM IP (e.g., rubik kilic.dev gateway = `192.168.195.16`)
2. LB cluster creates a **DNSEndpoint** registering that IP as `cluster-<target>-gateway-<slug>.lb.int.loki.arpa` in OPNSense (loki)
3. LB cluster creates an **Envoy Backend** pointing to that FQDN
4. LB cluster creates **TLSRoute/HTTPRoute/TCPRoute** referencing the Backend

The LB cluster's own gateways also have L2-announced IPs registered in OPNSense (handled by `gateway.service.ts`, not by workload services):
- `cluster-<lb>-gateway-default.lb.int.loki.arpa` → DEFAULT gateway IP
- `cluster-<lb>-gateway-internal.lb.int.loki.arpa` → INTERNAL gateway IP

## Cross-Cluster Routing Pattern (`cluster-<target>`)

```typescript
import {
  ArgoCDService,
  EnvoyGatewayService,
  GatewayAPIService,
  GatewayListenerProtocol,
  InjectArgoCDService,
  InjectEnvoyGatewayService,
  InjectGatewayAPIService,
  InjectStandardsService,
  InjectWorkloadsService,
  K8sLabels,
  K8sMatchExpressions,
  K8sProvider,
  StandardsService,
  Workload,
  WorkloadsService
} from '@kilic.dev/pulumi-k8s'
import { Inject, Injectable, OnModuleInit } from '@nestjs/common'

import { ClusterGateways } from '@cluster/cluster.constants'
import { ClusterGatewayService } from '@cluster/gateway.service'
import { ARGOCD_CLUSTER, ARGOCD_NAMESPACE_SETUP, ARGOCD_NAMESPACE_TRANSFORMS, ARGOCD_REPOSITORY, ArgoCDProjects, ENVOY_GATEWAY_POLICY_LABEL_ENABLED, EnvoyGatewayPolicyLabels } from '@constants'
import { ARGOCD_APPLICATION_PROVIDER, ARGOCD_NAMESPACE_PROVIDER } from '@root/module.constants'

@Injectable()
export class ClusterTargetService implements OnModuleInit {
  constructor(
    @InjectStandardsService() private readonly standards: StandardsService,
    @InjectWorkloadsService() private readonly workloads: WorkloadsService,
    @InjectArgoCDService() private readonly argocd: ArgoCDService,
    @InjectGatewayAPIService() private readonly gateway: GatewayAPIService,
    @InjectEnvoyGatewayService() private readonly envoy: EnvoyGatewayService,
    @Inject(ClusterGatewayService) private readonly clusterGateway: ClusterGatewayService,
    @Inject(ARGOCD_APPLICATION_PROVIDER) private readonly provider: K8sProvider,
    @Inject(ARGOCD_NAMESPACE_PROVIDER) private readonly ns: K8sProvider
  ) {}

  public async onModuleInit(): Promise<void> {
    const workload = this.workloads.create({
      name: 'cluster-<target>'
    })

    await this.deploy(workload)
  }

  public async deploy(workload: Workload): Promise<void> {
    this.argocd.newNamespace(/* ... */)
    this.argocd.newApplication(/* ... using ARGOCD_REPOSITORY */)

    // BackendTrafficPolicy for the workload
    this.clusterGateway.reflect(workload)

    // L2 announcement DNSEndpoint (register target cluster gateway IP in OPNSense)
    this.gateway.newDNSEndpoint(
      '<target>-gateway-<domain-slug>-l2-announcement',
      {
        labels: {
          'provider.kilic.dev/external-dns-opnsense-loki': 'true'
        },
        endpoints: [
          {
            dnsName: 'cluster-<target>-gateway-<domain-slug>.lb.int.loki.arpa',
            recordTTL: 300,
            recordType: 'A',
            targets: ['<gateway-ip>'],
            providerSpecific: [
              {
                name: 'external-dns.alpha.kubernetes.io/opnsense-description',
                value: '[<lb-cluster>] cluster <target> gateway l2 announcement for <domain>'
              }
            ]
          }
        ]
      },
      { provider: this.provider }
    )

    // Backend pointing to target cluster gateway FQDN
    const backend = this.envoy.newBackend(
      '<target>-gateway',
      {
        endpoints: [{ fqdn: { hostname: 'cluster-<target>-gateway-<domain-slug>.lb.int.loki.arpa' } }],
        appProtocols: ['gateway.envoyproxy.io/h2c']
      },
      { provider: this.provider }
    )

    // Get gateway references
    const defaultGateway = this.clusterGateway.reference(ClusterGateways.DEFAULT)
    const internalGateway = this.clusterGateway.reference(ClusterGateways.INTERNAL)

    // External TLSRoute — Cloudflare-proxied (for HTTP(S) services)
    this.gateway.newTLSRoute(
      '<target>-external',
      {
        labels: {
          ...ENVOY_GATEWAY_POLICY_LABEL_ENABLED,
          [EnvoyGatewayPolicyLabels.BACKEND_TRAFFIC_POLICY_PROXY_PROTOCOL_V2]: 'true',
          'provider.kilic.dev/external-dns-cloudflare': 'true'
        },
        annotations: {
          'external-dns.alpha.kubernetes.io/cloudflare-proxied': 'true'
        },
        hostnames: ['cenk.kilic.dev', 'sync.kilic.dev'],
        backendRef: backend
      },
      ClusterGateways.DEFAULT,
      { provider: this.provider }
    )

    // External TLSRoute — Cloudflare direct / un-proxied (for S3, wildcards, etc.)
    // No cloudflare-proxied annotation → grey cloud in Cloudflare
    this.gateway.newTLSRoute(
      '<target>-external-direct',
      {
        labels: {
          ...ENVOY_GATEWAY_POLICY_LABEL_ENABLED,
          [EnvoyGatewayPolicyLabels.BACKEND_TRAFFIC_POLICY_PROXY_PROTOCOL_V2]: 'true',
          'provider.kilic.dev/external-dns-cloudflare': 'true'
        },
        hostnames: ['s3.kilic.dev', '*.s3.kilic.dev'],
        backendRef: backend
      },
      ClusterGateways.DEFAULT,
      { provider: this.provider }
    )

    // Internal TLSRoute — NO DNS labels on the route itself
    // Internal DNS is handled via separate OPNSense DNSEndpoints (see DNS Configuration)
    this.gateway.newTLSRoute(
      '<target>-internal',
      {
        labels: {
          ...ENVOY_GATEWAY_POLICY_LABEL_ENABLED,
          [EnvoyGatewayPolicyLabels.BACKEND_TRAFFIC_POLICY_PROXY_PROTOCOL_V2]: 'true'
        },
        hostnames: ['<target>.int.kilic.dev', '*.<target>.int.kilic.dev'],
        backendRef: backend
      },
      ClusterGateways.INTERNAL,
      { provider: this.provider }
    )
  }
}
```

## TCPRoute Pattern (Custom Port)

For TCP services (SMTP, databases, etc.) that need a dedicated port on the gateway:

```typescript
// 1. Add a listener to the gateway for the TCP port
this.clusterGateway.listen(
  ClusterGateways.DEFAULT,  // or INTERNAL
  this.gateway.createGatewayListeners({
    type: GatewayListenerProtocol.TCP,
    name: '<service-name>',
    port: <port>,
    allowedRoutes: {
      namespaces: {
        from: 'Selector',
        selector: {
          matchExpressions: [
            {
              key: K8sLabels.METADATA_NAME,
              operator: K8sMatchExpressions.IN,
              values: [workload.namespace]
            }
          ]
        }
      }
    }
  })
)

// 2. Create Backend with the TCP port
const tcpBackend = this.envoy.newBackend(
  '<service-name>',
  {
    endpoints: [{ fqdn: { hostname: '<target>.lb.int.loki.arpa', port: <port> } }]
  },
  { provider: this.provider }
)

// 3. Create TCPRoute referencing the specific listener section
// sectionName format: tcp-<name>-<port>
this.gateway.newTCPRoute(
  '<service-name>',
  {
    parentRefs: [{ ...defaultGateway, sectionName: 'tcp-<service-name>-<port>' }],
    backendRef: tcpBackend
  },
  { provider: this.provider }
)

// 4. DNS — TCP can't be Cloudflare-proxied, use CNAME to WAN endpoint
this.gateway.newDNSEndpoint(
  '<service-name>',
  {
    labels: { 'provider.kilic.dev/external-dns-cloudflare': 'true' },
    endpoints: [
      {
        dnsName: '<service>.kilic.dev',
        recordType: 'CNAME',
        targets: ['loki.kilic.dev']
      }
    ]
  },
  { provider: this.provider }
)
```

## VM/Host Routing Pattern (`vm-<name>`)

```typescript
// Same imports as cross-cluster pattern, but typically simpler — external-only routing

@Injectable()
export class VmNameService implements OnModuleInit {
  // Same constructor injections

  public async deploy(workload: Workload): Promise<void> {
    this.argocd.newNamespace(/* ... */)
    this.argocd.newApplication(/* ... using ARGOCD_REPOSITORY */)

    this.clusterGateway.reflect(workload)

    // Backend pointing to VM FQDN
    const backend = this.envoy.newBackend(
      '<vm-name>',
      {
        endpoints: [{ fqdn: { hostname: '<vm-name>.loki.arpa' } }]
      },
      { provider: this.provider }
    )

    // External TLSRoute with Cloudflare DNS
    this.gateway.newTLSRoute(
      '<vm-name>',
      {
        labels: {
          ...ENVOY_GATEWAY_POLICY_LABEL_ENABLED,
          'provider.kilic.dev/external-dns-cloudflare': 'true'
        },
        annotations: {
          'external-dns.alpha.kubernetes.io/cloudflare-proxied': 'true'
        },
        hostnames: ['service.kilic.dev', 'other.kilic.dev'],
        backendRef: backend
      },
      ClusterGateways.DEFAULT,
      { provider: this.provider }
    )
  }
}
```

## Direct Routes Pattern (`routes`)

```typescript
// For routes handled directly by the LB cluster (e.g., redirects)
// No Backend needed — uses HTTPRoute instead of TLSRoute

this.gateway.newHTTPRoute(
  'redirect-name',
  {
    labels: {
      ...ENVOY_GATEWAY_POLICY_LABEL_ENABLED,
      'provider.kilic.dev/external-dns-cloudflare': 'true'
    },
    annotations: {
      'external-dns.alpha.kubernetes.io/cloudflare-proxied': 'true'
    },
    hostnames: ['old.kilic.dev'],
    rules: [
      {
        filters: [
          {
            type: 'RequestRedirect',
            requestRedirect: {
              hostname: 'new.kilic.dev',
              statusCode: 301
            }
          }
        ]
      }
    ]
  },
  ClusterGateways.DEFAULT,
  { provider: this.provider }
)
```

## Adding Routes to an Existing Service

When adding a new route to an existing workload service (e.g., adding a new domain to `cluster-rubik`):

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
