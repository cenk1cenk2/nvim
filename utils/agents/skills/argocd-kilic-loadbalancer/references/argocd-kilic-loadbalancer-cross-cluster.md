# Cross-Cluster Routing Pattern (operator-lb relay)

How traffic reaches a target Kubernetes cluster through a load balancer cluster. Cross-cluster exposure is the operator-lb relay: the target cluster and its workloads declare everything in their own repos, and the operator on the LB cluster copies it in.

## Moving Parts

| Piece | Lives in | Declares |
|---|---|---|
| LoadBalancers, Upstreams, Upstream DNSEndpoints | `cluster/<c>/argocd-<c>/src/cluster/operator-lb.service.ts` | Which LB gateways the cluster relays through, and which of its own gateways those LBs forward to |
| Relay ListenerSets | `cluster/<c>/argocd-<c>/src/cluster/relay.service.ts` (`ClusterRelayService`), plus the per-workload ListenerSets in `src/workloads/<w>/<w>.service.ts` | The hostnames and ports claimed on the LB gateway |
| Routes and their DNSEndpoints | `cluster/workloads/<w>/.deploy/<cluster>/` (`lb-*.yaml`) | TLSRoutes, TCPRoutes and UDPRoutes parented to a relay ListenerSet, and the Cloudflare/OPNsense records for their hostnames |
| Operator | [`cluster/operators/operator-lb`](https://gitlab.kilic.dev/cluster/operators/operator-lb) | `charts/chart` installs it on the LB cluster, `charts/target` per downstream; its `CLAUDE.md` is the full manual |
| LB cluster | `cluster/<lb>/argocd-<lb>/src/cluster/operator-lb.service.ts` | One `lb-<target>` namespace per downstream, where the copies land |

LB clusters are sun (loki region) and moon (thor region). Each keeps its own gateways, its `vm-<name>` and `routes` workloads; target-cluster routes are never authored in the LB cluster repo.

## Flow

1. The target cluster declares a **LoadBalancer** per LB gateway it relays through (`lb.kilic.dev/v1alpha1`, `clusterRef` to the LB cluster profile, `gatewayRef` to the LB gateway).
2. It declares an **Upstream** per own gateway (`spec.fqdn`) and a **DNSEndpoint** for that FQDN, labelled `clusters.lb.kilic.dev/<lb>` and `provider.kilic.dev/external-dns-opnsense-loki`, annotated `lb.kilic.dev/targets-from` with the gateway whose address it resolves to.
3. Relay **ListenerSets** (GatewayAPI) parent to the LB gateway and carry `lb.kilic.dev/upstream: lb.kilic.dev/v1alpha1/Upstream/<namespace>/<upstream>` - TLS listeners by hostname, TCP/UDP listeners by port.
4. Workloads author **TLSRoutes/TCPRoutes/UDPRoutes** parented to the relay ListenerSet, with a `backendRef` to the Upstream (the operator's webhook defaults a missing one from `lb.kilic.dev/upstream` and rejects hostname and port collisions on the LB gateway), plus DNSEndpoints labelled `clusters.lb.kilic.dev/<lb>`.
5. operator-lb on the LB cluster copies the ListenerSets, routes and DNSEndpoints into `lb-<target>` and owns the Envoy Backend side: one Backend per Upstream and port.

Traffic: client -> LB gateway -> relayed route in `lb-<target>` -> Envoy Backend -> Upstream FQDN (target gateway) -> in-cluster route -> Service.

## rubik Example

`argocd-rubik/src/cluster/cluster.constants.ts` names the pieces:

- LoadBalancers `lb-sun-default` and `lb-sun-internal`, against sun's `cluster-system/default` and `cluster-system/internal` gateways
- Upstreams `kilic-dev` (FQDN `cluster-rubik-gateway-kilic-dev.lb.int.loki.arpa`) and `monitoring-int-kilic-dev` (FQDN `cluster-rubik-gateway-monitoring-kilic-dev.lb.int.loki.arpa`)

`argocd-sun/src/cluster/operator-lb.service.ts` creates the `lb-rubik` namespace, labelled for sun's default and internal gateways.

## Code Entry Points

### `relay.service.ts`

`ClusterRelayService` holds one entry per LoadBalancer - labels, the `lb.kilic.dev/upstream` annotation, listeners and the ListenerSet reference - and emits the cluster-level relay ListenerSets with their TLSRoutes (for rubik, `lb-sun-internal` with the `CLUSTER_INTERNAL` hostname and its wildcard, routed to the `kilic-dev` Upstream on 443). Workload services use it through:

- `relay.label(ClusterLoadBalancers.SUN_DEFAULT)` - namespace labels `gateways.lb.kilic.dev/<lb>: "true"` that let the namespace attach to the relay
- `relay.read(ClusterLoadBalancers.SUN_DEFAULT)` - the labels and annotations to stamp on a per-workload relay ListenerSet
- `relay.reference(...)` - the GatewayAPI reference of the relay ListenerSet

A workload adding ports or hostnames declares its own relay ListenerSet in its namespace, from `src/workloads/<w>/<w>.service.ts`:

```typescript
const lb = this.relay.read(ClusterLoadBalancers.SUN_DEFAULT)

this.gateway.newListenerSet(
  workload.resource(ClusterLoadBalancers.SUN_DEFAULT),
  {
    metadata: {
      name: ClusterLoadBalancers.SUN_DEFAULT,
      namespace: workload.namespace,
      labels: lb.labels,
      annotations: lb.annotations
    },
    spec: {
      parentRef: {
        name: lb.reference.name,
        namespace: lb.reference.namespace
      },
      listeners: [
        {
          type: GatewayListenerProtocol.TCP,
          name: 'smtp',
          port: 25,
          allowedRoutes: { namespaces: { from: 'Same' } }
        }
      ]
    }
  },
  { provider: this.ns }
)
```

### `operator-lb.service.ts`

Declares the LoadBalancer and Upstream custom resources and the Upstream DNSEndpoints under the `operator-lb` workload. A new target gateway (new domain) means a new Upstream, its FQDN `cluster-<target>-gateway-<domain-slug>.lb.int.loki.arpa`, and a DNSEndpoint whose `lb.kilic.dev/targets-from` points at that gateway; a new LB gateway means a new LoadBalancer.

## Workload Repo Side

Routes live next to the workload's manifests, in `cluster/workloads/<w>/.deploy/<cluster>/`:

```yaml
---
apiVersion: gateway.networking.k8s.io/v1
kind: TLSRoute
metadata:
  name: lb-moon-default
spec:
  hostnames:
    - atuin.kilic.dev
  parentRefs:
    - group: gateway.networking.k8s.io
      kind: ListenerSet
      name: lb-moon-default
  rules:
    - backendRefs:
        - group: lb.kilic.dev
          kind: Upstream
          namespace: cluster-system
          name: kilic-dev
          port: 443
          weight: 1
```

TCP and UDP routes add `sectionName` for the listener. DNS for the hostname is a DNSEndpoint in the same directory carrying `clusters.lb.kilic.dev/<lb>: "true"` and the provider label (Cloudflare for external, OPNsense for internal) per `argocd-kilic-loadbalancer-dns`:

```yaml
---
apiVersion: externaldns.k8s.io/v1alpha1
kind: DNSEndpoint
metadata:
  name: teamspeak3
  labels:
    clusters.lb.kilic.dev/sun: "true"
    provider.kilic.dev/external-dns-cloudflare: "true"
spec:
  endpoints:
    - dnsName: ts3.kilic.dev
      recordType: CNAME
      targets:
        - loki.kilic.dev
```
