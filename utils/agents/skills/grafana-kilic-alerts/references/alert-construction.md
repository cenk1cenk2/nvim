# Alert Construction

How a kilic alert rule is built, linked, inhibited and tested. The concrete rules, their prefixes per subsystem, and the Alertmanager routes and inhibit rules are in the owning repositories; read them before writing one.

## Anatomy

```yaml
- alert: <Prefix><Condition>
  annotations:
    dashboard_url: https://monitoring.kilic.dev/d/<uid>/<slug>?var-<entity>={{ $labels.<entity> }}
    description: <Object> {{ $labels.namespace }}/{{ $labels.<object> }} in {{ $labels.cluster }} has <condition>. <What to check>.
    replaces: <OldAlert>, <OtherOldAlert>
    summary: <One static sentence naming the condition.>
  expr: |
    max by (cluster, <object labels>) (...) <comparison>
  for: <duration>
  labels:
    component: <subsystem>
    severity: warning
```

Keys are sorted (`annotations`, `expr`, `for`, `labels`, and alphabetically inside each), matching the existing files.

- **Name**: PascalCase, starting with the subsystem prefix. Inhibit matchers and the alert-family dashboards select by prefix regex, so the prefix is structural: a new prefix lands in an `Other` family until the dashboard learns it, and a prefix that collides with another estate's (a host alert named like a Kubernetes node alert) gets swept into that estate's inhibition. Reuse the neighbours' prefix.
- **One name, one label set.** Two rules with the same name and static labels are a duplicate that `promtool check rules` rejects; merge them with `or`. A warning and critical pair differs in `severity` and stays two rules.
- **`summary` is static**, one sentence, no templating, so grouped notifications read the same. **`description` carries the templated specifics**: the object, the cluster, the value (`humanizePercentage`, `humanizeDuration`), and what to check.
- **`severity` is `critical` or `warning`.** There is no info tier.
- **`component`** names the subsystem and groups the alert with its neighbours.
- **`replaces:`** lists, comma-separated, every alert this one supersedes, including the old name on a rename, so nobody reintroduces them as missing coverage.

## Writing the condition

Build in this order, and stop at the first step that removes the noise:

1. **Expression**: aggregate to the object with `max by (cluster, <object labels>)`, so replicas produce one alert. Chain `and on (...)` / `unless on (...)` to describe a terminal state rather than a transient one (failed **and** no active pods **and** not succeeded, rather than "failed > 0").
2. **`for:`**: from how long the condition can transiently hold, not from how urgent it feels. Read the neighbours' durations; short windows are for genuinely urgent states, long ones for slow-moving conditions.
3. **Severity**: `critical` when someone must act now or data is at risk, `warning` otherwise. A pair uses the same expression shape at two thresholds, the critical one with a shorter horizon.
4. **Inhibition**: only when one alert makes another meaningless, below.

**Pushed or sparse data** needs its own shapes: target missing versus collector missing, the tenant-alive guard, and `last_over_time` for gauges pushed once per run, per `kilic-core-tenant`.

## `dashboard_url`

Link to the dashboard that **shows the problem**, scoped to the object, with the variable the target dashboard actually has: `var-cluster={{ $labels.cluster }}` for Kubernetes dashboards, the entity variable (`var-node={{ $labels.node }}`) for core ones. Never `var-datasource`; the target's default already selects the right tenant.

**Route by a label with template conditionals** when the object belongs to one of several dashboard families. The label that tells the families apart (the job namespace, for host classes) picks the uid:

```
https://monitoring.kilic.dev/d/{{ if match "^<classA>/" $labels.job }}<uidA>/<slugA>{{ else if match "^<classB>/" $labels.job }}<uidB>/<slugB>{{ else }}<uidC>/<slugC>{{ end }}?var-node={{ $labels.node }}
```

**Look the label up with `query` when the expression aggregated it away** (a per-host alert keyed `(cluster, node)` has no `job`):

```
{{ $job := "" }}{{ with printf "group by (job) (last_over_time(up{cluster='%s', node='%s', job=~'(.+/)?<exporter>'}[30d]))" $labels.cluster $labels.node | query }}{{ $job = . | first | label "job" }}{{ end }}{{ if match "^<classA>/" $job }}...{{ end }}
```

Use single quotes inside the query string, and a `last_over_time` lookback long enough to find the label after the series stopped.

The link target exists only if its uid does: check with `search_dashboards`.

## Inhibition

Inhibit rules live in monitoring-backbone's Alertmanager fallback config, grouped in commented families by shape. Every tenant runs the same config, so one rule covers every tenant whose alerts it names, and its Go templates are written unescaped.

| Shape | Source suppresses |
|---|---|
| Scrape target down | every alert derived from that target's metrics |
| Subsystem root cause | its own downstream symptoms |
| Warning and critical pair | the warning for the same object |
| Pushed telemetry missing | per-exporter target-missing alerts (collector missing), and each exporter's derived alerts (exporter down or missing) |

- **The `equal:` list is the whole correctness of the rule.** Prove it: list each label in `equal:`, and confirm it appears in the `by (...)` of **both** the source and every target expression. A label one side aggregates away compares as empty against a set value and never matches, and inhibition that never matches looks identical to inhibition that works. Labels absent on both sides compare as empty and match.
- **Only inhibit what the source genuinely blinds.** Alerts derived from a different source stay valid when one exporter dies.
- **A per-target down alert inhibits only once every target is down**, by a label the down alert sets (`targets_down="all"`) matched in `source_matchers`; one down replica leaves the others' metrics flowing.
- **Add to the family the rule belongs to**, or open a new commented family for a new estate.

Routing is per severity in the same file, each route grouping so a newly affected object posts its own message. Read the current routes there; tune grouping and repeat before adding an inhibit rule for something merely repetitive rather than redundant.

## Lint and test

Lint through container images, never a local install:

```sh
yq '{"groups": .spec.groups}' rules/<file>.yaml > /tmp/rules.yaml
docker run --rm -v /tmp:/w --entrypoint promtool quay.io/prometheus/prometheus check rules /w/rules.yaml
docker run --rm -v "$PWD":/w --entrypoint amtool quay.io/prometheus/alertmanager check-config /w/<alertmanager config>
```

Then `kustomize build` each changed repository (`--enable-helm` for monitoring-backbone).

**Unit-test a new or changed expression with `promtool test rules`** in a scratch file: input series that should fire, and **a negative control that must not** (the healthy state, or the transient state the expression is meant to ignore). A test with only the firing case passes for an expression that always fires. Assert the alert's labels and the rendered `dashboard_url` where it is templated. Run it through the same image with `--entrypoint promtool ... test rules`.
