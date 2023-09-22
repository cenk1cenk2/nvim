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
      local lsp_utils = require("lvim.lsp.utils")
      local METHOD = lsp_utils.METHODS.LINTER

      lsp_utils.register_tools(METHOD, "shellcheck", { "sh", "bash", "zsh" })
      lsp_utils.register_tools(METHOD, "hadolint", { "dockerfile" })
      lsp_utils.register_tools(METHOD, "cspell", { "markdown", "text", "gitcommit", "" })

      return lsp_utils.read_tools(METHOD)
    end,
    on_setup = function(config)
      require("lint").linters_by_ft = config.setup
    end,
    on_done = function()
      lvim.lsp.tools.list_registered.linters = function(ft)
        return require("lint").linters_by_ft[ft] or {}
      end
    end,
    autocmds = {
      {
        { "InsertLeave", "BufReadPost" },
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

return M
