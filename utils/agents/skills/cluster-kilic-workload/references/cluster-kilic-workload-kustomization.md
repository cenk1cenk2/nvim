# Workload Kustomization Patterns

Kustomization templates for each workload shape: multi-component root, Helm or plain-manifest component, and single-component top level. Read the one matching the chosen structure.

## Root kustomization (multi-component)

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

labels:
  - includeSelectors: true
    includeTemplates: true
    pairs:
      app.kubernetes.io/part-of: <workload-name>

resources:
  - ./<component-1>/
  - ./<component-2>/
```

## Component kustomization (with Helm chart)

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

labels:
  - includeSelectors: true
    includeTemplates: true
    pairs:
      app.kubernetes.io/name: <component-name>

helmCharts:
  - name: <chart-name>
    releaseName: <release-name>
    repo: <chart-repo-url>
    version: <chart-version>
    additionalValuesFiles:
      - values.yaml

resources:
  - ./es.yaml
  - ./route-http.yaml
```

**Helm chart values.yaml reference:** When writing a `values.yaml` for a Helm chart (whether in a component subfolder or top-level), include a comment at the top with a link to the upstream chart's default `values.yaml` (GitHub raw link or documentation URL). This helps future maintainers understand what options are available.

```yaml
# Upstream chart defaults: <link-to-upstream-values.yaml>
key: value
```

Find the link during the Research Phase — check the chart's GitHub/GitLab repository for the `values.yaml` file, or the chart's documentation page listing all configurable values. For custom charts from the `cluster/charts` group, link to that chart's `values.yaml` in GitLab.

## Component kustomization (plain manifests)

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

labels:
  - includeSelectors: true
    includeTemplates: true
    pairs:
      app.kubernetes.io/name: <component-name>

resources:
  - ./deployment.yaml
  - ./service.yaml
  - ./route-http.yaml
```

## Single-component kustomization (top-level, no subfolders)

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ./deployment.yaml
  - ./service.yaml
  - ./route-http.yaml
  - ./es-s3.yaml
  - ./probe.yaml
```

Can also have `helmCharts:` directly at the top level, and `configMapGenerator:` for config files.
