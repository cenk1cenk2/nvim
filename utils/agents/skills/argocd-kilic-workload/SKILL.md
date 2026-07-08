---
name: argocd-kilic-workload
description: Create a new workload service in the current cluster's ArgoCD repository. Scaffolds the Pulumi service, registers it in the workloads module, and optionally configures gateway listeners. Always manually invoked. Do NOT use for LB routing (/argocd-kilic-loadbalancer), standalone workload repos (/cluster-kilic-workload), or Helm chart wrappers (/cluster-kilic-chart).
disable-model-invocation: true
argument-hint: "[workload-name] - e.g., 'my-app', 'html-cv3', 'notifications'"
references:
  - ../references/present-first.md
---

## Cluster Workload Creator

> **IMPORTANT: This skill assumes you are already inside a cluster ArgoCD repository** (e.g., `cluster/rubik/argocd-kilic-rubik`).

> **Present-first.** Read the `present-first` reference — do not enter plan mode; draft and present before writing, and proceed on approval or upfront blessing.

## How This Repository Works

This is a NestJS + Pulumi monorepo that generates Kubernetes manifests. When Pulumi runs, it executes all registered services which output YAML manifests to `workloads/*/1-manifest/`. ArgoCD watches this repo and syncs those manifests to the cluster.

Key files:
- **`src/constants.ts`** — Cluster identity: `ARGOCD_REPOSITORY`, `ARGOCD_CLUSTER`, `ArgoCDProjects`, `ClusterDomains`
- **`src/cluster/cluster.constants.ts`** — Gateway enum names and IPs (varies per cluster)
- **`src/workloads/workloads.module.ts`** — NestJS module registering all workload services
- **`src/workloads/<workload>/<workload>.service.ts`** — Individual workload Pulumi service

## Gather Requirements

Ask the user:

- **Workload name:** e.g., `my-app`
- **Workload repo:** The GitLab repo containing the Kubernetes manifests (e.g., `cluster/workloads/<workload>`)
- **Gateway listener needed?** Does it need an HTTPS/TCP listener on the cluster gateway? If yes, what hostname/subdomain?
- **Resource quota needed?** Only if the user explicitly requests it. What CPU/memory limits?

## Research Phase (MANDATORY)

**BEFORE writing any code**, read these files from the current repository:

1. **`src/constants.ts`** — Note `ArgoCDProjects`, `ARGOCD_CLUSTER`, `ClusterDomains`
2. **`src/cluster/cluster.constants.ts`** — Note `ClusterGateways` enum values (e.g., rubik uses `KILIC_DEV`, sun uses `DEFAULT`/`INTERNAL`)
3. **`src/workloads/workloads.module.ts`** — See current registrations
4. **A similar existing workload service** — Use as the template

This is mandatory because **each cluster has different constants and gateway names**.

## Workload Service Pattern

**Simple workload (no gateway):**

