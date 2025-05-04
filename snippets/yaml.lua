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
}
