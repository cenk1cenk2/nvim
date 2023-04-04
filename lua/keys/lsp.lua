return {
  normal_mode = {
    ["K"] = {
      function()
        lvim.lsp.wrapper.hover()
      end,
      "hover",
    },
    ["gd"] = {
      function()
        lvim.lsp.wrapper.definition()
      end,
      "go to definition",
    },
    ["gt"] = {
      function()
        lvim.lsp.wrapper.declaration()
      end,
      "go to declaration",
    },
    ["gr"] = {
      function()
        lvim.lsp.wrapper.references()
      end,
      "go to references",
    },
    ["gy"] = {
      function()
        lvim.lsp.wrapper.implementation()
      end,
      "go to implementation",
    },
    ["go"] = {
      function()
        lvim.lsp.wrapper.signature_help()
      end,
      "show signature help",
    },
    ["gl"] = {
      function()
        lvim.lsp.wrapper.show_line_diagnostics()
      end,
      "show line diagnostics",
    },
    ["gh"] = {
      function()
        lvim.lsp.wrapper.code_action()
      end,
      "code action",
    },
  },
  insert_mode = {},
  visual_mode = {
    ["ca"] = {
      function()
        lvim.lsp.wrapper.code_action()
      end,
      "range code action",
    },
  },
}
