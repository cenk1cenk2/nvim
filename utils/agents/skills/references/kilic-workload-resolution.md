# Kilic Workload Resolution

Resolve a **running thing** — a metric series, a pod, a namespace, an alert — back to the **repository and file** that own its configuration. Read this before editing anything on behalf of an observation made in a cluster.

Never infer the repo from a name. Pod names carry replicaset hashes, job pods are named after the repo that triggered them rather than the repo that defines them, and namespaces do not map one-to-one onto repositories. ArgoCD already knows the answer; ask it.

## The chain

```
observation      cluster, namespace, workload kind + name, container
  ArgoCD         the Application whose destination matches cluster + namespace
    sources[]    spec.sources[].repoURL  (or spec.source.repoURL)
      repo       the group decides which configuration ladder applies
        spread   how many Applications share that repoURL decides base vs override
```

1. **List Applications** with the ArgoCD MCP server and match on `spec.destination.namespace` plus the cluster. Applications are named `cluster-<cluster>-system-<component>`, so the cluster is legible in the name as a cross-check, never as the primary key.
2. **Read `spec.sources[].repoURL`.** `sources` is plural and a component may carry several; the chart or manifest source is the one that is not a bare `ref:` values source.
3. **Classify by group** — this determines everything downstream, per `kilic-resource-placement`:

   | repoURL group | What it is |
   |---|---|
   | `cluster/charts/chart-*` | System component, deployed by `argocd-system`, layered Helm values |
   | `cluster/workloads/*` | Workload repository, kustomize under `.deploy/` |

4. **Count the spread.** Filter every Application sharing that `repoURL`: the count is how many clusters run it. One cluster means there is no common layer to argue about; several means a change to the common layer reaches all of them, and only a genuine per-cluster difference justifies an override.

## Watch for

- **The target may not be a Deployment.** Operator-owned workloads (`cnpg` clusters, `mariadbs`, `opentelemetrycollectors`, `grafanas`, `renovatejobs`) surface as their own kinds, and their sizing lives in the operator CR or the chart values that render it, not in a Deployment spec.
- **Job and CronJob pods are transient.** They appear in metrics with names resembling the repository that triggered them. Resolve them through their owner, and treat a finished job's series as history rather than current state.
- **An Application can exist without the workload running**, and a workload can run whose Application was removed. When the two disagree, the cluster is the fact and the repository is the intent — say which one you acted on.
