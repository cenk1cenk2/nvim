# Rightsize Charts Cross-Cluster

Sizing for `cluster/charts/*` repositories. A chart repository deploys the same helm chart to several clusters at once through ArgoCD ApplicationSets, so a chart is sized by sampling every cluster and taking the maximum. Ownership and spread come from ArgoCD per `kilic-workload-resolution`; this file carries only the arithmetic that differs.

Sample each cluster through `mimir-<cluster>`, or run each query once on the federated `mimir` with `cluster` added to its `by (...)` — the same data in one call, covering every Kubernetes cluster and excluding `core`, which runs no charts. Confirm the live set with `grafana-kilic__list_datasources(type="prometheus")` before sampling; it returns `mimir` and `mimir-core` alongside the per-cluster uids.

## Check for upstream defaults first

Before adding a `resources:` block to a chart wrapper's `values.yaml`, read the upstream chart's own default values. Several charts, envoy-gateway and cert-manager among them, already ship generous defaults, and an override that restates them adds drift for nothing. Add an override only when the upstream chart sets `resources: {}`, when its defaults are too low for this estate's scale, or when they are high enough to waste capacity.

## Sampling

1. Take the namespace from the Application's `destination.namespace`.
2. Identify the containers with `count by (container) (container_cpu_usage_seconds_total{namespace="<ns>", container!="", container!="POD"})` on any one cluster's Mimir.
3. Sample every cluster's Mimir per the queries in `rightsize-signals`: the time-weighted busiest-pod average for requests, the 7d max for limits, both CPU and memory, broken out `by (cluster, container)` on the federated `mimir`.
4. Take the maximum across clusters for every value.
5. Snap per `rightsize-snap-grids` and open one merge request per chart repository.

## Per-container sizing decision

- `req.cpu` = max(time-weighted average across clusters), snapped UP.
- `lim.cpu` = max(7d max across clusters), snapped UP, floor 100m.
- `req.mem` = max(time-weighted average across clusters), snapped UP.
- `lim.mem` = max(7d max across clusters), snapped UP, floor 64Mi.

Maximums are correct here because a single `targetRevision` pins one chart version for every cluster, so the chart default has to work for the most demanding one. A workload repository is the opposite case: each of its rows reads its own cluster's datasource only, because each `.deploy/<cluster>/` overlay runs on that cluster alone.

## The merge request description says when it lands

A chart values change does nothing on merge. It takes effect once semantic-release cuts a chart version and Kargo moves that version's pin in `argocd-system`, per `kilic-resource-placement`. Every chart sizing merge request description states this in its own line, so a reviewer does not read the merge as the rollout and a post-merge check does not read the unchanged pods as a failed change.

## Skip criteria

A chart that runs no pods on any cluster has nothing to sample and no data-backed sizing decision, so it is skipped. Verify with `count by (namespace, container) (...)` against each cluster's Mimir; zero results everywhere means there is no workload to size. Config-only repositories and CRD wrappers with no operator are the usual cases.

## Chart repository types

| Type | Has pods | Example |
|------|----------|---------|
| Operator (deployment) | Yes | chart-cloudnative-pg, chart-cert-manager |
| DaemonSet | Yes | chart-velero (node-agent), chart-local-path-provisioner |
| Config-only | No | chart-cert-manager-letsencrypt-dns01-cloudflare, chart-velero-cluster-backup |
| CRD wrapper | Depends | chart-csi-driver-smb (daemon), chart-envoy-gateway (operator plus proxy CRD) |
