# Core Tenant: kilic

How the `core` tenant's metrics and logs are labelled, and the query and rule shapes its pushed data needs. `core` is the estate outside Kubernetes: hypervisors, backup servers, routers, NAS and the Ansible-run services. Its datasources are `mimir-core`, `loki-core` and `alertmanager-core`; the federated `mimir` and `loki` exclude it. `cluster/workloads/monitoring-core` owns its dashboards, rules and API exporters, and its `CLAUDE.md` is the operational context.

## Sources and labels

Every series carries `cluster="core"`, so a selector inside `mimir-core` never needs it. Hosts, routers and backup servers are told apart by a target label, never by `instance` or `namespace`:

| Source | `job` | Target label |
|---|---|---|
| Host exporters, pushed by each host's own `otel-collector-metrics` (ansible-playbooks `containers/monitoring`) | `<monitoring.namespace>/<exporter>`: `nas/node-exporter`, `hypervisor/smartctl-exporter`, `nas/podman-exporter`, `<ns>/podman-jobs` | `node` |
| Proxmox VE and Backup Server APIs, scraped in monitoring-core | `hyprvisor/pve-exporter`, `hyprvisor/pbs-exporter` | `node`, `pbs` |
| OPNsense API, scraped in monitoring-core | `network/opnsense-exporter` | `router` |
| Ansible-run services | `ansible/caddy`, `ansible/gitlab`, `ansible/rancher` | `node` |

- **`<monitoring.namespace>` comes from the host's inventory group** (`group_vars/machine.hypervisor` sets `hypervisor`, `group_vars/vm.nas` sets `nas`), so host selectors match the exporter, not the group: `job=~".+/node-exporter"`. The API exporters spell their namespace `hyprvisor`.
- **Every host-exporter series carries `node`** except `target_info`.
- **The Hosts dashboards exclude hypervisors** with `job!~"hypervisor/.+"` beside the exporter matcher; hypervisors have their own Proxmox dashboards.
- **Host data bypasses the monitoring-core collector**, so its keep-list never filters it. A new panel or rule on a `pve_`, `pbs_` or `opnsense_` metric adds that metric to the keep-list in the same change.

## Podman recipes

Podman series carry `node`, `quadlet` (the systemd unit without `.service`) and `name` (the container).

- **Exclude infra containers** with `image!~"localhost/podman-pause:.*"`. Pod infra and Quadlet service containers run that image.
- **Count restarts as distinct container ids per name.** Every restart creates a new container id, so a restart is a new series:

  ```promql
  count by (node, quadlet, name) (
    present_over_time(podman_container_started_seconds{job=~".+/podman-exporter", image!~"localhost/podman-pause:.*"}[1h])
  ) - 1
  ```

- **Running is `podman_container_state == 2`**; aggregate `max by (node, quadlet, name)` first.

## Pushed metrics

A host pushes its exporters' samples through one collector, so absence has two causes, and rules tell them apart:

- **`<Prefix>TargetMissing`**: one exporter's `up` was present in the last `30d`, is absent for `10m`, while the tenant as a whole still ships (`and on (cluster) max by (cluster) (present_over_time(up{cluster="core"}[5m]))`). Keyed `(cluster, job, node)`.
- **`HostCollectorMissing`**: the same shape over every exporter of a host, keyed `(cluster, node)`. It pages once when the host or its collector is down, and inhibits the per-exporter `TargetMissing` alerts.
- **`<Prefix>ExporterDown`**: `up == 0`, the collector reaches the host but the exporter does not answer.
- **Rarely updated gauges are read with `last_over_time(...[30d])`.** Timer job outcomes (`podman_job_last_success_timestamp_seconds`, `podman_job_last_failure_timestamp_seconds`, `podman_job_exit_code`) are pushed once per run, so an instant selector sees nothing between runs.

## Logs

`loki-core` stream labels are `cluster`, `node`, `quadlet`, `service_name` (the container name), `service_namespace` (the inventory group's namespace) and `deployment_environment`. `node` and `quadlet` are indexed by a core-tenant override in monitoring-backbone `.deploy/rubik/loki/values.yaml`. Only the containers a host lists in `monitoring.collectors.logs.containers` are shipped, so a missing container is a collection gap, not a broken query.

**Logs are read in Explore, not on a log dashboard.** Dashboards link there with drilldown URLs per `grafana-kilic-dashboards`. Working example, the `Open Quadlet logs` link on monitoring-core's `podman.json`:

```
/explore?left=%7B%22datasource%22%3A%22loki-core%22%2C%22queries%22%3A%5B%7B%22expr%22%3A%22%7Bnode%3D%5C%22${__data.fields["node"]}%5C%22%2C%20service_name%3D~%5C%22.%2B%5C%22%7D%20%7C%20quadlet%3D%5C%22${__data.fields["quadlet"]}%5C%22%22%2C%22refId%22%3A%22A%22%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22${__from}%22%2C%22to%22%3A%22${__to}%22%7D%7D
```

Decoded, the pane state is `{"datasource":"loki-core","queries":[{"expr":"{node=\"<node>\", service_name=~\".+\"} | quadlet=\"<quadlet>\"","refId":"A"}],"range":{"from":"${__from}","to":"${__to}"}}`. A dashboard-level link uses `${node:regex}` in the same position.

## Dashboards

Core and Infrastructure dashboards use the `datasource` variable `/^mimir(-core)?$/` selected `mimir-core`, no `cluster` variable, and a multi-select target variable (`node`, `pbs`, `router`, `guest`, `quadlet`) defaulting to All. Alerts link to them with that variable (`var-node={{ $labels.node }}`).
