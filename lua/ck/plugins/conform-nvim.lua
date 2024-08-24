-- https://github.com/stevearc/conform.nvim
local M = {}

M.name = "stevearc/conform.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      return {
        "stevearc/conform.nvim",
        event = "BufReadPost",
      }
    end,
    setup = function()
      local conform = require("conform")
      local tools = require("ck.lsp.tools")
      local METHOD = tools.METHODS.FORMATTER

      M.extend_tools(conform)
      M.register_tools(tools, METHOD)

      return {
        -- Map of filetype to formatters
        formatters_by_ft = tools.read_tools(METHOD),
        -- If this is set, Conform will run the formatter on save.
        -- It will pass the table to conform.format().
        -- This can also be a function that returns the table.
        format_on_save = function(bufnr)
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
      nvim.lsp.buffer_options.formatexpr = "v:lua.require'conform'.formatexpr()"

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

      nvim.lsp.fn.format = function(opts)
        opts = vim.tbl_extend("force", {
          bufnr = vim.api.nvim_get_current_buf(),
          timeout_ms = nvim.lsp.format_on_save.timeout_ms,
          filter = nvim.lsp.format_on_save.filter,
        }, opts or {})

        require("conform").format(opts)
      end
    end,
    wk = function(_, categories, fn)
      return {
        {
          fn.wk_keystroke({ categories.LOGS, "f" }),
          function()
            vim.cmd([[ConformInfo]])
          end,
          desc = "formatter logs",
        },
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

function M.register_tools(tools, METHOD)
  tools.register_tools(METHOD, "trim_whitespace", {
    "*",
  })

  -- lsp_utils.register_tools(METHOD, "trim_multiple_whitespace", {
  --   "*",
  -- })

  tools.register_tools(METHOD, "trim_newlines", {
    "*",
  })

  tools.register_tools(METHOD, "trim_multiple_newlines", {
    "*",
  })

  tools.register_tools(METHOD, "injected", {
    "hurl",
    "markdown",
    "gotmpl",
  })

  tools.register_tools(METHOD, "prettierd", {
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

  tools.register_tools(METHOD, "stylua", {
    "markdown-toc",
  })

  tools.register_tools(METHOD, "stylua", {
    "lua",
  })

  tools.register_tools(METHOD, { "golines", "goimports" }, {
    "go",
  })

  tools.register_tools(METHOD, "shfmt", {
    "sh",
    "bash",
    "zsh",
  })
  -- lsp_utils.register_tools(METHOD, "beautysh", {
  --   "sh",
  --   "bash",
  --   "zsh",
  -- })

  -- lsp_utils.register_tools(METHOD, "terraform_fmt", {
  --   "terraform",
  --   "tfvars",
  -- })
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
