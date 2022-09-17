return {
  normal_mode = {
    ["K"] = {
      function()
        lvim.lsp_wrapper.hover()
      end,
      "hover",
    },
    ["gf"] = {
      function()
        lvim.lsp_wrapper.definition()
      end,
      "go to definition",
    },
    ["gt"] = {
      function()
        lvim.lsp_wrapper.declaration()
      end,
      "go to declaration",
    },
    ["gr"] = {
      function()
        lvim.lsp_wrapper.references()
      end,
      "go to references",
    },
    ["gz"] = {
      function()
        lvim.lsp_wrapper.implementation()
      end,
      "go to implementation",
    },
    ["go"] = {
      function()
        lvim.lsp_wrapper.signature_help()
      end,
      "show signature help",
    },
    ["gl"] = {
      function()
        lvim.lsp_wrapper.show_line_diagnostics()
      end,
      "show line diagnostics",
    },
    ["ca"] = {
      function()
        lvim.lsp_wrapper.code_action()
      end,
      "code action",
    },
  },
  insert_mode = {},
  visual_mode = {
    ["ca"] = {
      function()
        lvim.lsp_wrapper.range_code_action()
      end,
      "range code action",
    },
  },
}
