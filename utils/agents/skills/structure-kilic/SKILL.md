---
name: structure-kilic
description: structure-kilic Auto-invoked on kilic estate context - gitlab.kilic.dev repos, the infrastructure, cluster, workloads or ansible groups, cluster names like rubik or overseer - to map which repository owns a change, how it flows to where it runs, and which skill covers that area. Not for the Laravel estate, or for operating one tool already identified.
references:
  - ./references/structure-kilic-overview.md
  - ./references/structure-kilic-exploring.md
  - ../references/kilic/kilic-workload-resolution.md
  - ../references/kilic/kilic-resource-placement.md
  - ../references/kilic/kilic-ci-pipelines.md
  - ../references/current-state-only.md
---

## Estate Structure: kilic

The map of how the kilic estate is wired across `gitlab.kilic.dev`:
- which group and repository owns what;
- how a change flows from IaC through clusters and ArgoCD to a running workload;
- which cluster runs what.

Load it before deciding where a change goes or what an observation traces back to. It routes; the area skills operate.

## Process

1. **Place the request on the map** per `structure-kilic-overview`. The Groups section says who owns it, the Flow section says what ships it, and the Clusters section says where it runs.
2. **Find the exact file** per `structure-kilic-exploring`: pick the tool, match the naming pattern, then follow the recipe. For a running thing traced back to its repo, resolve per `kilic-workload-resolution`. For where a value belongs, per `kilic-resource-placement`. For anything in a pipeline, per `kilic-ci-pipelines`.
3. **Verify live before acting.** Treat the map as a guide, not proof. Confirm the repo with the `gitlab` read tools (`web_url`, archived flag) and confirm what runs with `argocd-kilic`. When the two disagree with the map, the live state wins, and the map needs updating per Key Principles.
4. **Hand off to the area skill** that the exploring skill-coverage table names. For example, load `argocd-kilic` for sync, prune and Kargo, `cluster-kilic-workload` for workload manifests, and `argocd-kilic-loadbalancer` for public routes. An area marked **No skill** is worked straight from its repository's own `CLAUDE.md` and in-repo skills.

## Key Principles

- **Link every repository by its `web_url`**, per the identifier rule in `AGENTS.md`. Every repo row in the overview already carries one.
- **The map is extendable.** A new group, repo class or cluster lands as a row under the existing headings (Groups, Flow, Clusters). Recipes and naming patterns go in the exploring file. Another estate gets its own `structure-<estate>` skill with the same headings.
- **Keep it current.** A repo that is archived, moved or added, or a flow that changed, is corrected in these references in the same turn it is found, per `current-state-only`.
