---
name: grafana-kilic-alerts
description: grafana-kilic-alerts Author and tune Prometheus alert rules in the monitoring-ruler repo - expression, for-duration, severity, and the inhibition that keeps one root cause from paging ten times. Use on "add an alert", "this alert is noisy", "why did we get paged twice". Not for reading metrics, dashboards, or Grafana-managed alerting.
disableModelInvocation: true
argumentHint: '[alert or subsystem] - e.g. ''add a cnpg backup alert'', ''velero is noisy'''
references:
  - ../references/kilic/grafana-kilic-datasources.md
  - ../references/output-diff.md
---

## Alerting

Alerts are **`PrometheusRule` CRs evaluated by the Mimir Ruler**, not Grafana-managed alerts. Grafana's own alerting API holds nothing, and Grafana OnCall is not installed — do not reach for either. Datasource inventory: `grafana-kilic-datasources`. For writing and validating the expressions themselves, load the `grafana-kilic-read` skill.

Two repositories are involved and both usually change together:

| What | Where |
|---|---|
| Alert and recording rules | `cluster/workloads/monitoring-ruler` |
| Alertmanager routing and inhibition | `cluster/workloads/monitoring`, at `.deploy/rubik/mimir/es-alertmanager-slack.yaml` |

Alertmanager config is templated inside an ExternalSecret, so Go template braces in it are escaped as `{{ "{{" }}`. Alertmanager runs per cluster; there are six datasources and none for `core`.

## Repository Layout

```
.deploy/base/alerts/<category>/     alerting rules, every cluster
.deploy/base/rules/<category>/      recording rules, every cluster
.deploy/rubik/alerts/workloads/     rubik-only, for the central stack
.deploy/<cluster>/                  per-cluster overlays
```

Rubik is the **central** cluster running the full stack; moon, nailbed, neutrino, overseer and sun are **edge**. An alert about something only rubik runs belongs in `.deploy/rubik/`, not in base with a cluster matcher.

## Alert Anatomy

```yaml
- alert: KubeJobFailedTerminal
  annotations:
    summary: Kubernetes job failed without a successful completion.
    description: Job {{ $labels.namespace }}/{{ $labels.job_name }} in cluster {{ $labels.cluster }} has failed, has no active pods, and has not succeeded.
    dashboard_url: https://monitoring.kilic.dev/d/<uid>/<slug>?var-datasource=mimir-{{ $labels.cluster }}&var-cluster={{ $labels.cluster }}
    replaces: KubeJobFailed
  expr: |
    ...
  for: 30m
  labels:
    component: workload-resources
    severity: warning
```

- **Name** is PascalCase and subsystem-prefixed (`KubeJobFailedTerminal`, `CNPGBackupStale`, `VaultSealed`). The prefix is what inhibition matchers key on, so it is structural, not cosmetic.
- **`summary`** is one sentence, no templating. **`description`** carries the templated specifics.
- **`dashboard_url`** points at the dashboard that shows the problem, with `var-datasource=mimir-{{ $labels.cluster }}` so the link lands on the right cluster.
- **`replaces`** names the alerts this one supersedes — see below.
- **`severity` is `critical` or `warning`. Nothing else.** There is no info tier; an alert not worth one of those two is not worth having.
- **`component`** groups an alert with its subsystem.

## Noise Reduction, In Order of Precedence

Every one of these exists because something paged too often. Reach for them in this order.

### 1. Write the expression so it only fires on a real state

Aggregate with `max by (...)` over the labels that identify the object, so replicas of the same workload produce one alert rather than N.

Chain `and on (...)` to describe a genuinely terminal condition rather than a transient one. `KubeJobFailedTerminal` fires only when a job has failed **and** has no active pods **and** has not succeeded — the naive "failed > 0" fires during a retry that then succeeds.

### 2. Pick `for:` deliberately

The dominant durations are `10m`, `15m`, `5m` and `30m`, with `1h` and longer for slow-moving conditions and `2m` reserved for genuinely urgent ones. `for:` is the cheapest noise control there is: a condition that resolves itself inside the window never becomes an alert.

### 3. Consolidate with `replaces:`

When one alert supersedes several upstream ones, name them in a `replaces:` annotation, comma-separated. It records why the originals are gone, so nobody reintroduces them as "missing coverage".

### 4. Inhibit, when one alert makes another meaningless

