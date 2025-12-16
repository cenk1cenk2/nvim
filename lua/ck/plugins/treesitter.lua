-- https://github.com/nvim-treesitter/nvim-treesitter
local M = {}

M.name = "nvim-treesitter/nvim-treesitter"

-- local log = require("ck.log")

M.parsers_dir = join_paths(get_data_dir(), "parsers")

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        branch = "main", -- Changed from "master" to "main"
        event = "BufReadPre",
        cmd = { "TSInstall", "TSUninstall", "TSUpdate", "TSUpdateSync" },
        dependencies = {
          {
            "JoosepAlviste/nvim-ts-context-commentstring",
            dependencies = { "nvim-treesitter/nvim-treesitter" },
            event = { "BufReadPost", "BufNewFile", "BufNew" },
          },
          {
            "windwp/nvim-ts-autotag",
            dependencies = { "nvim-treesitter/nvim-treesitter" },
            event = "InsertEnter",
          },
        },
      }
    end,
    setup = function()
      vim.opt.runtimepath:prepend(M.parsers_dir)

      -- Main branch uses a simplified setup
      return {
        install_dir = M.parsers_dir,
      }
    end,
    on_setup = function(c)
      require("nvim-treesitter").setup(c)

      local installed = require("nvim-treesitter.config").get_installed("parsers")
      local not_installed = vim.tbl_filter(function(parser)
        return not vim.tbl_contains(installed, parser)
      end, nvim.treesitter.parsers)

      if #not_installed > 0 then
        require("nvim-treesitter").install(not_installed, { summary = false })
      end

      -- Setup context commentstring
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
      })
    end,
    on_done = function()
      if next(M.parsers) then
        vim.api.nvim_create_autocmd("User", {
          pattern = "TSUpdate",
          callback = function()
            local parser_config = require("nvim-treesitter.parsers")
            for key, value in pairs(M.parsers) do
              parser_config[key] = vim.tbl_extend("force", value, {
                tier = 2, -- Important: tier 2 for custom parsers (unstable)
              })
            end
          end,
        })
      end

      for parser, filetypes in pairs(M.ft_parsers) do
        vim.treesitter.language.register(parser, filetypes)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("_treesitter", { clear = true }),
        pattern = "*",
        callback = function(event)
          local bufnr = event.buf
          local ft = event.match

          -- skip if treesitter is not available for this filetype
          if ft == "" then
            return
          end

          -- Get the mapped language for this filetype
          local lang = vim.treesitter.language.get_lang(ft)

          -- Enable syntax highlighting with the correct language
          if lang then
            pcall(vim.treesitter.start, bufnr, vim.treesitter.language.get_lang(ft))
          end

          vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end,
      })
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.TREESITTER, "i" }),
          function()
            vim.cmd([[TSConfigInfo]])
          end,
          desc = "treesitter info",
        },
        {
          fn.wk_keystroke({ categories.TREESITTER, "k" }),
          function()
            vim.cmd([[Inspect]])
          end,
          desc = "inspect node",
        },
        {
          fn.wk_keystroke({ categories.TREESITTER, "K" }),
          function()
            vim.cmd([[InspectTree]])
          end,
          desc = "inspect tree",
        },
        {
          fn.wk_keystroke({ categories.TREESITTER, "u" }),
          function()
            vim.cmd([[TSUpdate]])
          end,
          desc = "update installed treesitter packages",
        },
        {
          fn.wk_keystroke({ categories.TREESITTER, "X" }),
          function()
            vim.cmd([[TSUninstall all]])
          end,
          desc = "uninstall all treesitter packages",
        },
        {
          fn.wk_keystroke({ categories.TREESITTER, "R" }),
          function()
            local installed = require("nvim-treesitter.config").get_installed("parsers")
            for _, parser in ipairs(installed) do
              vim.cmd(("TSInstall! %s"):format(parser))
            end
          end,
          desc = "reinstall all treesitter packages",
        },
      }
    end,
    toggles = function(_, categories, fn)
      ---@type WKToggleMappings
      return {
        {
          fn.wk_keystroke({ categories.TREESITTER, "t" }),
          function()
            return require("snacks").toggle.treesitter()
          end,
          desc = "treesitter",
        },
      }
    end,
  })
end

M.parsers = {}

M.ft_parsers = {
  ["yaml"] = { "yaml.ansible", "yaml.compose", "yaml.gitlab-ci" },
  ["bash"] = { "zsh" },
  ["ini"] = { "confini", "conf" },
}

return M
