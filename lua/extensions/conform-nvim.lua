-- https://github.com/stevearc/conform.nvim
local M = {}

local extension_name = "conform_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "stevearc/conform.nvim",
        event = "BufReadPost",
      }
    end,
    setup = function()
      local lsp_utils = require("lvim.lsp.utils")
      local METHOD = lsp_utils.METHODS.FORMATTER
      local conform = require('conform')

      conform.formatters.prettierd = vim.tbl_deep_extend("force", require("conform.formatters.prettierd"), {
        env = {
          "PRETTIERD_DEFAULT_CONFIG=" .. vim.fn.expand("~/.config/nvim/utils/linter-config/.prettierrc.json"),
        },
      })

      lsp_utils.register_tools(METHOD, "prettierd", {
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
        "vue",
        "svelte",
        "yaml",
        "yaml.ansible",
        "yaml.docker-compose",
        "json",
        "jsonc",
        "html",
        "scss",
        "css",
        "markdown",
        "graphql",
        "helm",
      })

      lsp_utils.register_tools(METHOD, "eslint_d", {
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
        "vue",
        "svelte",
      })

      lsp_utils.register_tools(METHOD, "stylua", {
        "lua",
      })

      lsp_utils.register_tools(METHOD, { "golines", "goimports" }, {
        "go",
      })

      lsp_utils.register_tools(METHOD, "shfmt", {
        "sh",
        "bash",
        "zsh",
      })
      -- lsp_utils.register_tools(METHOD, "beautysh", {
      --   "sh",
      --   "bash",
      --   "zsh",
      -- })

      lsp_utils.register_tools(METHOD, "terraform_fmt", {
        "terraform",
        "tfvars",
      })

      local formatters_by_ft = lsp_utils.read_tools(METHOD)

      return {
        -- Map of filetype to formatters
        formatters_by_ft = formatters_by_ft,
        -- If this is set, Conform will run the formatter on save.
        -- It will pass the table to conform.format().
        -- This can also be a function that returns the table.
        format_on_save = {
          -- I recommend these options. See :help conform.format for details.
          lsp_fallback = true,
          timeout_ms = lvim.lsp.format_on_save.timeout,
        },
        -- If this is set, Conform will run the formatter asynchronously after save.
        -- It will pass the table to conform.format().
        -- This can also be a function that returns the table.
        format_after_save = {
          lsp_fallback = true,
        },
        -- Set the log level. Use `:ConformInfo` to see the location of the log file.
        log_level = vim.log.levels.ERROR,
        -- Conform will notify you when a formatter errors
        notify_on_error = true,
      }
    end,
    on_setup = function(config)
      require("conform").setup(config.setup)
    end,
    on_done = function()
      -- lvim.lsp.tools.list_registered.formatters = function(ft)
      --   return require("conform").list_formatters()
      -- end
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  })
end

return M
