---@type KeymapMappings
return {
  {
    "K",
    function()
      nvim.lsp.wrapper.hover()
    end,
    desc = "hover",
    mode = { "n", "v", "x" },
  },
  {
    "gd",
    function()
      nvim.lsp.wrapper.definition()
    end,
    desc = "go to definition",
    mode = { "n", "v", "x" },
  },
  {
    "gD",
    function()
      nvim.lsp.wrapper.declaration()
    end,
    desc = "go to declaration",
    mode = { "n", "v", "x" },
  },
  {
    "gr",
    function()
      nvim.lsp.wrapper.references()
    end,
    desc = "go to references",
    mode = { "n", "v", "x" },
  },
  {
    "gt",
    function()
      nvim.lsp.wrapper.implementation()
    end,
    desc = "go to implementation",
    mode = { "n", "v", "x" },
  },
  {
    "go",
    function()
      nvim.lsp.wrapper.signature_help()
    end,
    desc = "show signature help",
    mode = { "n", "v", "x" },
  },
  {
    "gl",
    function()
      nvim.lsp.wrapper.show_line_diagnostics()
    end,
    desc = "show line diagnostics",
    mode = { "n", "v", "x" },
  },
  {
    "gh",
    function()
      nvim.lsp.wrapper.code_action()
    end,
    desc = "code action",
    mode = { "n", "v", "x" },
  },
}
