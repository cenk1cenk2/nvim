-- https://github.com/mfussenegger/nvim-lint
local M = {}

local extension_name = "nvim_lint"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "mfussenegger/nvim-lint",
        event = "BufReadPre",
      }
    end,
    setup = function()
      local lint = require("lint")
      local lsp_utils = require("lvim.lsp.utils")
      local METHOD = lsp_utils.METHODS.LINTER

      M.extend_tools(lint)
      M.register_tools(lsp_utils, METHOD)

      return lsp_utils.read_tools(METHOD)
    end,
    on_setup = function(config)
      require("lint").linters_by_ft = config.setup
    end,
    on_done = function()
      lvim.lsp.tools.list_registered.linters = function(bufnr)
        return require("lint").linters_by_ft[vim.bo[bufnr].ft] or {}
      end
    end,
    autocmds = {
      {
        { "TextChanged", "BufReadPost" },
        {
          group = "__linter",
          pattern = "*",
          callback = function()
            require("lint").try_lint()
          end,
        },
      },
    },
  })
end

function M.register_tools(lsp_utils, METHOD)
  lsp_utils.register_tools(METHOD, "shellcheck", { "sh", "bash", "zsh" })
  lsp_utils.register_tools(METHOD, "hadolint", { "dockerfile" })
  lsp_utils.register_tools(METHOD, "cspell", { "markdown", "text", "gitcommit", "" })
  lsp_utils.register_tools(METHOD, "proto", { "protolint" })
  lsp_utils.register_tools(METHOD, "tfsec", { "terraform", "tfvars" })
  lsp_utils.register_tools(METHOD, "protolint", { "proto" })
end

function M.extend_tools(lint)
  lint.linters.protolint = {
    cmd = "protolint",
    stdin = false, -- or false if it doesn't support content input via stdin. In that case the filename is automatically added to the arguments.
    append_fname = true, -- Automatically append the file name to `args` if `stdin = false` (default: true)
    args = { "--reporter", "json" }, -- list of arguments. Can contain functions with zero arguments that will be evaluated once the linter is used.
    stream = "stderr", -- ('stdout' | 'stderr' | 'both') configure the stream to which the linter outputs the linting result.
    ignore_exitcode = true, -- set this to true if the linter exits with a code != 0 and that's considered normal.
    env = nil, -- custom environment table to use with the external process. Note that this replaces the *entire* environment, it is not additive.
    parser = function(output)
      local diagnostics = {}

      local decoded = vim.json.decode(output, { object = true, array = true })

      if decoded == nil or decoded.lints == nil then
        return diagnostics
      end

      for _, message in ipairs(decoded.lints) do
        table.insert(diagnostics, {
          lnum = message.line - 1,
          col = message.column - 1,
          -- end_lnum = decoded.location["end"].line - 1,
          -- end_col = decoded.location["end"].column - 1,
          severity = vim.diagnostic.severity.WARN,
          message = ("%s [%s]"):format(message.message, message.rule),
        })
      end

      return diagnostics
    end,
  }
end

return M
