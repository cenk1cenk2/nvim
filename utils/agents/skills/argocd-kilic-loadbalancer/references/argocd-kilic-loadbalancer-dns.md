# LB Cluster DNS Patterns

DNS providers, Cloudflare and OPNSense record patterns, and FQDN naming for routing workloads in a load balancer cluster. Read it when a route or DNSEndpoint needs DNS labels, records, or FQDNs.

## DNS Providers

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

## Cloudflare DNS Patterns

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

## Wildcard Hostnames and DNS

- **Specific hostnames** on routes create individual DNS records (e.g., `cenk.kilic.dev`, `gitlab.kilic.dev`)
- **Wildcard hostnames** like `*.s3.kilic.dev` create wildcard DNS records — these **must be un-proxied** (Cloudflare free plan doesn't proxy wildcards)
- **Internal wildcards** like `*.rubik.int.kilic.dev` on the INTERNAL gateway have **no external-dns labels** on the route — internal DNS for these is handled via separate OPNSense DNSEndpoints

## OPNSense DNS Patterns

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
        dnsName: 'grafana.rubik.int.kilic.dev',
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

## FQDN Naming Conventions

| Pattern | Format | Example | Used For |
|---------|--------|---------|----------|
| L2 announcement | `cluster-<cluster>-gateway-<domain-slug>.lb.int.loki.arpa` | `cluster-rubik-gateway-kilic-dev.lb.int.loki.arpa` | Registering target cluster gateway IPs in OPNSense DNS |
| Internal service | `<service>.<cluster>.int.kilic.dev` or `*.<cluster>.int.kilic.dev` | `grafana.rubik.int.kilic.dev` | Internal service discovery via OPNSense |
| VM backend | `<hostname>.loki.arpa` | `gitlab.loki.arpa` | Backend FQDN for VM targets (pre-existing DNS, not managed here) |
| External domain | Direct domain name | `gitlab.kilic.dev`, `s3.kilic.dev` | Public-facing hostnames via Cloudflare |
| WAN endpoint | `loki.kilic.dev` | `loki.kilic.dev` | Gateway target for all Cloudflare DNS — resolves to public IP |
