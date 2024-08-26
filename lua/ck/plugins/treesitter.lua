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
        build = function()
          vim.cmd([[TSUpdate]])
        end,
        event = "BufReadPre",
        cmd = { "TSInstall", "TSUninstall", "TSUpdate", "TSUpdateSync" },
        -- cond = function()
        --   if is_headless() then
        --     log:debug("Headless mode detected, skipping running setup for treesitter.")
        --
        --     return false
        --   end
        --
        --   return true
        -- end,
        dependencies = {
          {
            "JoosepAlviste/nvim-ts-context-commentstring",
            dependencies = { "nvim-treesitter/nvim-treesitter" },
            event = "BufReadPost",
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

      ---@type TSConfig
      return {
        parser_install_dir = M.parsers_dir,
        ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
        ignore_install = {},
        matchup = {
          enable = false, -- mandatory, false will disable the whole extension
          -- disable = { "c", "ruby" },  -- optional, list of language that will be disabled
        },
        highlight = {
          enable = true, -- false will disable the whole extension
          additional_vim_regex_highlighting = false,
          disable = { "latex" },
        },
        indent = {
          enable = true,
          -- TSBufDisable indent
          disable = {},
        },
        autotag = { enable = true },
        refactor = { highlight_current_scope = { enable = false } },
        -- https://github.com/nvim-treesitter/nvim-treesitter/issues/4000
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<S-CR>",
            node_incremental = "<CR>",
            scope_incremental = "<S-CR>",
            node_decremental = "<BS>",
          },
        },
      }
    end,
    on_setup = function(c)
      require("nvim-treesitter.configs").setup(c)
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
      })
    end,
    on_done = function()
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

      for key, value in pairs(M.parsers) do
        parser_config[key] = value
      end

      for key, value in pairs(M.ft_parsers) do
        vim.treesitter.language.register(key, value)
      end
    end,
    wk = function(_, categories, fn)
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
          fn.wk_keystroke({ categories.TREESITTER, "U" }),
          function()
            vim.cmd([[TSUninstall all]])
          end,
          desc = "uninstall all treesitter packages",
        },
        {
          fn.wk_keystroke({ categories.TREESITTER, "R" }),
          function()
            for _, parser in pairs(fn.get_setup(M.name).ensure_installed) do
              vim.cmd(("TSInstall %s"):format(parser))
            end
          end,
          desc = "reinstall all treesitter packages",
        },
      }
    end,
  })
end

M.parsers = {}

M.ft_parsers = {
  ["yaml"] = { "yaml.ansible" },
  ["gotmpl"] = { "helm" },
  ["htmldjango"] = { "jinja" },
}

return M
