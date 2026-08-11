# Loki Label Model

How logs are labelled here, and the one mistake that produces a wrong answer without producing an error. Read this before writing any LogQL, including LogQL embedded in a dashboard link.

## Names match Mimir. Tiers do not. Values mostly do.

Metrics and logs use the **same label names** — `namespace`, `pod`, `container`, `node`, `deployment`, `statefulset`, `daemonset`, `cronjob`, `workload`, `workload_type`, `cluster`. Mimir gets them from the Prometheus exporters; Loki's collector renames its OpenTelemetry attributes to match.

Two things still differ, and both bite silently:

1. **Where a name may be used.** Loki indexes a subset as stream labels; everything else is structured metadata, filtered after the selector.
2. **What `workload_type` can contain.** Loki knows only built-in Kubernetes kinds; Mimir also knows custom resources. See the value table below.

**Stream labels — the only things allowed inside `{}`:**

`cluster`, `namespace`, `workload_type`, `deployment`, `statefulset`, `daemonset`, `cronjob`, `job_name`, `service_name`, `__stream_shard__`

**Structured metadata — filtered after the selector with `|`:**

`pod`, `container`, `node`, `workload`, `container_restart_count`, `detected_level`, `log_iostream`, `tenant`, `observed_timestamp`

## The silent failure

Correct:

```logql
{namespace="monitoring", deployment="mimir-ruler"} | container="ruler" | detected_level="error"
```

Wrong, and **returns an empty result rather than an error**:

```logql
{namespace="monitoring", container="ruler"}
```

An empty result is indistinguishable from "there are no logs", which is why this mistake survives repeatedly. **Treat an empty Loki result as a query bug until proven otherwise** — check every name in the selector against the stream-label list, then confirm the stream exists by selecting on namespace alone before narrowing.

## Why pod and container are not indexed

Not an oversight, and not because they are sometimes missing. **Stream count accumulates over the retention window, not as a snapshot** — a stream exists as long as it has chunks, so 360h of identities are all live at once against a `max_global_streams_per_user` of 15000 per tenant.

Pod names are the most churning identifier in Kubernetes: every rollout mints a new replicaset hash and every Job run mints a whole new name. Indexing `pod` would add streams permanently on each deploy, for fifteen days each. Structured metadata costs bytes per line instead, which is bounded.

**`job_name` is the exception already in the index**, and Job names commonly carry timestamps or hashes, so it is the one stream label with unbounded value churn. It is the likeliest route to the ceiling in a Job-heavy namespace, and worth watching there.

## Selecting a pod: namespace plus the pipeline

There is no `pod` stream label, so a pod-scoped query needs a stream label in the braces and the pod after the pipe. `namespace` is always present and always cheap, which makes this the standard shape rather than a workaround:

```logql
{namespace="monitoring", statefulset="loki-write"} | pod="loki-write-1"
{namespace="sourcebot"} | pod="sourcebot-db-8" | container="postgres"
```

`{pod="loki-write-1"}` alone returns nothing, silently.

**`namespace`, `pod` and `container` agree exactly between Mimir and Loki**, including for pods where `workload_type` does not. That makes them the reliable cross-side path when a correlation has to hold.

## `workload_type` — lowercase, and narrower than Mimir's

Loki values: `deployment`, `statefulset`, `daemonset`, `cronjob`, `job`, `barepod`.

`barepod` means **no controller owner that `k8sattributes` recognises**. The collector sets the type from the pod first, then overwrites it if a Deployment, StatefulSet, DaemonSet, Job or CronJob owner turns up; whatever survives is `barepod`.

**Mimir knows more kinds than Loki does**, because kube-state-metrics resolves custom resources while `k8sattributes` resolves only built-in ones:

| Side | Values |
|---|---|
| Mimir | `deployment`, `statefulset`, `daemonset`, `job`, `CronJob`, `Cluster`, `RenovateJob`, `HelmChart`, `barepod`, `staticpod` |
| Loki | `deployment`, `statefulset`, `daemonset`, `job`, `cronjob`, `barepod` |

So a CloudNativePG pod is `Cluster` in Mimir and **`barepod`** in Loki. Every CRD-owned pod collapses to `barepod`, and `staticpod` has no Loki equivalent at all.

**A drilldown built from a CRD row matches nothing.** A Prometheus row carrying `workload_type="Cluster"` produces `{workload_type=~"(?i)Cluster"}`, which returns zero rows in Loki — and `(?i)` does not rescue it, because the value genuinely is not there. **Drill down on `namespace` plus the `pod` or `workload` field instead** whenever the row's kind is a custom resource.

### Case sensitivity

Matchers are anchored and case-sensitive, so **any value not already lowercase needs an RE2 `(?i)` flag**. Mimir is mixed case — lowercase for built-in kinds, PascalCase for CRD-owned pods — and HPA `scaletargetref_kind` and VPA `target_kind` are PascalCase throughout.

```logql
{workload_type=~"(?i)${__data.fields["scaletargetref_kind"]}"}
```

Pass the Prometheus value literally and add the flag. Do not normalise it.

## A `cluster` matcher inside a selector is redundant

Each Loki datasource holds exactly one cluster, so the uid already decided it. Keep the matcher only when copying a dashboard query that templates on it.

## A label in the listing is not proof anything writes it

`list_loki_label_names` reflects every label present in chunks **within the retention window** (360h), not what is currently ingested. A label that stopped being written days ago still appears until its chunks age out, and it matches only those old chunks.

Confirm recent data carries a name before building on it — select on it with a short lookback and check rows come back.
