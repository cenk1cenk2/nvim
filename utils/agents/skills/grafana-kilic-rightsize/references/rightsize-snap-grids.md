# Rightsize Snap Grids

Every committed `requests` and `limits` value lands on one of these grids, or on an in-between stop materially closer to the sample. Round UP from the sample, never down, and add nothing on top: the sample comes from the queries in `rightsize-signals`, and the stop is the smallest one at or above it. Self-audit the diff before commit.

Value floors for a committed size: CPU request 10m, CPU limit 250m, memory request 32Mi, memory limit 64Mi. These are floors on the value; the materiality floors in `rightsize-signals` decide whether a change is proposed at all, and both hold.

## CPU, millicores

| | | | | | | | |
|---|---|---|---|---|---|---|---|
| 10 | 50 | 100 | 250 | 500 | 1000 | 2000 | 4000 |

Snap-ups: `1m` to `10m`, `25m` to `50m`, `30m` to `50m`, `68m` to `100m`, `136m` to `250m`, `314m` to `500m`, `391m` to `500m`, `520m` to `1000m`, `700m` to `1000m`, `1500m` to `2000m`.

**Integer CPU values are quoted in YAML.** `cpu: 1` parses as a number in Go and the resource silently reverts; write `cpu: "1"`, `cpu: "2"`, `cpu: "1.5"` — in helm `values.yaml`, raw `PodSpec`, kustomize patches and CNPG `Cluster.spec.resources` alike. Millicore forms such as `100m` are accepted bare.

## Memory, MiB

| | | | | | | | | | |
|---|---|---|---|---|---|---|---|---|---|
| 16 | 32 | 64 | 128 | 256 | 512 | 1024 | 2048 | 4096 | 8192 |

In-between stops in use: `96Mi`, `192Mi`, `384Mi`, `768Mi`, `1536Mi`, `3Gi` — each the midpoint of its two neighbouring grid stops.

Snap-ups: `29Mi` to `32Mi`, `34Mi` to `64Mi`, `90Mi` to `96Mi`, `150Mi` to `192Mi`, `350Mi` to `384Mi`, `510Mi` to `512Mi`, `700Mi` to `768Mi`, `1400Mi` to `1536Mi`, `1976Mi` to `2048Mi`, `2922Mi` to `3Gi`.

## Gi versus Mi at the boundary

At or above 1Gi, use `Gi` notation where the chart or YAML rendering supports it: `1024Mi` becomes `1Gi`, `2048Mi` becomes `2Gi`, `3072Mi` becomes `3Gi`, `4096Mi` becomes `4Gi`. Below 1Gi, and for `1536Mi`, which is not a whole Gi, stay in `Mi`. Raw `PodSpec` accepts both; the convention is the larger unit when the number is clean.

## Storage

Storage is a separate grid from memory. The prevailing walStorage floor on kilic.dev is 8Gi and the next stop is 16Gi; sizing per `rightsize-cnpg-walstorage`.

## When to deviate

The grid is a preference for scannability in `kustomize build` output and Grafana dashboards, not an allow-list. Take the in-between stop whenever it is materially closer to the sample than the next grid stop: a 350Mi request goes to `384Mi`, not `512Mi`, and a 2.9Gi limit goes to `3Gi`, not `4Gi`. Between 2Gi and 4Gi a whole step adds a gigabyte or more of headroom nobody measured, so take the in-between there rather than jumping a stop.

The rule applies to the sample the right query produced. A request read from a per-series average is inflated on any workload whose pods churned, and an inflated sample makes the next grid stop look close enough; read it per `rightsize-signals` first.

## Self-audit checklist before commit

For every container in the change, walk the diff and verify:

- `requests.cpu` and `requests.memory` came from the time-weighted busiest-pod query, not a per-series average.
- `limits.cpu` and `limits.memory` are the smallest stop at or above the 7d max, and no limit dropped below it.
- Every value is on the grid or on an in-between stop, and any integer CPU value is quoted as a string.
- Memory uses `Mi` or `Gi` per the boundary rule.
- No limit was added where the workload had none.
- The rendered YAML is real multi-line YAML, with no escape sequences left in the body by a file-write API.
