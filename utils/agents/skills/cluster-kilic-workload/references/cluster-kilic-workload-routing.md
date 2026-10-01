# Workload Gateway API Routing

HTTPRoute, robots.txt filter and GRPCRoute templates. Read when the workload is exposed through the cluster gateway.

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
