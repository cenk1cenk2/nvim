return {
  normal_mode = {
    ["K"] = { ":LspHover<CR>", "Show hover" },
    ["gf"] = { ":LspDefinition<CR>", "Goto Definition" },
    ["ge"] = { ":lua require('lspsaga.finder').lsp_finder()<CR>", "Finder" },
    ["gt"] = { ":LspDeclaration<CR>", "Goto declaration" },
    ["gr"] = { ":LspReferences<CR>", "Goto references" },
    ["gz"] = { ":LspImplementation<CR>", "Goto Implementation" },
    ["go"] = { ":LspSignatureHelp<CR>", "show signature help" },
    ["gl"] = { ":LspShowLineDiagnostics<CR>", "Show line diagnostics" },
    ["gk"] = { ":LspCodeLens<CR>", "Show Code Lens" },
    ["ca"] = { ":LspCodeAction<CR>", "Code action" },
    ["gFd"] = { ":LspPeekDefinitition<CR>", "peek definition" },
    ["gFt"] = { ":LspPeekType<CR>", "peek type definition" },
    ["gFi"] = { ":LspPeekImplementation<CR>", "peek implementation" },
  },
  insert_mode = {},
  visual_mode = {},
}
