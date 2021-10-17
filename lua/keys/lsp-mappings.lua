return {
  normal_mode = {
    ["K"] = { ":LspHover<CR>", "Show hover" },
    ["gf"] = { ":LspDefinition<CR>", "Goto Definition" },
    ["gt"] = { ":LspDeclaration<CR>", "Goto declaration" },
    ["gr"] = { ":LspReferences<CR>", "Goto references" },
    ["gz"] = { ":LspImplementation<CR>", "Goto Implementation" },
    ["gs"] = { ":LspSignatureHelp<CR>", "show signature help" },
    ["gp"] = { ":LspPeekDefinitition<CR>", "Peek definition" },
    ["gl"] = { ":LspShowLineDiagnostics<CR>", "Show line diagnostics" },
    ["ca"] = { ":LspCodeAction<CR>", "Code action" },
  },
  insert_mode = {},
  visual_mode = {},
}
