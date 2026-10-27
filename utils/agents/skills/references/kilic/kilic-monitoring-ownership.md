# Kilic Monitoring Ownership

Where a dashboard or an alert rule lives, how to find its owner, and how it reaches the central Grafana and the Mimir Ruler. The owner is decided by what the thing describes. Inventories (which dashboards, folders and apps exist where) live in the owning repositories' `CLAUDE.md` and `README.md`, not here.

## Who owns what

| Describes | Dashboards and rules live in |
|---|---|
| The fleet, a cross-cutting concern, or the monitoring stack itself | `cluster/workloads/monitoring-view` (dashboards) and `cluster/workloads/monitoring-ruler` (rules) |
| The core tenant: everything outside Kubernetes | `cluster/workloads/monitoring-core`, dashboards and rules together |
| One workload | that workload's repository, beside the component it describes |
| One system component | its `cluster/charts/chart-<c>` |
| Alertmanager routing and inhibition, datasources, Grafana itself | `cluster/workloads/monitoring-backbone` |

**Split generic from specific.** A dashboard or rule about the software itself (its controller, API, runtime, any install of it) ships with the chart or workload that deploys it. One about our own use of it (the projects, pipelines, routes or config we feed it) ships from the repository that holds that config, in its own folder beside the generic one. The test is where the concept is defined: a panel built on something only our config defines belongs to that config's repository even when the metric comes from the upstream controller. A dashboard mixing both is split along that line, so adjusting our setup never needs a chart release. The split applies only when the halves have different owners: an operator deployed in the same repository solely to run that repository's own config stays one dashboard and one folder with it.

## Finding the owner of an existing dashboard or rule

1. **Dashboard**: read it with `get_dashboard_by_uid` and note its folder; then search the code for the uid (`"uid": "<uid>"`) across the monitoring repositories, workload repositories and charts. The repository holding the JSON is the owner. A folder title alone is not proof: shared folders hold dashboards from many repositories.
2. **Rule**: search the code for `alert: <Name>`. The ruler's rule-group namespace, read per tenant through the alerting read tools, names the Kubernetes namespace and PrometheusRule it was synced from, which points at the Application that deployed it.
3. **Read the owner's `CLAUDE.md` and its existing dashboards or rules** before changing anything. They carry the current inventory, layout, selectors and naming; this reference carries only the method.

## Moving or splitting between owners

- **The generic half keeps the uid; the specific half gets a new one.** Links and alerts that pointed at the dashboard keep working, and only the moved panels need their links repointed.
- **A rule keeps its name and label set.** Add the new copy first and remove the old one last, so Alertmanager deduplicates the overlap instead of dropping the alert. When the copies sync from different Applications, sync the adding one first.
- **A dashboard moving with its uid goes the other way: remove the old owner's CR first.** Deleting a dashboard CR deletes that uid in Grafana, whoever owns it by then, so the new owner's CR must sync after the old one is gone. The dashboard is missing in between.
- **Repoint every link into the moved panels** (`viewPanel` ids, `var-*` names the old dashboard had and the new one does not, alert `dashboard_url`s, landing-page links) in the same change set.
- **State the merge order in every MR description.** A pin to a chart version that is not tagged yet leaves the Application at `Unknown` until a refresh after the tag exists.

## How a dashboard reaches Grafana

Dashboards are `GrafanaDashboard` CRs (`grafana.integreatly.org/v1beta1`) over a ConfigMap holding the JSON (`configMapGenerator` with `disableNameSuffixHash: true`), each naming its folder. Two grafana-operator paths reach the one central Grafana, and they never share an object:

- **The monitoring repositories** run on the central cluster and are served by its own operator through the `monitoring.kilic.dev/grafana: default` instance label.
- **Workload repositories and charts** are served by the per-cluster `grafana-operator-workloads` (`cluster/workloads/monitoring`), which watches only objects labelled `monitoring.kilic.dev/instance: monitoring.kilic.dev` and writes through an external `Grafana` instance authenticated with that cluster's service-account token. Each cluster's account may edit only the folders granted to it in monitoring-backbone; a dashboard pointed at any other folder fails to sync.

Dashboard uids are global: two owners shipping one uid overwrite each other.

## Folders

- **A fixed folder uid exists only where something references the folder from outside**, and is `folder-<path>`. The `folder-` prefix is reserved for folders: Grafana's folder browser overflows its stack when a dashboard shares its folder's uid, so a dashboard uid never starts with `folder-`.
- **Every application gets its own folder**, titled for the product, even with a single dashboard. An application folder carries no `uid`, nests under a top-level folder with `parentFolderUID`, and its dashboards reference it with `folderRef: <folder CR name>`. Titles share one parent, so the same app on two clusters needs distinct titles.
- **Every dashboard CR names a folder**, with `folderRef` (a folder CR in the same Application) or `folderUID` (any folder, including another repository's). One with neither lands in a folder named after the CR's namespace.
- **A `GrafanaFolder` `spec.uid` is immutable**, including set to unset; changing it means deleting the CR and letting ArgoCD recreate it.
- **Changing `parentFolderUID` moves the folder** with its dashboards; renaming the folder CR is a delete and a create, which takes its dashboards with it.
- **Deleting a folder CR deletes the folder in Grafana with every dashboard inside it.** The dashboard CRs keep reporting success until the operator resyncs.
- **A folder delete can hang on its finalizer** when Grafana answers 403 for a folder already gone; clear `metadata.finalizers` on that CR.

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

A workload with no Application of its own in the dashboards' namespace gets a separate monitoring Application.

## Layout in a chart

`templates/dashboards/{folder,dashboard,configmap}.yaml` over `files/dashboards/*.json`, and `templates/rules/prometheusrule.yaml`. Values:

```yaml
dashboards:
  enabled: true
  folder:
    parentUID: <top-level folder uid>
    title: <App>
rules:
  enabled: true
```

`dashboards.folder.parentUID` is `required` when dashboards are enabled and never derived from the cluster name. A chart that always ships under the same parent sets it as its default, so the dashboards arrive with the chart release. A chart whose parent differs per install leaves `enabled: false` and `parentUID: ""` and takes both from its `argocd-system` values. The folder CR name is a fixed literal and the dashboards `folderRef` it.

## How a rule reaches the Ruler

Alloy's `mimir.rules.kubernetes` syncs PrometheusRules from **every namespace** into the cluster's ruler tenant and appends `cluster`, skipping namespaces labelled `monitoring.kilic.dev/tenant: core`; on the central cluster a second component syncs those into the core tenant. A workload or chart rule therefore selects its own scope in `expr` (`cluster="<cluster>", namespace="<ns>"`), aggregates `max by` the object labels, and never sets `cluster` on its output.

## Links

Links between dashboards use `/d/<uid>/<slug>`, which survives folder moves and owner changes, and follow monitoring-view's `README.md` link rules wherever the dashboard lives. A landing page links to every dashboard in its scope, workload-owned ones included, and the two halves of a split link to each other.
