# Structure Overview: kilic

Repository and wiring map of the kilic estate on the self-hosted GitLab `gitlab.kilic.dev`. Anything not verified against GitLab, Sourcebot or live ArgoCD is marked **Unverified**.

- **SCM:** `https://gitlab.kilic.dev` (project `web_url` = `https://gitlab.kilic.dev/<path_with_namespace>`; confirmed with `get_project`).
- **Git remote form used by ArgoCD:** `git@gitlab.kilic.dev:<path_with_namespace>.git`.
- **Code index:** Sourcebot, repo names `gitlab.kilic.dev/<path_with_namespace>`.
- **How to find things:** `structure-kilic-exploring`.

---

## Groups

### Summary

| Group | What lives there | Tooling | Deploys | Target |
|---|---|---|---|---|
| [`infrastructure`](https://gitlab.kilic.dev/groups/infrastructure) | IaC for everything outside Kubernetes: hypervisors, VMs, network, DNS, object storage, Vault, GitLab, IdP, mail | Terraform (`tf-config-*`), Pulumi TypeScript/NestJS (`pulumi-config-*`), Butane/Ignition image | Real infrastructure via CI `plan`/`up` jobs | Proxmox, OPNsense, Cloudflare, Hetzner Cloud, Backblaze B2, Vault, GitLab, Zitadel, RustFS, mailserver, GitHub |
| [`cluster`](https://gitlab.kilic.dev/groups/cluster) (top level) | Cluster lifecycle and GitOps roots | Pulumi (Rancher), Pulumi-as-generator (`argocd-root`), kustomize (`argocd-system`, `kargo-root`) | Rancher cluster definitions, ArgoCD projects/cluster secrets/root apps, system ApplicationSets, Kargo projects | Rancher, ArgoCD on `overseer` |
| `cluster/<cluster>` (rubik, overseer, nailbed, neutrino, moon, sun) | One ArgoCD generator repo per cluster, plus archived per-cluster Terraform | Pulumi-as-generator (NestJS), committed `1-manifest/` output; Terraform (`tf-overseer` only, live) | Namespaces, per-cluster system bits (gateways, Cilium), ArgoCD Applications for workloads, LB routes | That cluster, via ArgoCD on `overseer` |
| [`cluster/workloads`](https://gitlab.kilic.dev/groups/cluster/workloads) | One repo per application | kustomize (often wrapping Helm charts via `helmCharts`) under `.deploy/<cluster>/` | Application manifests | Clusters named in `.deploy/<cluster>/` |
| [`cluster/charts`](https://gitlab.kilic.dev/groups/cluster/charts) | One Helm wrapper chart per system component | Helm, semantic-release tags `v<semver>` | Consumed by `argocd-system` ApplicationSets | Every cluster whose labels enable the component |
| [`cluster/operators`](https://gitlab.kilic.dev/groups/cluster/operators) | Custom Go operators, not deployed yet; kept for future use | Go, semantic-release | Nothing | - |
| [`cluster/pipes`](https://gitlab.kilic.dev/groups/cluster/pipes) | ArgoCD tooling | Go (ArgoCD Config Management Plugin) | Not wired to any live Application | - |
| [`cluster/monitoring`](https://gitlab.kilic.dev/groups/cluster/monitoring) | Archived dashboards repo only | - | - | - |
| [`ansible`](https://gitlab.kilic.dev/groups/ansible) | Host provisioning and non-Kubernetes services | Ansible (`./play` wrapper), podman containers | OS provisioning, core services as containers | Legacy/core VMs and bare metal (see Flow) |
| [`devops`](https://gitlab.kilic.dev/groups/devops) | CI for every other repo: [`pipelines`](https://gitlab.kilic.dev/devops/pipelines) (GitLab CI templates, tagged `<package>@<semver>`) and [`pipes`](https://gitlab.kilic.dev/devops/pipes) (Go CLIs published as `cenk1cenk2/pipe-<pipe>` images the templates run) | GitLab CI `include:project`, Go | Every pipeline job in the estate | GitLab runners |
| [`libraries`](https://gitlab.kilic.dev/groups/libraries) | Shared Taskfiles and code libraries | Taskfile, Go, Node | Included by repos (`libraries/taskfiles`) | - |
| [`pulumi`](https://gitlab.kilic.dev/groups/pulumi) | Pulumi template and shared libs | Pulumi TS | Template for new `pulumi-config-*` | - |
| [`renovate`](https://gitlab.kilic.dev/groups/renovate) | Renovate config and runner | Renovate | `renovate-runner` is deployed to rubik by `argocd-rubik` | rubik |
| [`docker`](https://gitlab.kilic.dev/groups/docker) | Container images (caddy, gitlab-tools, external-dns-webhook-opnsense, ansible-core, ...) | buildah/docker CI | Images to registries | Consumed by workloads and ansible containers |
| `terraform`, `services`, `html`, `config`, `cenk`, `utils`, `proposal`, `freelance` | Archived modules, personal sites, dotfiles, misc | - | Mostly out of scope for infra | - |

### infrastructure

| Repo | Tool | Manages |
|---|---|---|
| [tf-config-proxmox](https://gitlab.kilic.dev/infrastructure/tf-config-proxmox) | Terraform | Proxmox VMs, storage, backup and users on hypervisors `hercules`, `gulag`, `antaeus`; one `cluster-<name>.tf` per cluster (FCOS VMs tagged `cluster-<name>`) |
| [tf-config-opnsense](https://gitlab.kilic.dev/infrastructure/tf-config-opnsense) | Terraform | Routers per region (`region-thor-*`, `region-loki-*`): interfaces, DHCP, Unbound, firewall, WireGuard |
| [tf-config-cloudflare](https://gitlab.kilic.dev/infrastructure/tf-config-cloudflare) | Terraform | Public DNS, SRV records, API tokens |
| [tf-config-hetzner-cloud](https://gitlab.kilic.dev/infrastructure/tf-config-hetzner-cloud) | Terraform | Hetzner Cloud servers, networks, firewall |
| [tf-config-backblaze-b2](https://gitlab.kilic.dev/infrastructure/tf-config-backblaze-b2) | Terraform | B2 buckets and keys (Velero and etcd backups land in B2) |
| [fcos-ignition](https://gitlab.kilic.dev/infrastructure/fcos-ignition) | Butane/Ignition + image build | Fedora CoreOS ignition (`single-disk.yml`, `double-disk.yml`), built into an image by CI |
| [pulumi-config-gitlab](https://gitlab.kilic.dev/infrastructure/pulumi-config-gitlab) | Pulumi | GitLab itself: ArgoCD deploy keys (discovers `cluster/workloads` and `cluster/charts` by group, plus root/cluster repos by name), webhooks, CI pipeline variables for every IaC repo, job-token scopes, mirrors, memberships |
| [pulumi-config-vault](https://gitlab.kilic.dev/infrastructure/pulumi-config-vault) | Pulumi | Vault approles, auth, engines, groups, policies, tokens |
| [pulumi-config-vault-manual](https://gitlab.kilic.dev/infrastructure/pulumi-config-vault-manual) | Pulumi | Unverified scope (manually seeded Vault data) |
| [pulumi-config-zitadel](https://gitlab.kilic.dev/infrastructure/pulumi-config-zitadel) | Pulumi | Zitadel instance, organizations, projects, applications (SSO) |
| [pulumi-config-rustfs](https://gitlab.kilic.dev/infrastructure/pulumi-config-rustfs) | Pulumi | RustFS (S3) buckets, lifecycle, policies, replication, users |
| [pulumi-config-mailserver](https://gitlab.kilic.dev/infrastructure/pulumi-config-mailserver) | Pulumi | Mail accounts, DKIM, DNS |
| [pulumi-config-github](https://gitlab.kilic.dev/infrastructure/pulumi-config-github) | Pulumi | GitHub configuration |
| [pulumi-config-agents](https://gitlab.kilic.dev/infrastructure/pulumi-config-agents), [pulumi-config-agentgateway](https://gitlab.kilic.dev/infrastructure/pulumi-config-agentgateway) | Pulumi | Agent platform and agentgateway configuration (details Unverified) |
| Archived: `tf-config-minio-replication`, `pulumi-config-minio`, `pulumi-config-backblaze-b2` | - | Archived, not edit targets |

### cluster (top level and per-cluster subgroups)

| Repo | Tool | Role |
|---|---|---|
| [pulumi-config-rancher](https://gitlab.kilic.dev/cluster/pulumi-config-rancher) | Pulumi (`rancher2` provider), CI `preview`/`up` | Defines all six downstream clusters as Rancher `ClusterV2`: rubik, neutrino, nailbed on RKE2; overseer, sun, moon on K3s. etcd snapshots to S3 per cluster folder |
| [overseer/tf-overseer](https://gitlab.kilic.dev/cluster/overseer/tf-overseer) | Terraform (HTTP backend), CI plan/deploy | Bootstraps overseer: installs ArgoCD (Helm `argo-cd`, domain `argocd.int.kilic.dev`), Vault via vault-operator (`vault.int.kilic.dev`), vault backup, proxmox-csi-plugin |
| [argocd-root](https://gitlab.kilic.dev/cluster/argocd-root) | Pulumi as a local generator (`file://.` state, `task apply`), commits `argocd/1-manifest` and `root/1-manifest` | ArgoCD AppProjects, cluster secrets (ExternalSecret pulling server+token from Vault `overseer/argocd/clusters/<cluster>`; labels and annotations from `src/argocd/assets/cluster/<cluster>/{labels,annotations}.yml`), and the root Applications `argocd-root`, `argocd-system`, `cluster-<cluster>` |
| [argocd-system](https://gitlab.kilic.dev/cluster/argocd-system) | kustomize over ApplicationSets | One ApplicationSet per system component in `base/<c>/`, enabled per environment overlay (`development`, `platform`, `production`, `load-balancer`) with chart pins in `<env>/<c>/patch-applicationset.yaml`; cluster selection by `system.feature.kilic.dev/<c>` + `cluster.kilic.dev/environment` labels |
| [kargo-root](https://gitlab.kilic.dev/cluster/kargo-root) | kustomize, `.deploy/overseer/` | Kargo config: ClusterConfig, ClusterPromotionTasks `promote-chart-pin` / `report-chart-pin`, and one Project `kargo-argocd-system-<component>` per chart-pinned component with Warehouse and Stages `<component>.<env>` (+ `.report`) |
| `<cluster>/argocd-<cluster>` x6: [rubik](https://gitlab.kilic.dev/cluster/rubik/argocd-rubik), [neutrino](https://gitlab.kilic.dev/cluster/neutrino/argocd-neutrino), [nailbed](https://gitlab.kilic.dev/cluster/nailbed/argocd-nailbed), [overseer](https://gitlab.kilic.dev/cluster/overseer/argocd-overseer), [sun](https://gitlab.kilic.dev/cluster/sun/argocd-sun), [moon](https://gitlab.kilic.dev/cluster/moon/argocd-moon) | Pulumi as generator (NestJS, `src/`), committed output in `apps/`, `system/`, `namespaces/`, `workloads/<name>/` each under `1-manifest/`; CI only lints | Per-cluster: gateways/Cilium/namespaces (`system`, `namespaces`), ArgoCD Applications for each workload (`apps`), and on LB clusters the route manifests themselves (`workloads/`) |
| [node-patcher](https://gitlab.kilic.dev/cluster/node-patcher) | Run by hand | Patches new cluster nodes; run manually only when nodes are added |
| [pipes/argocd-pulumi-hydrator](https://gitlab.kilic.dev/cluster/pipes/argocd-pulumi-hydrator) | Go CMP (`plugin.yaml`, discovers `Pulumi.yaml`) | Would render a Pulumi program inside ArgoCD instead of committing `1-manifest/`. No live Application uses it |
| Archived: `rubik/tf-rubik`, `neutrino/tf-neutrino`, `nailbed/tf-nailbed`, `sun/tf-sun`, `moon/tf-moon` | Terraform | Archived, not edit targets |

### cluster/workloads

kustomize, one repo per application, deployment root `.deploy/<cluster>/`, `.deploy/base/` only when multi-cluster. CI renders with `devops/pipelines` `kustomize@1.2.0` (some add buildah image builds). Live mapping from ArgoCD:

| Repo | Cluster(s) | Deployed by |
|---|---|---|
| [monitoring](https://gitlab.kilic.dev/cluster/workloads/monitoring), [monitoring-ruler](https://gitlab.kilic.dev/cluster/workloads/monitoring-ruler) | all six | `argocd-system` ApplicationSets (not a cluster repo); no chart pin, no Kargo |
| [monitoring-backbone](https://gitlab.kilic.dev/cluster/workloads/monitoring-backbone), [monitoring-view](https://gitlab.kilic.dev/cluster/workloads/monitoring-view) | rubik | `argocd-rubik` |
| [gose](https://gitlab.kilic.dev/cluster/workloads/gose), [seafile](https://gitlab.kilic.dev/cluster/workloads/seafile), [mailserver](https://gitlab.kilic.dev/cluster/workloads/mailserver), [notifications](https://gitlab.kilic.dev/cluster/workloads/notifications), [obsidian](https://gitlab.kilic.dev/cluster/workloads/obsidian), [rustfs](https://gitlab.kilic.dev/cluster/workloads/rustfs) (main, cache, warehouse), [sourcebot](https://gitlab.kilic.dev/cluster/workloads/sourcebot), [teamspeak3](https://gitlab.kilic.dev/cluster/workloads/teamspeak3), [gitlab-runner](https://gitlab.kilic.dev/cluster/workloads/gitlab-runner), [gitlab-tools](https://gitlab.kilic.dev/cluster/workloads/gitlab-tools), [html-cv3](https://gitlab.kilic.dev/cluster/workloads/html-cv3), [html-listr2](https://gitlab.kilic.dev/cluster/workloads/html-listr2), [html-nurankilic](https://gitlab.kilic.dev/cluster/workloads/html-nurankilic) | rubik | `argocd-rubik` |
| [agents](https://gitlab.kilic.dev/cluster/workloads/agents), [atuin](https://gitlab.kilic.dev/cluster/workloads/atuin), [home-assistant](https://gitlab.kilic.dev/cluster/workloads/home-assistant), [immich](https://gitlab.kilic.dev/cluster/workloads/immich), [ollama](https://gitlab.kilic.dev/cluster/workloads/ollama), [paperless-ngx](https://gitlab.kilic.dev/cluster/workloads/paperless-ngx), [showmen](https://gitlab.kilic.dev/cluster/workloads/showmen) | neutrino | `argocd-neutrino` |
| [zitadel](https://gitlab.kilic.dev/cluster/workloads/zitadel) | overseer | `argocd-overseer` (AppProject `platform`) |
| [nailbed](https://gitlab.kilic.dev/cluster/workloads/nailbed) | nailbed | `argocd-nailbed` (demo-cnpg, demo-nginx; second source) |
| [renovate-runner](https://gitlab.kilic.dev/renovate/renovate-runner) (group `renovate`, not `cluster/workloads`) | rubik | `argocd-rubik` (`rubik-renovate`, `rubik-renovate-operator`) |
| Archived: `vouch` | - | - |

### cluster/charts

~30 repos `chart-<component>`, CI `helm@2.0.1` + `semantic-release@2.3.1`, tags `v<semver>`. Archived: `chart-keel`, `chart-kagent`, `chart-ark`, `helm-charts-system`. `chart-rabbitmq-operator` exists but no ApplicationSet references it. `chart-external-dns` backs three components (`external-dns-cloudflare`, `external-dns-opnsense-loki`, `external-dns-opnsense-thor`).

### ansible

| Repo | Role |
|---|---|
| [ansible-playbooks](https://gitlab.kilic.dev/ansible/ansible-playbooks) | `./play` wrapper. `provision/<area>/` (OS, users, ssh, podman, `cluster` node prep), `containers/<name>/deploy.yml` (podman services), `setup/<name>/`; `inventory.ini` is the host inventory for the whole estate |
| [ansible-roles](https://gitlab.kilic.dev/ansible/ansible-roles) | Shared roles, semantic-release |
| [cluster-setup](https://gitlab.kilic.dev/ansible/cluster-setup) | Local k3d/kind developer clusters. Not part of the live estate |

Core services run by ansible as containers:

| Container playbook | Hosts |
|---|---|
| `containers/gitlab` | `gitlab` (the GitLab server itself) |
| `containers/rancher` | `rancher` (Rancher manager VM) |
| `containers/netboot`, `containers/ignition` | `netboot` (PXE/ignition serving for FCOS) |
| `containers/headscale`, `containers/tailscale` | `trojan-thor`, `trojan-loki` |
| `containers/caddy` | group `webserver` |
| `containers/rclone`, `containers/seafile-cli` | `norsu` (NAS) |
| `setup/hermes` | `labrat.hermes` |
| `provision/cluster` | group `cluster` (all Kubernetes nodes) |

---

## Flow

### End to end

```
1. Network + hardware      infrastructure/tf-config-opnsense, tf-config-proxmox, tf-config-hetzner-cloud, tf-config-cloudflare
2. Hosts                   infrastructure/fcos-ignition (+ ansible containers/netboot, ignition) boot FCOS VMs
                           ansible/ansible-playbooks provision/* prepares hosts; containers/* runs GitLab, Rancher, headscale, caddy
3. Clusters                cluster/pulumi-config-rancher -> Rancher ClusterV2 (rke2 / k3s) for all six clusters
4. Platform bootstrap      cluster/overseer/tf-overseer -> ArgoCD + Vault on overseer
5. Platform config         infrastructure/pulumi-config-vault, pulumi-config-gitlab (deploy keys, webhooks), pulumi-config-zitadel
6. GitOps root             cluster/argocd-root (generated) -> AppProjects, cluster secrets, Applications:
                             argocd-root, argocd-system, cluster-<cluster> x6
7a. System components      cluster/argocd-system ApplicationSets x labels in argocd-root assets
                             -> cluster-<cluster>-system-<component> from cluster/charts/chart-<c>@<pin>
7b. Pin promotion          cluster/kargo-root Stages promote the chart pin through envs by committing to argocd-system
8. Per-cluster             cluster-<cluster> app -> argocd-<cluster>/apps -> cluster-<cluster>-system, -namespaces,
                             and <cluster>-<workload> Applications
9. Workloads               <cluster>-<workload> -> cluster/workloads/<workload>/.deploy/<cluster>
10. Exposure               LB clusters sun (loki) and moon (thor) route to downstream clusters and VMs
                             via their own argocd-<lb>/workloads/<cluster-x|vm-x|routes>
```

### Change paths

| I want to change | Edit | What ships it |
|---|---|---|
| A VM, disk, VLAN, firewall, DNS record | `infrastructure/tf-config-*` | MR pipeline plans; the deploy job on main is manual |
| GitLab, Vault, Zitadel, RustFS, mail config | `infrastructure/pulumi-config-*` | pipeline `preview`, then a manual `up` on main |
| A cluster's Kubernetes version or node config | `cluster/pulumi-config-rancher` | pipeline `preview`, manual `up`, Rancher reconciles |
| ArgoCD or Vault install on overseer | `cluster/overseer/tf-overseer` | Terraform pipeline |
| Which system components a cluster gets, per-cluster values | `cluster/argocd-root/src/argocd/assets/cluster/<c>/{labels,annotations}.yml` then regenerate and commit `argocd/1-manifest` | ArgoCD `argocd-root` app (auto, prune off) |
| A system component's fleet or per-env values | `cluster/argocd-system/{base,<env>}/<c>/values.yaml` | ArgoCD `argocd-system` app |
| A pipeline's template or pipe CLI | `devops/pipelines` (template) or `devops/pipes` (CLI), per `kilic-ci-pipelines` | release tag on that package; each consumer picks it up when it bumps its `ref` |
| A system component's chart | `cluster/charts/chart-<c>`, release tag; Kargo writes the pin, the first one included | Kargo Stage commits pin -> ArgoCD |
| Add a workload's Application or namespace | `cluster/<c>/argocd-<c>/src/workloads/<name>/` then regenerate `apps/1-manifest` | ArgoCD `cluster-<c>` app |
| A workload's manifests | `cluster/workloads/<w>/.deploy/<cluster>/` | ArgoCD `<cluster>-<w>` app, `targetRevision: HEAD`, automated prune |
| Public route for a workload | `cluster/<lb>/argocd-<lb>` (sun or moon) | ArgoCD `<lb>-cluster-<c>` / `<lb>-routes` |
| A legacy/core server or its container | `ansible/ansible-playbooks` | `./play ...`, run locally or from CI |

### ArgoCD topology (single instance)

- ArgoCD runs on **overseer** (in-cluster destination `https://kubernetes.default.svc`). All other clusters register through the Rancher proxy `https://rancher.int.kilic.dev/k8s/clusters/<id>`.
- Application naming: root `argocd-root`, `argocd-system`, `cluster-<c>`; per cluster `cluster-<c>-system`, `cluster-<c>-namespaces`; system components `cluster-<c>-system-<component>`; workloads `<c>-<workload>`; platform exceptions without prefix: `zitadel`, `kargo-root`.
- AppProjects: `default`, `argocd`, `argocd-apps`, `platform`, `kargo`, and per cluster `cluster-<c>`, `cluster-<c>-system`, `cluster-<c>-operator`, `cluster-<c>-pv`.
- Sync, prune and Kargo mechanics: `argocd-kilic`.

---

## Clusters

| Cluster | Distro (Rancher) | ArgoCD env label | Region | Nodes (inventory) | Runs | Bootstrapped / configured by |
|---|---|---|---|---|---|---|
| overseer | K3s | platform | thor (VMs on `hercules`); the `cluster.kilic.dev/region: loki` label in `argocd-root/src/argocd/assets/cluster/overseer/labels.yml` is wrong, and nothing reads it | overseer-03..05, seer-04..07 | ArgoCD, Vault, Kargo, Argo Rollouts, Zitadel, kargo-root, system components | `tf-config-proxmox` (VMs), `pulumi-config-rancher`, `tf-overseer` (ArgoCD, Vault), `argocd-overseer` |
| rubik | RKE2 | production | loki (VMs on `antaeus`, Hetzner) | rubik-04..06, qubit-07..11 | Most user-facing workloads, rustfs, monitoring backbone/view, grafana-operator, renovate, gitlab-runner | `tf-config-proxmox`, `pulumi-config-rancher`, `argocd-rubik` |
| neutrino | RKE2 | production | thor | neutrino-03..05, electron-06..11 | GPU/home workloads (ollama, immich, home-assistant, agents, paperless-ngx), nvidia-operator, agentgateway | same pattern, `argocd-neutrino` |
| nailbed | RKE2 | development | thor | nailbed-01..03 | Development/demo workloads | same pattern, `argocd-nailbed` |
| sun | K3s | load-balancer | loki | sun-02 | Gateways, external-dns (Cloudflare + OPNsense), routes to rubik, gitlab VM, trojan-loki | same pattern, `argocd-sun` |
| moon | K3s | load-balancer | thor | moon-02 | Gateways, external-dns, routes to nailbed, neutrino, overseer, trojan-thor | same pattern, `argocd-moon` |
| rancher (manager) | Unverified | not in ArgoCD | thor | `rancher` VM | Rancher server (podman via ansible `containers/rancher`) | `ansible-playbooks`, `tf-config-proxmox` (`hercules-vm-rancher.tf`) |

Label sources: `cluster.kilic.dev/{environment,region,name}` from `cluster/argocd-root/src/argocd/assets/cluster/<c>/labels.yml`, confirmed live via ArgoCD `list_clusters`.

## Regions and Core Hosts

### Regions

Two regions, each with its own OPNsense router, joined by a site-to-site WireGuard tunnel. The tunnel and each region's interfaces, DHCP, Unbound, firewall and aliases live in [tf-config-opnsense](https://gitlab.kilic.dev/infrastructure/tf-config-opnsense) as `region-<region>-*.tf`, with one provider alias per router.

| Region | Where | Hypervisors ([tf-config-proxmox](https://gitlab.kilic.dev/infrastructure/tf-config-proxmox)) | Internal domain | Router VM |
|---|---|---|---|---|
| **thor** | home | `hercules`, `gulag` | `thor.arpa` | `THOR` on gulag (`router-thor.tf`) |
| **loki** | remote, Hetzner | `antaeus` (dedicated server) | `loki.arpa` | `LOKI` on antaeus (`router-loki.tf`) |

**loki extends into Hetzner Cloud.** [tf-config-hetzner-cloud](https://gitlab.kilic.dev/infrastructure/tf-config-hetzner-cloud) runs extra servers, `qubit-eNN` (`hcloud_server.rubik_qubit`, `fsn1`) as additional rubik nodes. They sit on the `loki` Hetzner network and join the loki router over its `loki-vswitch` WireGuard server; their peer keys are in Vault under `terraform/hetzner/wireguard/clients/*`.

`tf-config-proxmox` files follow the host: `<hypervisor>-vm-<name>.tf` for a standalone VM, `<hypervisor>-{backup,storage,users}.tf` for the hypervisor itself, and `cluster-<c>.tf`, `router-<region>.tf` and `nas-<name>.tf` by role. Each file's `provider = proxmox.<hypervisor>` says which host it lands on.

### Core / legacy hosts

**Core** means everything that is not a Kubernetes workload: standalone servers and the machines the clusters run on. Terraform creates them in `tf-config-proxmox` (and `tf-config-hetzner-cloud`). [ansible-playbooks](https://gitlab.kilic.dev/ansible/ansible-playbooks) provisions them and runs their services as podman containers. `core` in Grafana datasource names (`mimir-core`, `loki-core`) is this host estate, not a cluster.

| Role | Host | Region / hypervisor | Defined by |
|---|---|---|---|
| Hypervisors | hercules, gulag | thor | physical; config in `hercules-*.tf`, `gulag-*.tf` |
| | antaeus | loki (Hetzner) | physical; `antaeus-*.tf` |
| | pdm (Proxmox Datacenter Manager) | thor, hercules | `hercules-vm-pdm.tf` |
| Routers | THOR, LOKI (OPNsense) | gulag, antaeus | `router-*.tf` + `tf-config-opnsense` |
| NAS | norsu | thor, hercules | `nas-norsu.tf`; ansible `containers/{rclone,seafile-cli}` |
| | pukki | loki, antaeus | `nas-pukki.tf` |
| Servers | gitlab | loki, antaeus | `antaeus-vm-gitlab.tf`; ansible `containers/gitlab` |
| | netboot (PXE / FCOS ignition) | loki, antaeus | `antaeus-vm-netboot.tf`; ansible `containers/{netboot,ignition}` |
| | rancher (Rancher manager) | thor, hercules | `hercules-vm-rancher.tf`; ansible `containers/rancher` |
| Edge / VPN | trojan-thor, trojan-loki (headscale/tailscale) | gulag, antaeus | `*-vm-trojan-*.tf`; ansible `containers/{headscale,tailscale}` |
| Decommissioning | orbitar | loki, antaeus | `antaeus-vm-orbitar.tf`; being removed, not a target for new work |
| | vega, mountain2, showmen | thor, hercules | `hercules-vm-*.tf`; being removed, not a target for new work |
| | labrat (agent workstation) | thor, gulag | `gulag-vm-labrat.tf`; ansible `setup/hermes` |
| Cluster nodes | see Clusters | per cluster | `cluster-<c>.tf`; ansible `provision/cluster` |
| Workstations | mau5, bat | - | ansible inventory only |

Cluster node placement from `cluster-<c>.tf`: rubik on antaeus (loki) plus the Hetzner Cloud `qubit-e*` nodes; sun on antaeus (loki); overseer, neutrino and nailbed on hercules (thor); moon on gulag (thor).

---

## Extending this file

Keep the headings (Groups, Flow, Clusters, Regions and Core Hosts) so every `structure-<estate>` skill lines up. Add a group as a row in the Groups summary and, if it has more than three live repos, its own sub-table. Link repos only by `web_url` from `get_project` or `list_group_projects`.
