# Loki Label Model

How logs are labelled here, and the one mistake that produces a wrong answer without producing an error. Read this before writing any LogQL, including LogQL embedded in a dashboard link.

## Names match Mimir. Tiers do not.

Metrics and logs use the **same label names** — `namespace`, `pod`, `container`, `node`, `deployment`, `statefulset`, `daemonset`, `cronjob`, `workload`, `workload_type`, `cluster`. Mimir gets them from the Prometheus exporters; Loki's collector renames its OpenTelemetry attributes to match.

What differs is **where a name may be used**. Loki indexes a subset as stream labels; everything else is structured metadata, filtered after the selector.

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

The split is deliberate. Pod, container and node are per-instance dimensions; indexing them would multiply streams against a `max_global_streams_per_user` of 15000 per tenant. Structured metadata costs bytes per line, not streams.

## There is no pod stream label

A pod-scoped query selects the workload and filters the pod:

```logql
{namespace="monitoring", statefulset="loki-write"} | pod="loki-write-1"
```

## `workload_type` is lowercase, and matchers are case-sensitive

Values: `deployment`, `statefulset`, `daemonset`, `cronjob`, `job`, `barepod`.

Matchers are anchored and case-sensitive, so **any value not already lowercase needs an RE2 `(?i)` flag**. That covers every value arriving from Prometheus, which is mixed case: the `workload_type` from `namespace_workload_pod:kube_pod_owner:relabel` is lowercase for built-in kinds but PascalCase for CRD-owned pods (`Cluster`, `RenovateJob`, `CronJob`), and HPA `scaletargetref_kind` and VPA `target_kind` are PascalCase throughout.

```logql
{workload_type=~"(?i)${__data.fields["scaletargetref_kind"]}"}
```

Pass the Prometheus value literally and add the flag. Do not normalise the value.

## A `cluster` matcher inside a selector is redundant

Each Loki datasource holds exactly one cluster, so the uid already decided it. Keep the matcher only when copying a dashboard query that templates on it.

## A label in the listing is not proof anything writes it

`list_loki_label_names` reflects every label present in chunks **within the retention window** (360h), not what is currently ingested. A label that stopped being written days ago still appears until its chunks age out, and it matches only those old chunks.

Confirm recent data carries a name before building on it — select on it with a short lookback and check rows come back.
