# Rightsize Bursty List

Bursty workloads take no multiplier: the memory limit is the smallest grid stop at or above the 7d max, the same tight rule every workload follows. Bursty means the working set spikes: queries, batch processing, ingestion, model loading. The classification decides how the 7d max is read, not what is added to it: on a bursty workload, confirm the window contains a burst — a compaction, a model load, a search window — before lowering its limit to that max. A quiet week understates the spike, and the limit stays where it is.

## The list

| Workload | Bursty | Notes |
|---|---|---|
| valkey | yes | every instance, including main, cache, paperless and home-assistant. |
| postgres and mariadb | yes | every database, whether CNPG `Cluster`, the `postgresql` chart, or `mariadb-operator`. |
| kafka | yes | any broker pod. |
| mimir-ingester | yes | writes hit memory hard during compaction. |
| mimir-compactor | yes | compaction is a bursty memory user. |
| mimir-distributor | yes | the write path spikes with traffic. |
| mimir-ruler | yes | rule evaluation is bursty. |
| loki-write, loki-backend | yes | write path. |
| loki-read, loki-querier | yes | query path. |
| ollama, open-webui | yes | inference, with model loading as the spike. |
| radarr, sonarr, prowlarr, bazarr | yes | indexer API calls spike during search windows. |
| plex | yes | transcoding spikes. |
| deluge | yes | torrent bursts. |
| homepage | yes | dashboard widgets re-fetch. |
| rustfs cache, warehouse, backup | yes | these do compaction. |
| monitoring alloy, otc-container, ta-container | yes | log collection buffers spike. |
| rustfs main | no | a thin S3 frontend. |
| gose | no | static serving, low variance. |
| teamspeak3 | no | the voice codec is constant-rate. |
| zitadel | no | bounded by request rate. |
| sourcebot | no | code search is I/O bound. |
| gitlab-runner | no | the runner pod dispatches; builds are isolated. |
| monitoring alertmanager, gateway, mimir-proxy | no | static routing. |
| blackbox-exporter, prometheus-exporter | no | trivial. |
| socat | no | trivial. |

## When the workload is not on the list

Default to bursty for anything holding an in-memory data structure (caches, queues, ingesters, compactors), any database, any inference workload, and any media transcoder. Default to non-bursty for thin routers and frontends, exporters, init containers, and constant-rate processors.

A per-issue exception in the Linear issue body wins: a shared sizing matrix is the default and the per-issue document holds deviations.

## Worked example

A postgres container whose 7d window contains a burst, read per `rightsize-signals`: time-weighted busiest-pod average 18m CPU and 240Mi, 7d max 160m CPU and 295Mi working set:

```
requests.cpu    = max(18, 10)    -> snap up to 50m
requests.memory = max(240, 32)   -> snap up to 256Mi
limits.cpu      = max(160, 250)  -> 250m floor
limits.memory   = max(295, 64)   -> in-between stop 384Mi
```

The limit is the 7d max on the grid and nothing more; bursty or not, the arithmetic is the same.
