---@type vim.lsp.ClientConfig
return {
  condition = function()
    return vim.list_contains({ vim.fn.expand("~/notes") }, vim.fs.root(0, { ".obsidian" }))
  end,
}
