# ArgoCD PVC Restore

Standard pattern for restoring PVC data and databases from S3 archives in ArgoCD-managed workloads. Read this when creating restore manifests for workloads that need data migration or recovery.

## Pattern

A suspended `CronJob` that downloads an archive from S3 and restores it. Suspended by default — triggered manually via k9s or `kubectl create job --from=cronjob/<name>`.

## Data Restore Template

For restoring file data to a PVC:

```yaml
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: <app>-restore
spec:
  schedule: "0 0 * * *"
  suspend: true
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          initContainers:
            - name: download
              image: alpine:latest
              command:
                - /bin/ash
                - -c
                - |
                  wget -O /restore/archive.tar.gz ${DOWNLOAD_URL}
              volumeMounts:
                - name: restore
                  mountPath: /restore
              env:
                - name: DOWNLOAD_URL
                  value: REPLACE_WITH_S3_PRESIGNED_URL
          containers:
            - name: restore
              image: alpine:latest
              command:
                - /bin/ash
                - -c
                - |
                  tar -xzvf /restore/archive.tar.gz -C /target
              volumeMounts:
                - name: restore
                  mountPath: /restore
                - name: target
                  mountPath: /target
          volumes:
            - name: restore
              emptyDir: {}
            - name: target
              persistentVolumeClaim:
                claimName: <pvc-name>
```

## PostgreSQL Restore Template

Uses `jkaninda/pg-bkup:latest`. Supports `.sql`, `.sql.gz`, and `.sql.gpg` formats.

```yaml
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: <app>-db-restore
spec:
  schedule: "0 0 * * *"
  suspend: true
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          initContainers:
            - name: download
              image: alpine:latest
              command:
                - /bin/ash
                - -c
                - |
                  wget -O /restore/archive.sql.gz ${DOWNLOAD_URL}
              volumeMounts:
                - name: restore
                  mountPath: /restore
              env:
                - name: DOWNLOAD_URL
                  value: REPLACE_WITH_S3_PRESIGNED_URL
          containers:
            - name: db-restore
              image: jkaninda/pg-bkup:latest
              command:
                - restore
                - -f
                - /restore/archive.sql.gz
              env:
                - name: DB_HOST
                  value: <db-service>-rw
                - name: DB_PORT
                  value: "5432"
                - name: DB_NAME
                  value: <database>
                - name: DB_USERNAME
                  valueFrom:
                    secretKeyRef:
                      name: <secret>
                      key: username
                - name: DB_PASSWORD
                  valueFrom:
                    secretKeyRef:
                      name: <secret>
                      key: password
              volumeMounts:
                - name: restore
                  mountPath: /restore
          volumes:
            - name: restore
              emptyDir: {}
```

## MySQL Restore Template

Uses `jkaninda/mysql-bkup:latest`. Supports `.sql`, `.sql.gz`, and `.sql.gpg` formats.

```yaml
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: <app>-db-restore
spec:
  schedule: "0 0 * * *"
  suspend: true
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          initContainers:
            - name: download
              image: alpine:latest
              command:
                - /bin/ash
                - -c
                - |
                  wget -O /restore/archive.sql.gz ${DOWNLOAD_URL}
              volumeMounts:
                - name: restore
                  mountPath: /restore
              env:
                - name: DOWNLOAD_URL
                  value: REPLACE_WITH_S3_PRESIGNED_URL
          containers:
            - name: db-restore
              image: jkaninda/mysql-bkup:latest
              command:
                - restore
                - -f
                - /restore/archive.sql.gz
              env:
                - name: DB_HOST
                  value: <db-service>
                - name: DB_PORT
                  value: "3306"
                - name: DB_NAME
                  value: <database>
                - name: DB_USERNAME
                  valueFrom:
                    secretKeyRef:
                      name: <secret>
                      key: username
                - name: DB_PASSWORD
                  valueFrom:
                    secretKeyRef:
                      name: <secret>
                      key: password
              volumeMounts:
                - name: restore
                  mountPath: /restore
          volumes:
            - name: restore
              emptyDir: {}
```

## S3 URL Sources

- **Presigned URL:** `https://main.s3.kilic.dev/<path>?X-Amz-Algorithm=...` — time-limited, generate from MinIO console
- **Shared object URL:** `https://backup.console.s3.kilic.dev/api/v1/download-shared-object/...` — longer-lived share links from backup bucket

Replace `REPLACE_WITH_S3_PRESIGNED_URL` with the actual URL before triggering.

## Conventions

- Name the CronJob `<app>-restore` for data or `<app>-db-restore` for databases
- Name the manifest file `job-restore.yaml` (or `job-db-restore.yaml` for DB)
- Always use `suspend: true` — never auto-run restores
- Use `emptyDir` for staging, PVC for the target (data restores only)
- Include in `kustomization.yaml` so ArgoCD syncs it but it remains dormant
