local s = require("ck.utils.snippets")

return {
  s.s(
    {
      trig = "f",
      name = "frontmatter seperator",
      desc = { "Adds frontmatter seperator." },
    },
    s.fmt(
      [[
      ---

      ]],
      {}
    )
  ),
  s.s(
    {
      trig = "o",
      name = "double frontmatter seperator",
      desc = { "Adds double frontmatter seperator." },
    },
    s.fmt(
      [[
      ---
      {}
      ---

      ]],
      {
        s.i(1),
      }
    )
  ),
  s.s(
    {
      trig = "schema",
      name = "Yaml Schema",
      desc = { "Adds a yaml-language-server schema to current buffer." },
    },
    s.fmt(
      [[
      # yaml-language-server: $schema={}
      ]],
      {
        s.i(1),
      }
    )
  ),
  s.s(
    { trig = "kustomize", name = "Kustomize", desc = { "Adds the kustomize boilerplate." } },
    s.fmt(
      [[
      ---
      apiVersion: kustomize.config.k8s.io/v1beta1
      kind: Kustomization

      resources: []
      ]],
      {}
    )
  ),
  s.s(
    { trig = "m-es", name = "External Secret Manifest", desc = { "Adds the external-secrets.io/v1beta1 ExternalSecret manifest." } },
    s.fmt(
      [[
      ---
      apiVersion: external-secrets.io/v1beta1
      kind: ExternalSecret
      metadata:
        name: {}
      spec:
        secretStoreRef: {}
        target: {}
        data: {}
      ]],
      {
        s.i(1, { "" }),
        s.i(2, { "{}" }),
        s.i(3, { "{}" }),
        s.i(4, { "[]" }),
      }
    )
  ),
  s.s(
    { trig = "m-netshoot", name = "Netshoot", desc = { "Adds the nicolaka/netshoot image." } },
    s.fmt(
      [[
      ---
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: netshoot
      spec:
        replicas: 1
        selector:
          matchLabels:
            app.kubernetes.io/name: netshoot
        template:
          metadata:
            labels:
              app.kubernetes.io/name: netshoot
          spec:
            containers:
              - name: netshoot
                image: nicolaka/netshoot
                command:
                  - /bin/bash
                args:
                  - -c
                  - "while true; do ping localhost; sleep 60; done"
      ]],
      {}
    )
  ),
}
