-- https://github.com/stevearc/conform.nvim
local M = {}
local tools = require("ck.lsp.tools")

M.name = "stevearc/conform.nvim"

local METHOD = tools.METHODS.FORMATTER

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "stevearc/conform.nvim",
        event = "BufReadPost",
      }
    end,
    setup = function()
      M.extend_tools()
      M.register()

      ---@type conform.setupOpts
      return {
        -- Map of filetype to formatters
        formatters_by_ft = tools.read(METHOD),
        -- If this is set, Conform will run the formatter on save.
        -- It will pass the table to conform.format().
        -- This can also be a function that returns the table.
        format_on_save = function(bufnr)
          if not require("ck.lsp.format").should_format_on_save() then
            return {
              formatters = {},
            }
          end

          return {
            lsp_fallback = M.get_lsp_fallback(bufnr),
            timeout_ms = nvim.lsp.format_on_save.timeout,
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
    on_setup = function(c)
      require("conform").setup(c)
    end,
    on_done = function()
      table.insert(nvim.lsp.buffer_options, function(_, bufnr)
        vim.api.nvim_set_option_value("formatexpr", "v:lua.require'conform'.formatexpr()", { buf = bufnr })
      end)

      ---@type ToolListFn
      nvim.lsp.tools.list_registered.formatters = function(bufnr)
        local formatters = require("ck.lsp.tools").list_registered(require("ck.lsp.tools").METHODS.FORMATTER, bufnr)

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

        return M.filter_default_formatters(formatters)
      end

      ---@type FormatFilterFn
      nvim.lsp.format_on_save.filter = function(client)
        if client.supports_method("textDocument/formatting") then
          return true
        end

        return false
      end

      ---@param opts? vim.lsp.buf.format.Opts
      ---@diagnostic disable-next-line: duplicate-set-field
      nvim.lsp.fn.format = function(opts)
        opts = vim.tbl_extend("force", {
          bufnr = vim.api.nvim_get_current_buf(),
          timeout_ms = nvim.lsp.format_on_save.timeout_ms,
          filter = nvim.lsp.format_on_save.filter,
        }, opts or {})

        return require("conform").format(opts)
      end
    end,
    autocmds = function()
      return {
        require("ck.modules.autocmds").on_lspattach(function(bufnr)
          return {
            wk = function(_, categories, fn)
              ---@type WKMappings
              return {
                {
                  fn.wk_keystroke({ categories.LSP, categories.LOGS, "f" }),
                  function()
                    vim.cmd([[ConformInfo]])
                  end,
                  desc = "formatter logs",
                  buffer = bufnr,
                },
              }
            end,
          }
        end),
      }
    end,
  })
end

M.default_formatters = {
  "trim_whitespace",
  -- "trim_multiple_whitespace",
  "trim_newlines",
  "trim_multiple_newlines",
}

---@param formatters string[]
---@return string[]
function M.filter_default_formatters(formatters)
  return vim.tbl_filter(function(formatter)
    if type(formatter) == "string" and vim.list_contains(M.default_formatters, formatter) then
      return false
    elseif type(formatter) == "table" and formatter.name and vim.list_contains(M.default_formatters, formatter.name) then
      return false
    end

    return true
  end, formatters)
end

function M.get_lsp_fallback(bufnr)
  if vim.tbl_contains({
    "javascript",
    "typescript",
    "javascriptreact",
    "typescriptreact",
    "vue",
    "svelte",
  }, vim.bo[bufnr].filetype) then
    return "always"
  elseif #M.filter_default_formatters(require("conform").list_formatters(bufnr)) == 0 then
    return "always"
  end

  return true
end

function M.register()
  tools.register(METHOD, "trim_whitespace", {
    "*",
  })

  -- lsp_utils.register(METHOD, "trim_multiple_whitespace", {
  --   "*",
  -- })

  tools.register(METHOD, "trim_newlines", {
    "*",
  })

  tools.register(METHOD, "trim_multiple_newlines", {
    "*",
  })

  tools.register(METHOD, "injected", {
    "hurl",
    "markdown",
    "gotmpl",
  })

  tools.register(METHOD, "prettierd", {
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

  -- lsp_utils.register(METHOD, "eslint_d", {
  --   "javascript",
  --   "typescript",
  --   "javascriptreact",
  --   "typescriptreact",
  --   "vue",
  --   "svelte",
  -- })

  tools.register(METHOD, "stylua", {
    "markdown-toc",
  })

  tools.register(METHOD, "stylua", {
    "lua",
  })

  tools.register(METHOD, { "golines", "goimports" }, {
    "go",
  })

  tools.register(METHOD, "shfmt", {
    "sh",
    "bash",
    "zsh",
  })
  -- lsp_utils.register(METHOD, "beautysh", {
  --   "sh",
  --   "bash",
  --   "zsh",
  -- })

  -- lsp_utils.register(METHOD, "terraform_fmt", {
  --   "terraform",
  --   "tfvars",
  -- })
end

function M.extend_tools()
  local conform = require("conform")

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

  conform.formatters["trim_multiple_whitespace"] = {
    meta = {
      url = "https://www.gnu.org/software/gawk/manual/gawk.html",
      description = "Trim multiple whitespace with awk.",
    },
    command = "tr",
    args = { "-s", "' '" },
  }
end

return M
