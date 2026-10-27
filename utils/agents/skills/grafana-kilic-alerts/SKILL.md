---
name: grafana-kilic-alerts
description: grafana-kilic-alerts Author and tune Prometheus alert rules in their owning repo - naming, expression, for-duration, severity, dashboard links, and the inhibition that keeps one root cause from paging ten times. Use on "add an alert", "this alert is noisy", "why did we get paged twice". Not for reading metrics, dashboards, or Grafana-managed alerting.
disableModelInvocation: true
argumentHint: '[alert or subsystem] - e.g. ''add a cnpg backup alert'', ''velero is noisy'''
references:
  - ./references/alert-construction.md
  - ../references/kilic/grafana-kilic-datasources.md
  - ../references/kilic/kilic-monitoring-ownership.md
  - ../references/kilic/kilic-autoscaling-metrics.md
  - ../references/kilic/kilic-core-tenant.md
---

## Alerting

Alerts are **`PrometheusRule` CRs evaluated by the Mimir Ruler**, not Grafana-managed alerts; why the Grafana alerting API and OnCall are unavailable: `grafana-kilic-datasources`. Load the `grafana-kilic-read` skill before validating an expression against live data.

The rule and its Alertmanager handling live in different repositories and usually change together: the rule in its owner per `kilic-monitoring-ownership`, routing and inhibition in monitoring-backbone's Alertmanager fallback config. **Read the owner's `CLAUDE.md` and the existing rules for that subsystem before writing one**: prefixes, `component`, aggregation shape, `for:` and `dashboard_url` targets are established per subsystem, and an alert that does not match its neighbours is not covered by their inhibition.

Anatomy, the `dashboard_url` routing method, inhibition shapes, and the lint and test recipe: `alert-construction`. Core tenant shapes for pushed metrics (target missing versus collector missing, `last_over_time` for sparse gauges): `kilic-core-tenant`. Autoscaling families and what each existing rule means for triage: `kilic-autoscaling-metrics`.

## Rules and the Federated Datasource

**The ruler does not federate.** Each rule evaluates inside the tenant that owns it, and rule state is read per tenant through `mimir-<tenant>` or `alertmanager-<tenant>`. The federated `mimir` is still where an expression gets validated, and there every raw series carries `__tenant_id__`:

- **Scope by `cluster`.** A rule for one cluster selects it literally; a base rule every cluster evaluates carries no matcher, so add `cluster="<name>"` to the validation query rather than to the rule. A core rule is validated on `mimir-core`.
- **Aggregate `__tenant_id__` away.** Keep `cluster` and the object labels in every `by (...)`, and match binary operators with `on (...)` including `cluster`. A bare `or`, `and` or `unless` between a raw series and an aggregate evaluates correctly in the ruler but returns doubled or missing rows on `mimir`, so a rule validated that way was not validated.
- **Place by scope.** Something every cluster runs goes in the base rules; something only one cluster runs goes in that cluster's overlay rather than base with a cluster matcher; one workload goes in its own repository, scoped in `expr` to its cluster and namespace.

## Process

1. **Find the owner and read its rules and `CLAUDE.md`.** Copy the neighbours' prefix, `component`, aggregation and `dashboard_url` shape.
2. **Write the expression** to fire only on a real state: aggregate to the object, chain `and on (...)` for a terminal condition.
3. **Validate it live** per `grafana-kilic-read`: confirm it returns rows now, or would under a loosened threshold, and reason about when it would not.
4. **Choose `for:`** from how long the condition can transiently hold, then the severity.
5. **Write the annotations**: a static `summary`, a templated `description`, a `dashboard_url` to the dashboard that shows the problem, `replaces:` naming every alert it supersedes, including its own old name on a rename.
6. **Check what it fires alongside.** If a root cause already pages, add an inhibit rule and prove the `equal:` labels in both expressions.
7. **Lint and unit-test** through container images, with a negative control in the test.
8. **Report the rule and any Alertmanager change together**: they are one change even across two repositories.
9. **Moving a rule to another owner keeps its name and labels**, so Alertmanager deduplicates the overlap: add the new copy, let it sync, then remove the old one.

## Key Principles

1. **The expression is the first noise filter, `for:` the second, inhibition the last.** Reaching for inhibition to fix a badly written expression hides the bug.
2. **The name prefix is structural**: inhibition and the alert-family dashboards key on it.
3. **An inhibit rule's `equal:` labels must exist in both expressions.** A non-matching inhibit rule is indistinguishable from a working one until you get paged.
4. **Inhibit only what is genuinely blinded.**
5. **Two severities only.**
6. **`replaces:` records the consolidation** so removed alerts do not come back as a coverage gap.
7. **A test without a negative control proves nothing.**

## Examples

**User says:** "we got paged eight times when the Velero server went down"

1. Read the Velero rules and note which alerts derive from the server's own metrics.
2. Those are blinded by the server being down, so only the server-down alert should page.
3. Prove the shared labels from the expressions: every derived alert keeps `cluster` and `namespace` in its `by`, so `equal: [cluster, namespace]`.
4. Add the inhibit rule to its family in the Alertmanager config in monitoring-backbone, and lint it with `amtool`.
5. Check nothing derived from a different source got swept in.

**Result:** One page for the root cause, with the derived alerts suppressed only while the source is down.

---

**User says:** "add an alert for jobs that never finish"

1. Read the workload-resources rules for the prefix, `component` and aggregation.
2. Aggregate `max by (cluster, namespace, job_name)` and test active start time against a threshold.
3. Base, since every cluster runs Jobs; `severity: warning`; `dashboard_url` to the workloads dashboard with `var-cluster`.
4. Validate live, then a `promtool test rules` case with a long-running job that fires and a short one that does not.

**Result:** An alert that matches its neighbours, and is therefore covered by the inhibition they already have.
