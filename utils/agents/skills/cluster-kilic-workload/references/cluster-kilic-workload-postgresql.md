# Workload PostgreSQL (CNPG)

CloudNativePG cluster, scheduled backup and the secrets they need. Read when the workload needs PostgreSQL.

Always deployed via CloudNativePG `Cluster` CRD with S3 barman backup.

```yaml
# db.yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: <workload>-db
spec:
  instances: 3
  imageName: ghcr.io/cloudnative-pg/postgresql:17
  postgresql:
    parameters:
      timezone: Europe/Vienna
  bootstrap:
    initdb:
      database: <db-name>
      owner: <db-user>
      secret:
        name: postgresql-user
  storage:
    size: 1Gi
    storageClass: proxmox-zfs
  walStorage:
    size: 4Gi
    storageClass: proxmox-zfs
  backup:
    barmanObjectStore:
      destinationPath: s3://cloudnativepg-<cluster>/<workload>
      s3Credentials:
        accessKeyId:
          name: postgresql-backup
          key: AWS_ACCESS_KEY_ID
        secretAccessKey:
          name: postgresql-backup
          key: AWS_SECRET_ACCESS_KEY
    retentionPolicy: 14d
```

```yaml
# db-backup.yaml
apiVersion: postgresql.cnpg.io/v1
kind: ScheduledBackup
metadata:
  name: <workload>-db-backup
spec:
  schedule: "@every 12h"
  backupOwnerReference: self
  cluster:
    name: <workload>-db
```

ExternalSecrets needed:

- `postgresql-user` — DB credentials from `<cluster>/<workload>/postgresql` (keys: `username`, `password`)
- `postgresql-backup` — S3 backup credentials from `<cluster>/<workload>/postgresql-backup` (keys: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)

Place in a `postgresql/` subfolder with its own `kustomization.yaml`.
