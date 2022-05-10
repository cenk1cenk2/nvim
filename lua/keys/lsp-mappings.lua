return {
  normal_mode = {
    ["K"] = { ":LspHover<CR>", "Show hover" },
    ["gf"] = { ":LspDefinition<CR>", "Goto Definition" },
    ["gt"] = { ":LspDeclaration<CR>", "Goto declaration" },
    ["gr"] = { ":LspReferences<CR>", "Goto references" },
    ["gz"] = { ":LspImplementation<CR>", "Goto Implementation" },
    ["gS"] = { ":LspSignatureHelp<CR>", "show signature help" },
    ["go"] = { ":LspPeekDefinitition<CR>", "Peek definition" },
    ["gl"] = { ":LspShowLineDiagnostics<CR>", "Show line diagnostics" },
    ["ca"] = { ":LspCodeAction<CR>", "Code action" },
    ["gLd"] = { ":LspPeekDefinitition<CR>", "peek definition" },
    ["gLt"] = { ":LspPeekType<CR>", "peek type definition" },
    ["gLi"] = { ":LspPeekImplementation<CR>", "peek implementation" },
  },
  insert_mode = {},
  visual_mode = {},
}
