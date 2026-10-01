# Workload Monitoring Probe

The blackbox exporter Probe for uptime monitoring. Read when the workload gets a monitoring probe.

Blackbox exporter probe for uptime monitoring:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: Probe
metadata:
  name: <workload>
  labels:
    release: prometheus-operator
spec:
  interval: 60s
  module: http_2xx
  prober:
    url: blackbox-exporter.monitoring.svc:9115
  targets:
    staticConfig:
      static:
        - https://<hostname>.kilic.dev
```
