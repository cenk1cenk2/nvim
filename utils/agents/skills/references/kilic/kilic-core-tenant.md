# Core Tenant: kilic

How the `core` tenant labels its data, and the selector and rule shapes that follow. `core` is the estate outside Kubernetes; its datasources are `mimir-core`, `loki-core` and `alertmanager-core`, and the federated `mimir` and `loki` exclude it. `cluster/workloads/monitoring-core` owns its dashboards, rules and API exporters. **Its `CLAUDE.md` holds the current inventory**: which exporters exist, their `job` values, the host classes and their dashboards. Read it, and the neighbouring rules and panels, before writing a selector.

## Label contract

- **Every series carries `cluster="core"`**, so a selector inside `mimir-core` never needs it, while a rule carries it so the tenant scoping is explicit.
- **`job` is `<namespace>/<exporter>`**, where the namespace is the source's group (an inventory group for pushed host exporters, the scrape namespace for API exporters). Some sources push with no namespace and get the bare exporter name.
- **Entities are told apart by a target label** (`node` for hosts, a per-exporter label for API targets), never by `instance` or `namespace`. Rules and panels select on `job` and the target label only, so moving where something is scraped changes no rule or panel.

## Selector mechanisms

- **Optional namespace prefix for pushed exporters**: `job=~"(.+/)?<exporter>"` matches the exporter whatever group it ships under, including the bare form.
- **Exact matcher for single-source exporters**: an API exporter scraped from one place gets `job="<namespace>/<exporter>"`.
- **Exclude host classes that have their own dashboards**: a generic host page adds `job!~"(<class>|<class>)/.+"` beside the exporter matcher, and the class's own pages select `job=~"<class>/.+"`. The same split decides where alerts link, per `grafana-kilic-alerts`.
- **Collector keep-lists**: data scraped through the tenant's own collector is filtered to the metrics its rules and dashboards use, so a new panel or rule on another metric adds it to the keep-list in the same change. Pushed host data bypasses that collector.

## Pushed metrics: telling absence apart

A host pushes every exporter through one local collector, so a missing series has two causes, and the rules tell them apart:

- **Target missing** (`<Prefix>TargetMissing`): one exporter's `up` was present over a long lookback, is absent over a short one, while the tenant as a whole still ships. Keyed by `(cluster, job, <target label>)`:

  ```promql
  max by (cluster, job, node) (present_over_time(up{cluster="core", job=~"(.+/)?<exporter>"}[30d]))
  and on (cluster)
  max by (cluster) (present_over_time(up{cluster="core"}[5m]))
  unless on (cluster, job, node)
  max by (cluster, job, node) (present_over_time(up{cluster="core", job=~"(.+/)?<exporter>"}[10m]))
  ```

- **Collector missing**: the same shape over every exporter of a host, keyed `(cluster, node)`. It pages once when the host or its collector is down, and inhibits the per-exporter target-missing alerts.
- **Exporter down** (`<Prefix>ExporterDown`): `up == 0`; the collector reaches the host but the exporter does not answer.
- **The tenant-alive guard** (`and on (cluster) ... present_over_time(up{cluster="core"}[5m])`) stops a tenant-wide ingestion outage from firing every target-missing alert at once.
- **Sparse gauges are read with `last_over_time(...[<long window>])`.** Anything pushed once per run, such as a timer job's last outcome, is absent between runs, so an instant selector sees nothing.

## Container runtime series

- **Infra containers are excluded** by their image (pod infra and service containers run the pause image), or they double every count.
- **A restart is a new container id**, so restarts are counted as distinct series per container name over the window, minus one.
- **State gauges are aggregated to the container** with `max by (<target label>, <unit>, name)` before comparing.

## Logs

`loki-core` holds container logs from the hosts, with its own stream labels (`node`, the unit and the container's `service_name` among them), not the Kubernetes set: label tiers per `loki-label-model`. Only the containers a host lists for shipping are collected, so a missing container is a collection gap, not a broken query. Logs are read in Explore through drilldown links, never on a log dashboard.

## Dashboards

Core dashboards use the `datasource` variable `/^mimir(-core)?$/` selected `mimir-core`, no `cluster` variable, and a multi-select target variable defaulting to All. Alerts link to them with that variable (`var-node={{ $labels.node }}`).
