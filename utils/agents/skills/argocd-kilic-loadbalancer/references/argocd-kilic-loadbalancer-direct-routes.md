# Direct Routes Pattern (`routes`)

HTTPRoute template for routes the LB cluster handles itself, such as domain redirects, with no Backend.

```typescript
// For routes handled directly by the LB cluster (e.g., redirects)
// No Backend needed — uses HTTPRoute instead of TLSRoute

this.gateway.newHTTPRoute(
  'redirect-name',
  {
    labels: {
      ...ENVOY_GATEWAY_POLICY_LABEL_ENABLED,
      'provider.kilic.dev/external-dns-cloudflare': 'true'
    },
    annotations: {
      'external-dns.alpha.kubernetes.io/cloudflare-proxied': 'true'
    },
    hostnames: ['old.kilic.dev'],
    rules: [
      {
        filters: [
          {
            type: 'RequestRedirect',
            requestRedirect: {
              hostname: 'new.kilic.dev',
              statusCode: 301
            }
          }
        ]
      }
    ]
  },
  ClusterGateways.DEFAULT,
  { provider: this.provider }
)
```
