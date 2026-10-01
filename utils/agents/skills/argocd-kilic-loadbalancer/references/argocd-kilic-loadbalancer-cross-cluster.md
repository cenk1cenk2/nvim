# Cross-Cluster Routing Pattern (`cluster-<target>`)

L2 announcement flow and the service template for a `cluster-<target>` workload that routes LB traffic to a target cluster gateway.

## L2 Announcements

Target cluster gateways have L2-announced IPs (via Cilium LB-IPAM). The LB cluster needs to know these IPs to route traffic. The flow:

1. Target cluster gateway has a Cilium LB-IPAM IP (e.g., rubik kilic.dev gateway = `192.168.195.16`)
2. LB cluster creates a **DNSEndpoint** registering that IP as `cluster-<target>-gateway-<slug>.lb.int.loki.arpa` in OPNSense (loki)
3. LB cluster creates an **Envoy Backend** pointing to that FQDN
4. LB cluster creates **TLSRoute/HTTPRoute/TCPRoute** referencing the Backend

The LB cluster's own gateways also have L2-announced IPs registered in OPNSense (handled by `gateway.service.ts`, not by workload services):
- `cluster-<lb>-gateway-default.lb.int.loki.arpa` → DEFAULT gateway IP
- `cluster-<lb>-gateway-internal.lb.int.loki.arpa` → INTERNAL gateway IP

## Service Template

```typescript
import {
  ArgoCDService,
  EnvoyGatewayService,
  GatewayAPIService,
  GatewayListenerProtocol,
  InjectArgoCDService,
  InjectEnvoyGatewayService,
  InjectGatewayAPIService,
  InjectStandardsService,
  InjectWorkloadsService,
  K8sLabels,
  K8sMatchExpressions,
  K8sProvider,
  StandardsService,
  Workload,
  WorkloadsService
} from '@kilic.dev/pulumi-k8s'
import { Inject, Injectable, OnModuleInit } from '@nestjs/common'

import { ClusterGateways } from '@cluster/cluster.constants'
import { ClusterGatewayService } from '@cluster/gateway.service'
import { ARGOCD_CLUSTER, ARGOCD_NAMESPACE_SETUP, ARGOCD_NAMESPACE_TRANSFORMS, ARGOCD_REPOSITORY, ArgoCDProjects, ENVOY_GATEWAY_POLICY_LABEL_ENABLED, EnvoyGatewayPolicyLabels } from '@constants'
import { ARGOCD_APPLICATION_PROVIDER, ARGOCD_NAMESPACE_PROVIDER } from '@root/module.constants'

@Injectable()
export class ClusterTargetService implements OnModuleInit {
  constructor(
    @InjectStandardsService() private readonly standards: StandardsService,
    @InjectWorkloadsService() private readonly workloads: WorkloadsService,
    @InjectArgoCDService() private readonly argocd: ArgoCDService,
    @InjectGatewayAPIService() private readonly gateway: GatewayAPIService,
    @InjectEnvoyGatewayService() private readonly envoy: EnvoyGatewayService,
    @Inject(ClusterGatewayService) private readonly clusterGateway: ClusterGatewayService,
    @Inject(ARGOCD_APPLICATION_PROVIDER) private readonly provider: K8sProvider,
    @Inject(ARGOCD_NAMESPACE_PROVIDER) private readonly ns: K8sProvider
  ) {}

  public async onModuleInit(): Promise<void> {
    const workload = this.workloads.create({
      name: 'cluster-<target>'
    })

    await this.deploy(workload)
  }

  public async deploy(workload: Workload): Promise<void> {
    this.argocd.newNamespace(/* ... */)
    this.argocd.newApplication(/* ... using ARGOCD_REPOSITORY */)

    // BackendTrafficPolicy for the workload
    this.clusterGateway.reflect(workload)

    // L2 announcement DNSEndpoint (register target cluster gateway IP in OPNSense)
    this.gateway.newDNSEndpoint(
      '<target>-gateway-<domain-slug>-l2-announcement',
      {
        labels: {
          'provider.kilic.dev/external-dns-opnsense-loki': 'true'
        },
        endpoints: [
          {
            dnsName: 'cluster-<target>-gateway-<domain-slug>.lb.int.loki.arpa',
            recordTTL: 300,
            recordType: 'A',
            targets: ['<gateway-ip>'],
            providerSpecific: [
              {
                name: 'external-dns.alpha.kubernetes.io/opnsense-description',
                value: '[<lb-cluster>] cluster <target> gateway l2 announcement for <domain>'
              }
            ]
          }
        ]
      },
      { provider: this.provider }
    )

    // Backend pointing to target cluster gateway FQDN
    const backend = this.envoy.newBackend(
      '<target>-gateway',
      {
        endpoints: [{ fqdn: { hostname: 'cluster-<target>-gateway-<domain-slug>.lb.int.loki.arpa' } }],
        appProtocols: ['gateway.envoyproxy.io/h2c']
      },
      { provider: this.provider }
    )

    // Get gateway references
    const defaultGateway = this.clusterGateway.reference(ClusterGateways.DEFAULT)
    const internalGateway = this.clusterGateway.reference(ClusterGateways.INTERNAL)

    // External TLSRoute — Cloudflare-proxied (for HTTP(S) services)
    this.gateway.newTLSRoute(
      '<target>-external',
      {
        labels: {
          ...ENVOY_GATEWAY_POLICY_LABEL_ENABLED,
          [EnvoyGatewayPolicyLabels.BACKEND_TRAFFIC_POLICY_PROXY_PROTOCOL_V2]: 'true',
          'provider.kilic.dev/external-dns-cloudflare': 'true'
        },
        annotations: {
          'external-dns.alpha.kubernetes.io/cloudflare-proxied': 'true'
        },
        hostnames: ['cenk.kilic.dev', 'sync.kilic.dev'],
        backendRef: backend
      },
      ClusterGateways.DEFAULT,
      { provider: this.provider }
    )

    // External TLSRoute — Cloudflare direct / un-proxied (for S3, wildcards, etc.)
    // No cloudflare-proxied annotation → grey cloud in Cloudflare
    this.gateway.newTLSRoute(
      '<target>-external-direct',
      {
        labels: {
          ...ENVOY_GATEWAY_POLICY_LABEL_ENABLED,
          [EnvoyGatewayPolicyLabels.BACKEND_TRAFFIC_POLICY_PROXY_PROTOCOL_V2]: 'true',
          'provider.kilic.dev/external-dns-cloudflare': 'true'
        },
        hostnames: ['s3.kilic.dev', '*.s3.kilic.dev'],
        backendRef: backend
      },
      ClusterGateways.DEFAULT,
      { provider: this.provider }
    )

    // Internal TLSRoute — NO DNS labels on the route itself
    // Internal DNS is handled via separate OPNSense DNSEndpoints per `argocd-kilic-loadbalancer-dns`
    this.gateway.newTLSRoute(
      '<target>-internal',
      {
        labels: {
          ...ENVOY_GATEWAY_POLICY_LABEL_ENABLED,
          [EnvoyGatewayPolicyLabels.BACKEND_TRAFFIC_POLICY_PROXY_PROTOCOL_V2]: 'true'
        },
        hostnames: ['<target>.int.kilic.dev', '*.<target>.int.kilic.dev'],
        backendRef: backend
      },
      ClusterGateways.INTERNAL,
      { provider: this.provider }
    )
  }
}
```
