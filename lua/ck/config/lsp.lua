return {
  log = {
    level = "error",
  },
  features = {
    on_type_formatting = {
      ---@type NvimLspFeaturePredicate
      enabled = false,
    },
    inline_completion = {
      ---@type NvimLspFeaturePredicate
      enabled = false,
    },
    codelens = {
      ---@type NvimLspFeaturePredicate
      enabled = false,
    },
    inlay_hints = {
      ---@type NvimLspFeaturePredicate
      enabled = true,
      toggled = false,
      ---@alias NvimInlayHintsMode
      ---| "eol"
      ---| "right_align"
      ---| "inline"
      mode = "inline",
    },
  },
  ai = {
    debug = false,
    chat = {
      ---@type ("codecompanion" | "claude" | "avante")[]
      provider = { "claude" },
      ---@type table<string, any>
      options = {},
      rag = false,
    },
    completion = {
      ---@type ("inline" | "cmp" | "minuet")[]
      provider = { "inline" },
      number_of_completions = 1,
      context_window = 2048,
      line_limit = 15,
      vectorcode = {
        enabled = false,
        number_of_files = 1,
      },
      prompt = "",
      fim = {
        prefix = "",
        suffix = "",
        middle = "",
        file = "",
      },
      ---@type table<string, any>
      options = {},
    },
    provider = {
      ---@type 'copilot' | 'ai.kilic.dev' | 'gemini' | string
      chat = "claude_code",
      ---@type 'copilot' | 'ai.kilic.dev' | 'gemini' | string
      completion = "copilot",
    },
    filetypes = {
      ---@type string[]
      enabled = {},
      ---@type string[]
      ignored = {},
    },
    model = {
      ---@type string?
      chat = nil,
      ---@type string?
      completion = nil,
      ---@type string?
      embed = nil,
    },
    copilot = {
      ---@type table<string, boolean>
      filetypes = {},
      debounce = 50,
      nes = {
        enabled = true,
        debounce = 50,
        events = {
          events = { "ModeChanged i:n", "TextChanged", "User SidekickNesDone" },
          clear = { "TextChangedI", "TextChanged", "BufWritePre", "InsertEnter" },
        },
      },
    },
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
    virtual_lines = false,
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
          local match = string.format("%s [%s]", d.message, code):gsub("1. ", "")

          return match
        end

        return d.message
      end,
    },
  },

  ---@type table<string, string | LspOnCallback>
  buffer_options = {
    formatexpr = "v:lua.vim.lsp.formatexpr(#{timeout_ms:500})",
  },

  ---@type string[]
  servers = {},
  ---@type string[]
  packages = {},
  ---@usage Automatic update of the language servers on startup.
  automatic_update = true,

  tools = {
    format = {
      enable = true,
      pattern = { "*" },
      timeout = 5000,
      filter = require("ck.lsp.format").filter,
      ---@module "conform"
      ---@type conform.LspFormatOpts
      lsp_format = "first",
    },

    clients = {
      formatters = "",
      linters = "",
    },
    ---@alias ToolByFt table<LspToolMethods, table<string, string[]>>
    by_ft = {
      ---@type ToolByFt
      formatters = {},
      ---@type ToolByFt
      linters = {},
    },
    ---@alias ToolListFn fun(bufnr: number): string[]
    list_registered = {
      ---@type ToolListFn
      formatters = function(bufnr)
        return require("ck.lsp.tools").list_registered(require("ck.lsp.tools").METHODS.FORMATTER, bufnr)
      end,
      ---@type ToolListFn
      linters = function(bufnr)
        return require("ck.lsp.tools").list_registered(require("ck.lsp.tools").METHODS.LINTER, bufnr)
      end,
    },
  },

  ---@type LspOnCallback[]
  on_init_callbacks = {},
  ---@type LspOnCallback[]
  on_attach_callbacks = {},
  ---@type LspOnCallback[]
  on_exit_callbacks = {},

  fn = require("ck.lsp.fn"),
}