Inhibition lives in the Alertmanager config, not the rules. **The `equal:` list is the whole correctness of an inhibit rule** — it must name labels that source and target genuinely share, verified against the rule expressions, not assumed.

The established families:

| Family | Shape |
|---|---|
| **Scrape target down** | A down exporter blinds every alert derived from its metrics, so only the target-down alert pages. `equal` carries the labels both sides share — usually `[cluster, namespace]` or `[cluster, namespace, job]`. |
| **Subsystem root cause** | A root cause suppresses its own downstream symptoms — a failing pod volume backup suppresses the schedule-level partial-failure and stale alerts it causes. |
| **Warning and critical pair** | The critical page already covers the warning for the same object. `equal` spans every object label used across the pairs; labels absent on a given pair compare as empty on both sides and still match. |

Two rules that keep inhibition honest:

- **Only inhibit what the source genuinely blinds.** When an exporter goes down, alerts derived from *other* sources stay valid and must keep paging. The Renovate rule suppresses only the alert reading the operator's own metric; the kube-state-metrics-derived ones are untouched.
- **Check what the expression actually keeps.** Vault alerts aggregate with `sum()` and `max()` and drop `cluster` and `namespace`, so the only label shared across all of them is the static `component`. An `equal: [cluster, namespace]` there would silently never match, and inhibition that never matches looks identical to inhibition that works.

### 5. Route by severity

Grouping is `[alertname, cluster, severity]`, with per-severity timings:

| Severity | `group_wait` | `group_interval` | `repeat_interval` |
|---|---|---|---|
| critical | 2m | 30m | 12h |
| warning | 30m | 2h | 48h |
| default | 1h | 6h | 168h |

Tune these before adding an inhibit rule for something that is merely repetitive rather than genuinely redundant.

## Process

1. **Read the existing rules for that subsystem first.** Naming, `component`, aggregation shape and `for:` conventions are established per subsystem, and an alert that does not match its neighbours will not be caught by their inhibition.
2. **Decide base or cluster.** Base for anything every cluster runs; `.deploy/rubik/` for the central stack.
3. **Validate the expression against live data**, per `grafana-kilic-read` — confirm it returns rows now, and reason about when it would not.
4. **Choose `for:` from how long the condition can transiently hold**, not from how urgent it feels.
5. **Check what it will fire alongside.** If a root cause already pages, add an inhibit rule and verify the `equal:` labels appear in **both** expressions.
6. **Set `dashboard_url`** to the dashboard that shows the problem, templated on cluster.
7. **Present the rule and any Alertmanager change together** per `output-diff` — they are one change even across two repos.

## Key Principles

1. **The expression is the first noise filter**, `for:` the second, inhibition the last. Reaching for inhibition to fix a badly written expression hides the bug.
2. **An inhibit rule's `equal:` labels must exist in both expressions.** Verify against the rules; a non-matching inhibit rule is indistinguishable from a working one until you get paged.
3. **Inhibit only what is genuinely blinded.** Alerts derived from a different source stay valid when one exporter dies.
4. **Two severities only.**
5. **`replaces:` records the consolidation** so removed alerts do not come back as a coverage gap.
6. **Aggregate to the object, not the replica.**
7. **Rules and Alertmanager config live in different repos and change together.**

## Examples

**User says:** "we got paged eight times when the Velero server went down"

1. Read the Velero rules and note which alerts derive from the Velero server's own metrics.
2. Those are blinded by the server being down, so only `VeleroServerDown` should page.
3. Confirm the shared labels by reading the expressions — all Velero alerts carry `namespace=velero`, so `equal: [cluster, namespace]`.
4. Add the inhibit rule to the Alertmanager config in the `monitoring` repo.
5. Check nothing derived from a different source got swept in.

**Result:** One page for the root cause, with the derived alerts suppressed only while the source is down.

---

**User says:** "add an alert for jobs that never finish"

1. Read `workload-resources.yaml` for the naming and aggregation conventions.
2. Expression aggregates `max by (cluster, namespace, job_name)` and tests active start time against a threshold.
3. Base, since every cluster runs Jobs.
4. `severity: warning`, `component: workload-resources`, `dashboard_url` to cluster-overview.
5. Confirm it returns rows against a cluster with long-running jobs before shipping.

**Result:** An alert that matches its neighbours, and is therefore covered by the inhibition they already have.
