# Structure Exploring: kilic

How an agent finds the repository and file behind a change or an observation. The map is `structure-kilic-overview`.

## Tools, in order of preference

| Need | Tool | Notes |
|---|---|---|
| Which repos exist, where a string lives | `sourcebot-kilic` `list_repos`, `grep`, `glob`, `list_tree`, `read_file` | Repo names are `gitlab.kilic.dev/<path>`. Index covers ~120 repos including archived-adjacent ones; `grep` with `groupByRepo: true` for a first sweep |
| Authoritative group membership, archived flag, `web_url` | `gitlab` `list_namespaces`, `list_group_projects` (`include_subgroups: true`), `get_project` | Sourcebot does not show `archived`; GitLab does |
| What actually runs where | `argocd-kilic` `list_applications`, `get_application`, `list_clusters` | `list_applications` strips `spec.sources`; call `get_application` for repoURL/path. Outputs are large, filter with jq/python |
| Cluster state | `kubernetes-kilic` (read-only) | Context names equal cluster names, plus `rancher` |
| Local work | `~/development/<group-ish>/<repo>` | Local layout flattens GitLab paths: `~/development/charts/chart-*` is `cluster/charts/chart-*`, `~/development/workloads/*` is `cluster/workloads/*`, `~/development/cluster/argocd-<c>` is `cluster/<c>/argocd-<c>`, `~/development/cluster/argocd-pulumi-hydrator` is `cluster/pipes/...` |
| Background notes | Obsidian `Repositories/<local-dir>/...` | Mirrors the local layout (`Repositories/workloads/...`), not GitLab paths; sparse |

## Naming conventions and path patterns

| Pattern | Meaning |
|---|---|
| `infrastructure/tf-config-<target>` | Terraform for one provider/target, CI `devops/pipelines` `terraform@2.0.1` (install, lint, plan, deploy) |
| `infrastructure/pulumi-config-<target>` | Pulumi TS (NestJS modules under `src/modules/<concern>/`), CI `pulumi@2.0.1` (preview, up) |
| `cluster/pulumi-config-rancher` | The only cluster-lifecycle Pulumi stack; one `create<Cluster>()` per cluster in `src/modules/clusters.service.ts` |
| `cluster/<c>/tf-<c>` | Per-cluster Terraform bootstrap; only `tf-overseer` is live |
| `cluster/<c>/argocd-<c>` | Pulumi generator; hand-written `src/`, generated `<dir>/1-manifest/` (`apps`, `system`, `namespaces`, `workloads/<name>`); `task` regenerates, commit output beside source |
| `cluster/argocd-root/src/argocd/assets/cluster/<c>/labels.yml` | Feature flags `system.feature.kilic.dev/<component>: true` and `cluster.kilic.dev/{environment,region,name}` |
| `cluster/argocd-root/src/argocd/assets/cluster/<c>/annotations.yml` | Per-cluster Helm values, key `values.system.feature.kilic.dev/<component>` |
| `cluster/argocd-system/base/<c>/applicationset.yaml` | One ApplicationSet per system component |
| `cluster/argocd-system/<env>/<c>/patch-applicationset.yaml` | Chart pin (`targetRevision`) for that env; `<env>` in development, platform, production, load-balancer |
| `cluster/argocd-system/{base,<env>}/<c>/values.yaml` | Layered values |
| `cluster/kargo-root/.deploy/overseer/projects/argocd-system/<c>/stages/<env>.yaml` | Kargo Stage `<c>.<env>`, Project `kargo-argocd-system-<c>` |
| `cluster/charts/chart-<c>` | Helm wrapper, tags `v<semver>` |
| `cluster/workloads/<w>/.deploy/<cluster>/` | Workload kustomize root; `.deploy/base/` when multi-cluster; vendored charts under `.../charts/<chart>-<ver>/` are not edit targets |
| ArgoCD app `cluster-<c>-system-<component>` | System component from argocd-system |
| ArgoCD app `<c>-<workload>` | Workload from argocd-`<c>` |
| ArgoCD app `<lb>-cluster-<c>`, `<lb>-vm-<host>`, `<lb>-routes` | LB routes on sun/moon to a downstream cluster or VM |
| `devops/pipelines/<package>/<template>.gitlab-ci.yml` | CI template, hidden job `.<name>`, pinned by tag `<package>@<semver>` |
| `devops/pipes/<pipe>/<command>/flags.go`, `<pipe>/README.md` | Pipe CLI behind a template; the README lists every environment variable |
| `ansible-playbooks/containers/<svc>/deploy.yml`, `provision/<area>/provision.yml`, `setup/<svc>/deploy.yml` | Ansible entry points; target hosts in the play's `hosts:` and `inventory.ini` |
| Vault path `overseer/argocd/clusters/<c>` | ArgoCD cluster credentials (server, token) only |

## Recipes

