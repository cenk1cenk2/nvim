  return {
    normal_mode = {
      ['K'] = {'<cmd>lua vim.lsp.buf.hover()<CR>', 'Show hover'},
      ['gd'] = {'<cmd>lua vim.lsp.buf.definition()<CR>', 'Goto Definition'},
      ['gD'] = {'<cmd>lua vim.lsp.buf.declaration()<CR>', 'Goto declaration'},
      ['gr'] = {'<cmd>lua vim.lsp.buf.references()<CR>', 'Goto references'},
      ['gI'] = {'<cmd>lua vim.lsp.buf.implementation()<CR>', 'Goto Implementation'},
      ['gs'] = {'<cmd>lua vim.lsp.buf.signature_help()<CR>', 'show signature help'},
      ['gp'] = {'<cmd>lua require\'lvim.lsp.peek\'.Peek(\'definition\')<CR>', 'Peek definition'},
      ['gl'] = {'<cmd>lua require\'lvim.lsp.handlers\'.show_line_diagnostics()<CR>', 'Show line diagnostics'}
    },
    insert_mode = {},
    visual_mode = {}
  }
