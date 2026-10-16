# Rightsize Throttling Alert

When a `CPUThrottlingHigh` alert fires on a workload whose limits were already raised, the question is whether that change actually landed on the cluster. The cluster is the source of truth; the repo is not.

## Read the live limits

Query the cluster's Mimir datasource for what is actually running:

```promql
kube_pod_container_resource_limits{namespace="<ns>", container="<name>", resource="cpu"}
kube_pod_container_resource_limits{namespace="<ns>", container="<name>", resource="memory"}
```

CPU comes back in cores, so `0.25` is 250m. Memory comes back in bytes; divide by 1024 twice for Mi. Neither needs GitLab.

## Cross-check the repo only when the live values disagree

Check the ArgoCD sync state with `argocd-kilic__get_application`, then the repo values with `gitlab__get_file_contents` against the detected default branch. When ArgoCD returns a permission error, compare the live limits against the expected post-merge values instead. When GitLab is unreachable, skip repo inspection entirely and rely on the live queries.

## Reading the alert

The alert fires when `container_cpu_cfs_throttled_periods_total / container_cpu_cfs_periods_total` exceeds 25 percent. A figure near 100 percent means the container is throttled almost constantly and needs materially more CPU headroom, not a one-stop bump. Confirm it with the summed throttle figure in `rightsize-signals` before acting: a high figure on a container whose average sits far below its limit is sub-second burst throttling, which stays untouched.

## Why a limit change did not help

1. **ArgoCD has not synced.** Limits differing between pods of the same workload means the rollout is in progress.
2. **The pod has not restarted.** A resource change on a Deployment needs a new ReplicaSet; existing pods keep the old limits until they are replaced.
3. **A StatefulSet rolls one replica at a time**, so one ordinal can show the new limit while another still shows the old. The alert clears once every replica has rolled.
4. **The limit was raised but is still below the 7d max.**
5. **The change targeted the wrong namespace**, which is easy when a component name appears in more than one repo.
6. **The workload is owned by a chart repo, not a workload repo.** For a chart under `cluster/charts/*` that wraps an upstream chart, the `resources:` block goes under the wrapped chart's values key, not in a kustomize overlay. Confirm what is running with `kube_pod_container_resource_limits` first, then locate the owning repo.
