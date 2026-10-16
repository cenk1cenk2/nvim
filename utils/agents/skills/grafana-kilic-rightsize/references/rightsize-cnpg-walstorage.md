# Rightsize CNPG walStorage

CNPG carries two storage fields under `spec`:

```yaml
spec:
  storage:        # primary data PVC
    size: 2Gi
    storageClass: proxmox-zfs
  walStorage:     # separate PVC for pg_wal/
    size: 8Gi
    storageClass: proxmox-zfs
```

`walStorage` is optional, and leaving it unset colocates WALs on the primary PVC. Always set it explicitly so WALs can be resized independently of the data volume.

## Sizing

The WAL PVC has to hold at least `2 x checkpoint_segments x 16MB`, which is roughly twice `wal_keep_size`. In practice:

- `walStorage.size` runs 2 to 3 times the steady-state `pg_wal/` footprint.
- The CNPG plugin's own safe upper bound is 5 times `primary.storage.size`, covering one full base backup plus archives.
- On kilic.dev the default is 8Gi across every workload, bumped to 16Gi when 8Gi fills. Match the prevailing floor and snap up one storage-grid stop when an alert reports pressure, per `rightsize-snap-grids`. Do not derive a per-workload formula.

## Bump flow

1. **Confirm backup health first.** This is a hard gate, not a preference. CNPG metrics are not scraped into Mimir here, so an absent alert is not evidence that backups are working; check the operator logs or the barman object store directly, and say so when the evidence is thin.
2. **Read the current size from both sides**: the repo file at `.deploy/<cluster>/postgresql/db.yaml`, and the live cluster with `kubelet_volume_stats_capacity_bytes{namespace="<ns>", persistentvolumeclaim=~".*-wal"}`.
3. **Give the user the current value and the grid options** (8Gi to 16Gi, 16Gi to 32Gi) and let them pick. They usually hold ops context, such as a retention change, that decides the size.
4. **Open the merge request on the repo that owns the manifest.** CNPG manifests live per workload at `cluster/workloads/<name>/.deploy/<cluster>/postgresql/db.yaml`. A shared `.deploy/cluster/postgresql/db.yaml` is less common; when it exists it is the better surface.
5. **One branch, one commit, one merge request**, whose description states the old and new size and the backup evidence that cleared the gate.

## Pitfalls

- **Bumping walStorage before confirming barman is healthy.** When barman is not shipping WALs, the volume fills because backups are broken, not because it is undersized. A bump only moves the failure to a larger threshold.
- **walStorage resizes require a pod restart.** CNPG does not resize the volume online: the operator creates a new PVC and the replica picks it up on next scheduling. On a three-replica cluster this is a rolling update rather than downtime, but it is still a rollout, so call it out in the merge request description.
- **`Cluster.spec.resources` restarts the instances too.** A CPU or memory change on a CNPG `Cluster` rolls every instance; the commit body says so.
