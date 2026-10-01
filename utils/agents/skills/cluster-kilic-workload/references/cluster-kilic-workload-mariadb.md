# Workload MariaDB (Bitnami Helm)

The Bitnami MariaDB chart through kustomize with its S3 backup CronJob. Read when the workload needs MariaDB.

Deployed via Bitnami Helm chart through kustomize with `namePrefix`:

```yaml
# db/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namePrefix: <workload>-

helmCharts:
  - name: mariadb
    releaseName: mariadb
    repo: oci://registry-1.docker.io/bitnamicharts
    version: <version>
    additionalValuesFiles:
      - values.yaml

resources:
  - ./es-user.yaml
  - ./es-backup.yaml
  - ./cronjob-mariadb-backup.yaml
```

Backup is handled by a CronJob using `jkaninda/mysql-bkup` image, backing up to S3.

ExternalSecrets needed:

- `es-user.yaml` — DB root/user passwords from `<cluster>/<workload>/mariadb`
- `es-backup.yaml` — DB creds + S3 creds for the backup CronJob

Place in a `db/` subfolder with its own `kustomization.yaml`.

**Read the reference repo** (`cluster/workloads/seafile`) for the full MariaDB pattern including CronJob, backup ConfigMap, and ExternalSecret details.
