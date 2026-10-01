# Workload ExternalSecret (Vault)

ExternalSecret shapes for pulling workload secrets from Vault. Read when the workload needs any secret.

All secrets come from Vault via `ClusterSecretStore: secret.vault.int.kilic.dev`. Vault path convention: `<cluster>/<workload>/<component>`.

**Simple extract (all keys from one Vault path):**

```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: <secret-name>
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: secret.vault.int.kilic.dev
  target:
    name: <secret-name>
    deletionPolicy: Delete
  dataFrom:
    - extract:
        conversionStrategy: Default
        decodingStrategy: None
        metadataPolicy: None
        key: <cluster>/<workload>/<component>
```

**Templated (remap keys to env vars):**

```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: <secret-name>
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: secret.vault.int.kilic.dev
  target:
    name: <secret-name>
    deletionPolicy: Delete
    template:
      data:
        APP_ACCESS_KEY: "{{ .username }}"
        APP_SECRET_KEY: "{{ .password }}"
        APP_ENDPOINT: "{{ .endpoint }}"
  dataFrom:
    - extract:
        key: <cluster>/<workload>/<component>
```

**Individual key references:**

```yaml
spec:
  data:
    - secretKey: OAUTH_CLIENT_ID
      remoteRef:
        key: <cluster>/<workload>/sso
        property: client_id
    - secretKey: OAUTH_CLIENT_SECRET
      remoteRef:
        key: <cluster>/<workload>/sso
        property: client_secret
```