| To change / find | Look in | Verify with |
|---|---|---|
| Which repo owns a running pod/namespace | ArgoCD app whose destination matches, then `get_application` sources | `argocd-kilic` `get_application`; reference `kilic-workload-resolution` |
| A workload's Deployment, values, routes | `cluster/workloads/<w>/.deploy/<cluster>/` | `sourcebot grep` in that repo; ArgoCD app `<cluster>-<w>` path |
| Add a new workload to a cluster | `cluster/workloads/<w>` + `cluster/<c>/argocd-<c>/src/workloads/<w>/` + re-run `infrastructure/pulumi-config-gitlab` for the deploy key | skills `cluster-kilic-workload`, `argocd-kilic-workload`, `linear-kilic-project-argocd-workload` |
| Expose a workload publicly | `cluster/sun/argocd-sun` (loki side) or `cluster/moon/argocd-moon` (thor side) | skill `argocd-kilic-loadbalancer`; ArgoCD `sun-cluster-rubik` etc. |
| Enable a system component on a cluster | `argocd-root` `labels.yml` + regenerate | `list_clusters` labels; skill `linear-kilic-project-argocd-system` |
| Per-cluster value for a system component | `argocd-root` `annotations.yml` + regenerate | `list_clusters` shows `values.system.feature.kilic.dev/*` annotation keys |
| Fleet or per-env value for a system component | `cluster/argocd-system/{base,<env>}/<c>/values.yaml` | reference `kilic-resource-placement` |
| New system component | `cluster/charts/chart-<c>` then `argocd-system` base + env overlay, `kargo-root` project | skills `cluster-kilic-chart`, `linear-kilic-project-argocd-system`, `argocd-system/.claude/skills/*` in-repo |
| Why a chart pin moved / promote a pin | `cluster/kargo-root` Stages, commits on `cluster/argocd-system` | skill `argocd-kilic` |
| Kubernetes version, node pools, etcd backup of a cluster | `cluster/pulumi-config-rancher/src/modules/clusters.service.ts` | Rancher UI / `kubernetes-kilic` nodes |
| A cluster's VMs (CPU, RAM, disks) | `infrastructure/tf-config-proxmox/cluster-<c>.tf` | tags `cluster-<c>` |
| ArgoCD or Vault install itself | `cluster/overseer/tf-overseer` | `kubernetes-kilic` context `overseer` |
| ArgoCD repo access, webhooks, CI variables for IaC | `infrastructure/pulumi-config-gitlab/src/modules/{argocd,webhook,pipelines}` | `gitlab` MCP project settings (read) |
| Vault policies/approles | `infrastructure/pulumi-config-vault` | `vault-kilic` MCP `list_mounts` (read) |
| SSO client for an app | `infrastructure/pulumi-config-zitadel`; app side in workload repo | - |
| DNS: public | `infrastructure/tf-config-cloudflare`, plus external-dns on sun/moon | - |
| DNS/DHCP/firewall internal | `infrastructure/tf-config-opnsense` (`region-<thor|loki>-*.tf`) | - |
| A legacy server or core container (GitLab, Rancher, headscale, caddy) | `ansible/ansible-playbooks/containers/<svc>/` and `host_vars/<host>/` | `inventory.ini`; repo `CLAUDE.md` |
| Monitoring stack per cluster | `cluster/workloads/monitoring`, `monitoring-ruler` (via argocd-system); central view on rubik `monitoring-backbone`, `monitoring-view` | skill `grafana-kilic` |
| A pipeline job's behaviour, variables, or failure | the `include` `ref: <package>@<ver>` in `.gitlab-ci.yml`, then `devops/pipelines/<package>/<template>.gitlab-ci.yml` at that tag, then `devops/pipes/<pipe>/<command>/` | reference `kilic-ci-pipelines`; skills `gitlab-ci-create`, `gitlab-ci-fix` |

## Skill coverage

| Area | Skill(s) |
|---|---|
| GitLab CI pipelines (`devops/pipelines`, `devops/pipes`) | `gitlab-ci-create`, `gitlab-ci-fix` |
| Workload manifests | `cluster-kilic-workload` |
| Cluster ArgoCD repo (Pulumi) for workloads | `argocd-kilic-workload` |
| LB clusters sun/moon routes | `argocd-kilic-loadbalancer` |
| System chart repos | `cluster-kilic-chart` |
| Planning a system component / workload rollout | `linear-kilic-project-argocd-system`, `linear-kilic-project-argocd-workload` |
| Operating ArgoCD, Kargo mechanics | `argocd-kilic` |
| Cluster reads | `kubernetes-kilic` |
| Observability | `grafana-kilic`, `grafana-kilic-*` |
| Resolving observation to repo; value placement | references `kilic-workload-resolution`, `kilic-resource-placement` |
| infrastructure group (Terraform/Pulumi), pulumi-config-rancher, tf-overseer, ansible-playbooks | **No skill.** `ansible-playbooks` has in-repo `.claude/skills/{container-quadlet,setup-playbook}` and a `CLAUDE.md`; `argocd-system` has in-repo `.claude/skills` |
| `spacelift-*` | Laravel estate, not kilic |
