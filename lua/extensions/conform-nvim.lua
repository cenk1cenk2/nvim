-- https://github.com/stevearc/conform.nvim
local M = {}

local extension_name = "conform_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "stevearc/conform.nvim",
        event = "BufWritePre",
      }
    end,
    setup = function()
      local conform = require("conform")
      local lsp_utils = require("lvim.lsp.utils")
      local METHOD = lsp_utils.METHODS.FORMATTER

      M.extend_tools(conform)
      M.register_tools(lsp_utils, METHOD)

      return {
        -- Map of filetype to formatters
        formatters_by_ft = lsp_utils.read_tools(METHOD),
        -- If this is set, Conform will run the formatter on save.
        -- It will pass the table to conform.format().
        -- This can also be a function that returns the table.
        format_on_save = function(bufnr)
          return {
            lsp_fallback = M.get_lsp_fallback(bufnr),
            timeout_ms = lvim.lsp.format_on_save.timeout,
          }
        end,
        -- If this is set, Conform will run the formatter asynchronously after save.
        -- It will pass the table to conform.format().
        -- This can also be a function that returns the table.
        -- format_after_save = function(bufnr)
        --   return {
        --     lsp_fallback = M.get_lsp_fallback(bufnr),
        --   }
        -- end,
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
      lvim.lsp.buffer_options.formatexpr = "v:lua.require'conform'.formatexpr()"

      lvim.lsp.tools.list_registered.formatters = function(bufnr)
        local formatters = lvim.lsp.tools.list_registered.default.formatters(bufnr)

        local lsp_fallback = M.get_lsp_fallback(bufnr)
        if #formatters == 0 and lsp_fallback == true or lsp_fallback == "always" then
          local lsp = vim.tbl_filter(function(client)
            if client.server_capabilities.documentFormattingProvider == true then
              return true
            end

            return false
          end, vim.lsp.get_clients({ bufnr = bufnr }))

          vim.list_extend(
            formatters,
            vim.tbl_map(function(client)
              return ("%s [lsp]"):format(client.name)
            end, lsp)
          )
        end

        return vim.tbl_filter(function(formatter)
          if vim.list_contains({ "trim_multiple_newlines", "trim_whitespace", "trim_newlines" }, formatter) then
            return false
          end

          return true
        end, formatters)
      end
    end,
  })
end

function M.get_lsp_fallback(bufnr)
  -- if vim.tbl_contains({
  --   "javascript",
  --   "typescript",
  --   "javascriptreact",
  --   "typescriptreact",
  --   "vue",
  --   "svelte",
  -- }, vim.bo[bufnr].filetype) then
  --   return "always"
  -- end

  -- return true
  return "always"
end

function M.register_tools(lsp_utils, METHOD)
  lsp_utils.register_tools(METHOD, "trim_whitespace", {
    "*",
  })

  -- lsp_utils.register_tools(METHOD, "trim_newlines", {
  --   "*",
  -- })

  lsp_utils.register_tools(METHOD, "trim_multiple_newlines", {
    "*",
  })

  lsp_utils.register_tools(METHOD, "injected", {
    "hurl",
    "markdown",
    "gotmpl",
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
  })

  -- lsp_utils.register_tools(METHOD, "eslint_d", {
  --   "javascript",
  --   "typescript",
  --   "javascriptreact",
  --   "typescriptreact",
  --   "vue",
  --   "svelte",
  -- })

  lsp_utils.register_tools(METHOD, "stylua", {
    "markdown-toc",
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
end

function M.extend_tools(conform)
  conform.formatters["prettierd"] = vim.tbl_deep_extend("force", require("conform.formatters.prettierd"), {
    env = {
      ["PRETTIERD_DEFAULT_CONFIG"] = vim.fn.expand("~/.config/nvim/utils/linter-config/.prettierrc.json"),
    },
  })

  conform.formatters["markdown-toc"] = vim.tbl_deep_extend("force", require("conform.formatters.markdown-toc"), {
    prepend_args = { "--bullets='-'" },
  })

  conform.formatters["golines"] = vim.tbl_deep_extend("force", require("conform.formatters.golines"), {
    prepend_args = { "-m", "180" },
  })

  conform.formatters["trim_multiple_newlines"] = {
    meta = {
      url = "https://www.gnu.org/software/gawk/manual/gawk.html",
      description = "Trim multiple new lines with awk.",
    },
    command = "awk",
    args = { "!NF {if (++n <= 1) print; next}; {n=0;print}" },
  }
end

return M
