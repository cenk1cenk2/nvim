# Workload SSO/OIDC

Gateway-level and application-level OIDC against Zitadel. Read when the workload needs SSO.

Two approaches depending on whether the application natively supports OIDC:

**1. Gateway-level OIDC (SecurityPolicy)** — when the app does NOT support OIDC natively. Envoy Gateway handles authentication before traffic reaches the app.

```yaml
apiVersion: gateway.envoyproxy.io/v1alpha1
kind: SecurityPolicy
metadata:
  name: <workload>-oidc
spec:
  oidc:
    clientID: "<zitadel-client-id>"
    clientSecret:
      kind: Secret
      name: sso-<workload> # ← from ExternalSecret
      group: ""
    provider:
      issuer: https://sso.kilic.dev
  targetRefs:
    - group: gateway.networking.k8s.io
      kind: HTTPRoute
      name: <workload>
```

With corresponding ExternalSecret for the SSO client secret:

```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: sso-<workload>
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: secret.vault.int.kilic.dev
  target:
    name: sso-<workload>
    deletionPolicy: Delete
    template:
      data:
        client-id: "{{ .client_id }}"
        client-secret: "{{ .client_secret }}"
  dataFrom:
    - extract:
        key: <cluster>/<workload>/sso
```

**2. Application-level OIDC** — when the app supports OIDC configuration via env vars or config files. Pass credentials via ExternalSecret, configure in app's values/config.

Vault path: `<cluster>/<workload>/sso` with keys: `client_id`, `client_secret`, `discovery_url`.

The SSO provider is always **Zitadel** at `https://sso.kilic.dev`.
