# TCPRoute Pattern (Custom Port)

Gateway listener, Backend, TCPRoute, and CNAME DNS for a TCP service on a dedicated gateway port.

For TCP services (SMTP, databases, etc.) that need a dedicated port on the gateway:

```typescript
// 1. Add a listener to the gateway for the TCP port
this.clusterGateway.listen(
  ClusterGateways.DEFAULT,  // or INTERNAL
  this.gateway.createGatewayListeners({
    type: GatewayListenerProtocol.TCP,
    name: '<service-name>',
    port: <port>,
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

// 2. Create Backend with the TCP port
const tcpBackend = this.envoy.newBackend(
  '<service-name>',
  {
    endpoints: [{ fqdn: { hostname: '<target>.lb.int.loki.arpa', port: <port> } }]
  },
  { provider: this.provider }
)

// 3. Create TCPRoute referencing the specific listener section
// sectionName format: tcp-<name>-<port>
this.gateway.newTCPRoute(
  '<service-name>',
  {
    parentRefs: [{ ...defaultGateway, sectionName: 'tcp-<service-name>-<port>' }],
    backendRef: tcpBackend
  },
  { provider: this.provider }
)

// 4. DNS — TCP can't be Cloudflare-proxied, use CNAME to WAN endpoint
this.gateway.newDNSEndpoint(
  '<service-name>',
  {
    labels: { 'provider.kilic.dev/external-dns-cloudflare': 'true' },
    endpoints: [
      {
        dnsName: '<service>.kilic.dev',
        recordType: 'CNAME',
        targets: ['loki.kilic.dev']
      }
    ]
  },
  { provider: this.provider }
)
```