```typescript
import {
  ArgoCDService,
  InjectArgoCDService,
  InjectStandardsService,
  InjectWorkloadsService,
  K8sProvider,
  StandardsService,
  Workload,
  WorkloadsService
} from '@kilic.dev/pulumi-k8s'
import { Inject, Injectable, OnModuleInit } from '@nestjs/common'

import { ARGOCD_CLUSTER, ARGOCD_NAMESPACE_SETUP, ARGOCD_NAMESPACE_TRANSFORMS, ArgoCDProjects } from '@constants'
import { ARGOCD_APPLICATION_PROVIDER, ARGOCD_NAMESPACE_PROVIDER } from '@root/module.constants'

@Injectable()
export class MyWorkloadService implements OnModuleInit {
  constructor(
    @InjectStandardsService() private readonly standards: StandardsService,
    @InjectWorkloadsService() private readonly workloads: WorkloadsService,
    @InjectArgoCDService() private readonly argocd: ArgoCDService,
    @Inject(ARGOCD_APPLICATION_PROVIDER) private readonly provider: K8sProvider,
    @Inject(ARGOCD_NAMESPACE_PROVIDER) private readonly ns: K8sProvider
  ) {}

  public async onModuleInit(): Promise<void> {
    const workload = this.workloads.create({
      name: '<workload-name>'
    })

    await this.deploy(workload)
  }

  public async deploy(workload: Workload): Promise<void> {
    this.argocd.newNamespace(
      workload.namespace,
      {
        metadata: {
          name: workload.namespace
        }
      },
      {
        provider: this.ns,
        transforms: ARGOCD_NAMESPACE_TRANSFORMS
      },
      ARGOCD_NAMESPACE_SETUP
    )

    this.argocd.newApplication(
      workload.name,
      {
        metadata: {
          name: workload.stagedName()
        },
        spec: {
          destination: {
            name: ARGOCD_CLUSTER,
            namespace: workload.namespace
          },
          project: ArgoCDProjects.CLUSTER,
          sources: [
            {
              repoURL: 'git@gitlab.kilic.dev:cluster/workloads/<workload>.git',
              targetRevision: 'HEAD',
              path: this.standards.stagedDeploymentPath(),
              kustomize: {
                namespace: workload.namespace
              }
            }
          ]
        }
      },
      { provider: this.provider }
    )
  }
}
```

**With gateway listener** — add these on top of the simple pattern:

```typescript
// Additional imports:
import { splat } from '@kilic.dev/pulumi-bootstrap'
import {
  GatewayAPIService,
  GatewayListenerProtocol,
  InjectGatewayAPIService,
  K8sLabels,
  K8sMatchExpressions
} from '@kilic.dev/pulumi-k8s'
import { ClusterGateways } from '@cluster/cluster.constants'
import { ClusterGatewayService } from '@cluster/gateway.service'
import { ClusterDomains } from '@constants'

// Additional constructor injections:
@InjectGatewayAPIService() private readonly gateway: GatewayAPIService,
@Inject(ClusterGatewayService) private readonly clusterGateway: ClusterGatewayService,

// At the end of deploy():
this.clusterGateway.listen(
  ClusterGateways.KILIC_DEV,  // ← check cluster.constants.ts for correct value
  this.gateway.createGatewayListeners({
    type: GatewayListenerProtocol.HTTPS,
    hostname: splat('<subdomain>.%s', ClusterDomains.KILIC_DEV),
    terminate: true,
    allowedRoutes: {
      namespaces: {
        from: 'Selector',
        selector: {
          matchExpressions: [
            {
              key: K8sLabels.METADATA_NAME,
              operator: K8sMatchExpressions.IN,
              values: [workload.namespace]
            }
          ]
        }
      }
    }
  })
)
```

**With resource quota** (only when explicitly requested by user) — add after namespace creation, before `newApplication()`:

```typescript
// Additional import:
import * as k8s from '@pulumi/kubernetes'

// After namespace creation, before newApplication():
new k8s.core.v1.ResourceQuota(
  workload.name,
  {
    metadata: {
      name: workload.name
    },
    spec: {
      hard: {
        ['limits.cpu']: '<cpu>',       // e.g., '4'
        ['limits.memory']: '<memory>'  // e.g., '12Gi'
      }
    }
  },
  { provider: workload.provider() }
)
```

## Registration

After creating the service, register it in `src/workloads/workloads.module.ts`:

1. Add import: `import { MyWorkloadService } from './<workload>/<workload>.service'`
2. Add to `providers` array

## Checklist

- [ ] Read `src/constants.ts` and `src/cluster/cluster.constants.ts`
- [ ] Read a similar existing workload as reference
- [ ] Create `src/workloads/<workload>/<workload>.service.ts`
- [ ] Register in `src/workloads/workloads.module.ts`
- [ ] If gateway: use correct `ClusterGateways` and `ClusterDomains` for this cluster
- [ ] Service class name follows PascalCase (e.g., `HtmlCv3Service`, `GitlabRunnerService`)
- [ ] If resource quota explicitly requested: add `ResourceQuota` after namespace creation with correct limits.
- [ ] Match code style from the reference workload.
