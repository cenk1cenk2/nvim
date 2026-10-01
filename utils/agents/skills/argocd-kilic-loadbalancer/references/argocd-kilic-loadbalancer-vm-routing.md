# VM/Host Routing Pattern (`vm-<name>`)

Service template for a `vm-<name>` workload that routes external traffic to a VM or host FQDN.

```typescript
// Same imports as the cross-cluster pattern (`argocd-kilic-loadbalancer-cross-cluster`), but typically simpler — external-only routing

@Injectable()
export class VmNameService implements OnModuleInit {
  // Same constructor injections

  public async deploy(workload: Workload): Promise<void> {
    this.argocd.newNamespace(/* ... */)
    this.argocd.newApplication(/* ... using ARGOCD_REPOSITORY */)

    this.clusterGateway.reflect(workload)

    // Backend pointing to VM FQDN
    const backend = this.envoy.newBackend(
      '<vm-name>',
      {
        endpoints: [{ fqdn: { hostname: '<vm-name>.loki.arpa' } }]
      },
      { provider: this.provider }
    )

    // External TLSRoute with Cloudflare DNS
    this.gateway.newTLSRoute(
      '<vm-name>',
      {
        labels: {
          ...ENVOY_GATEWAY_POLICY_LABEL_ENABLED,
          'provider.kilic.dev/external-dns-cloudflare': 'true'
        },
        annotations: {
          'external-dns.alpha.kubernetes.io/cloudflare-proxied': 'true'
        },
        hostnames: ['service.kilic.dev', 'other.kilic.dev'],
        backendRef: backend
      },
      ClusterGateways.DEFAULT,
      { provider: this.provider }
    )
  }
}
```
