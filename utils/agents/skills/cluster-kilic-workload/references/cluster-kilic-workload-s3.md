# Workload S3 Credentials

The templated ExternalSecret for S3 bucket credentials. Read when the workload uses S3 storage.

Always via ExternalSecret with templated key mapping. Vault path: `<cluster>/<workload>/s3`.

```yaml
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: s3-<workload>
spec:
  secretStoreRef:
    kind: ClusterSecretStore
    name: secret.vault.int.kilic.dev
  target:
    name: s3-<workload>
    deletionPolicy: Delete
    template:
      data:
        ACCESS_KEY: "{{ .username }}"
        SECRET_KEY: "{{ .password }}"
        ENDPOINT: "{{ .endpoint }}"
        BUCKET: "{{ .bucket }}"
        REGION: "{{ .region }}"
  dataFrom:
    - extract:
        key: <cluster>/<workload>/s3
```

Adjust the template key names to match what the application expects (e.g., `GOSE_ACCESS_KEY`, `AWS_ACCESS_KEY_ID`, etc.).
