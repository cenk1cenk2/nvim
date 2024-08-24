return {
  templates_dir = join_paths(get_data_dir(), "site", "after", "ftplugin"),
  format_on_save = {
    enable = true,
    ---@usage pattern string pattern used for the autocommand (Default: '*')
    pattern = "*",
    ---@usage timeout number timeout in ms for the format request (Default: 1000)
    timeout = 5000,
    ---@usage filter func to select client
    filter = require("core.lsp.format").filter,
  },
  --- @type vim.diagnostic.Opts
  diagnostics = {
    signs = {
      numhl = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
        [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
        [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
        [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
      },
      text = {
        [vim.diagnostic.severity.ERROR] = nvim.ui.icons.diagnostics.Error,
        [vim.diagnostic.severity.WARN] = nvim.ui.icons.diagnostics.Warning,
        [vim.diagnostic.severity.INFO] = nvim.ui.icons.diagnostics.Information,
        [vim.diagnostic.severity.HINT] = nvim.ui.icons.diagnostics.Hint,
      },
    },
    virtual_text = {
      severity_sort = true,
      -- prefix = function(diagnostic)
      --   return signs[vim.diagnostic.severity[diagnostic.severity]]
      -- end,
      source = true,
    },
    update_in_insert = false,
    underline = false,
    severity_sort = true,
    float = {
      focusable = true,
      style = "minimal",
      border = nvim.ui.border,
      source = true,
      header = "",
      prefix = "",
      format = function(d)
        local code = d.code or (d.user_data and d.user_data.lsp.code)
        if code then
          return string.format("%s [%s]", d.message, code):gsub("1. ", "")
        end
        return d.message
      end,
    },
  },
  code_lens = {
    refresh = true,
  },
  inlay_hints = {
    enabled = true,
  },
  buffer_mappings = require("core.keys.lsp"),
  ---@type string[]
  ensure_installed = {},
  ---@type string[]
  skipped_servers = {},
  ---@type string[]
  skipped_filetypes = {},
  ---@type table<string, string>
  buffer_options = {
    --- enable completion triggered by <c-x><c-o>
    omnifunc = "v:lua.vim.lsp.omnifunc",
    --- use gq for formatting
    formatexpr = "v:lua.vim.lsp.formatexpr(#{timeout_ms:500})",
  },
  tools = {
    clients = {
      formatters = "",
      linters = "",
    },
    by_ft = {
      ---@type table<LspToolMethods, table<string, string[]>>
      formatters = {},
      ---@type table<LspToolMethods, table<string, string[]>>
      linters = {},
    },
    list_registered = {
      default = {
        ---@param bufnr number
        ---@return string[]
        formatters = function(bufnr)
          local ft = vim.bo[bufnr].ft
          local tools = {}

          if nvim.lsp.tools.by_ft.formatters["*"] then
            vim.list_extend(tools, nvim.lsp.tools.by_ft.formatters["*"])
          end

          if nvim.lsp.tools.by_ft.formatters[ft] ~= nil then
            vim.list_extend(tools, nvim.lsp.tools.by_ft.formatters[ft])
          elseif nvim.lsp.tools.by_ft.formatters["_"] ~= nil then
            vim.list_extend(tools, nvim.lsp.tools.by_ft.formatters["_"])
          end

          return tools
        end,
        ---@param bufnr number
        ---@return string[]
        linters = function(bufnr)
          local ft = vim.bo[bufnr].ft
          local tools = {}

          if nvim.lsp.tools.by_ft.linters["*"] then
            vim.list_extend(tools, nvim.lsp.tools.by_ft.linters["*"])
          end

          if nvim.lsp.tools.by_ft.linters[ft] ~= nil then
            vim.list_extend(tools, nvim.lsp.tools.by_ft.linters[ft])
          else
            vim.list_extend(tools, nvim.lsp.tools.by_ft.linters["_"])
          end

          return tools
        end,
      },
      formatters = function(bufnr)
        return nvim.lsp.tools.list_registered.default.formatters(bufnr)
      end,
      linters = function(bufnr)
        return nvim.lsp.tools.list_registered.default.linters(bufnr)
      end,
    },
  },
  fn = {},
  ---@type LspOnCallback[]
  on_init_callbacks = {},
  ---@type LspOnCallback[]
  on_attach_callbacks = {},
  ---@type LspOnCallback[]
  on_exit_callbacks = {},
}