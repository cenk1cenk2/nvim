# Kilic Monitoring Ownership

Where a dashboard or an alert rule lives, and how it reaches the central Grafana at `https://monitoring.kilic.dev` (rubik) and the Mimir Ruler. Two owners, decided by what the thing describes.

## Who owns what

| Describes | Dashboards | Alert and recording rules |
|---|---|---|
| The fleet, a cross-cutting concern, or the monitoring stack itself | `cluster/workloads/monitoring-view`, rubik, namespace `monitoring-backbone` | `cluster/workloads/monitoring-ruler`, every cluster, namespace `monitoring` |
| One workload | that workload's repository, beside the component it describes | the same repository, beside its dashboards |
| One system component | its `cluster/charts/chart-<c>`, enabled from `cluster/argocd-system` values | the same chart |

**Split generic from specific.** A dashboard or rule about the software itself — its controller, API, runtime, any install of it — ships with the chart or workload that deploys it. One about our own use of it — the projects, pipelines, routes or config we feed it — ships from the repository that holds that config, in its own folder beside the generic one. The test is where the concept is defined: a panel built on something only our config defines (kargo-root's report stages and verdicts, the agent-job metrics its WorkflowTemplate emits) belongs to that config's repository even when the metric comes from the upstream controller. For Kargo, the controller dashboards are `chart-kargo`'s under `Kargo`, and verification, reporting and agent jobs are `kargo-root`'s under `Kargo Root`. A dashboard mixing both is split along that line, so adjusting our setup never needs a chart release.

Moving something between owners keeps the dashboard `uid` and the alert's name and label set unchanged, so `/d/<uid>` links survive and Alertmanager deduplicates the overlap. Add the new copy first and remove the old one last.

## How a workload-owned dashboard reaches Grafana

Every cluster runs `grafana-operator-workloads` (`cluster/workloads/monitoring`, `.deploy/<cluster>/grafana-operator-workloads/`), watching only objects labelled `monitoring.kilic.dev/instance: monitoring.kilic.dev`. The `Grafana` CR `grafana` beside it (`.deploy/base/grafana/`) is an external instance pointing at `https://monitoring.kilic.dev`, authenticated with that cluster's token from Vault (ExternalSecret `grafana-token`, keyed per cluster in `.deploy/<cluster>/grafana/`).

The token belongs to the Grafana service account `cluster-<cluster>` (role Viewer), created in `cluster/workloads/monitoring-backbone` `.deploy/rubik/grafana/`. Every cluster's account holds Edit on `Workloads`, and overseer's also on `Operations`; a dashboard pointed at any other folder fails to sync. `Workloads` is shared, so a cluster can write over another cluster's app there: dashboard uids are global, and two owners shipping one uid overwrite each other.

rubik's own `grafana-operator` (namespace `monitoring-system`) serves `monitoring-view` and `monitoring-backbone` through the label `monitoring.kilic.dev/grafana: default`. The two operators never share an object.

## Folder tree

```
Workloads                      uid folder-workloads          monitoring-view
  <App>                        generated uid                 the owning repository
Operations                     uid folder-operations         monitoring-view
  <App>                        generated uid                 overseer platform repos and charts
Kubernetes, Core, Fleet, ...   uid folder-<path>             monitoring-view
```

- **Every application gets its own folder**, titled for the product (`AgentGateway`, `GitLab Runner`, `Renovate`), even with a single dashboard. Titles share one parent, so the same app on two clusters needs distinct titles.
- **An application folder carries no `uid`**; its dashboards reference it with `folderRef: <folder CR name>`. `allowCrossNamespaceImport: true` stays on both.
- **A fixed uid exists only where something references the folder from outside**: monitoring-view's `folder-<path>` folders, which applications name as `parentFolderUID`. The `folder-` prefix is load-bearing: Grafana's folder browser overflows its stack when a dashboard inside a folder shares the folder's uid.
- **overseer platform apps nest under `Operations`** (`parentFolderUID: folder-operations`); every other app nests under `Workloads` (`parentFolderUID: folder-workloads`).

## Layout in a workload repository

Two kustomize directories beside the component they describe, each stamping the instance label for everything under it:

```
.deploy/<cluster>/[<component>/]dashboards/
  kustomization.yaml     labels: monitoring.kilic.dev/instance; configMapGenerator per JSON, disableNameSuffixHash: true
  folder.yaml            GrafanaFolder, parentFolderUID, title, no uid
  <name>.json            the dashboard
  <name>.yaml            GrafanaDashboard, folderRef, configMapRef
.deploy/<cluster>/[<component>/]rules/
  kustomization.yaml     labels: monitoring.kilic.dev/instance
  <name>.yaml            PrometheusRule
```

A workload with no Application of its own in the dashboards' namespace gets one: `rustfs` ships its monitoring as the separate `rubik-rustfs-monitoring` Application.

## Layout in a chart

`templates/dashboards/{folder,dashboard,configmap}.yaml` over `files/dashboards/*.json`, and `templates/rules/prometheusrule.yaml`. Values:

```yaml
dashboards:
  enabled: false
  folder:
    parentUID: ""       # required when enabled; no default from the cluster name
    title: <App>
rules:
  enabled: true
```

The folder CR name is a fixed literal and the dashboards `folderRef` it. `argocd-system` `base/<c>/values.yaml` sets `dashboards.enabled` and `dashboards.folder.parentUID`.

## How a rule reaches the Ruler

Alloy's `mimir.rules.kubernetes` syncs PrometheusRules from **every namespace** into the cluster's ruler tenant every 5 minutes and appends `cluster`, skipping those labelled `monitoring.kilic.dev/tenant: core`, which belong to the core tenant. A workload or chart rule therefore selects its own scope in `expr` (`cluster="<cluster>", namespace="<ns>"`), aggregates `max by` the object labels, and never sets `cluster` on its output.

## Changing a folder or dashboard in place

- **A `GrafanaFolder` `spec.uid` is immutable**, including set to unset. Changing it means deleting the CR and letting Argo recreate it.
- **Deleting a folder CR deletes the folder in Grafana with every dashboard inside it.** The dashboard CRs keep reporting success until the operator resyncs (every 10 minutes, or at once after a restart of that cluster's operator).
- **Deleting a dashboard CR deletes that uid in Grafana**, whichever CR now owns it. Delete the old owner's CR before the new one syncs, never after.
- **A folder delete can hang on its finalizer** when Grafana answers 403 for a folder already gone; clear `metadata.finalizers` on that CR.
