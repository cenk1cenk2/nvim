local M = {}

local extension_name = "cmp_extensions"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    opts = {
      multiple_packages = true,
    },
    packer = function()
      return {
        { "hrsh7th/cmp-nvim-lsp" },
        { "hrsh7th/cmp-buffer" },
        { "hrsh7th/cmp-path" },
        { "saadparwaiz1/cmp_luasnip" },
        { "hrsh7th/cmp-nvim-lua" },
        { "hrsh7th/cmp-vsnip" },
        -- https://github.com/petertriho/cmp-git
        { "petertriho/cmp-git" },
        -- https://github.com/David-Kunz/cmp-npm
        { "David-Kunz/cmp-npm" },
        -- https://github.com/hrsh7th/cmp-cmdline
        { "hrsh7th/cmp-cmdline" },
        { "davidsierradz/cmp-conventionalcommits" },
        -- https://github.com/tzachar/cmp-fuzzy-buffer
        { "tzachar/cmp-fuzzy-buffer" },
        { "lukas-reineke/cmp-rg" },
        -- -- https://github.com/hrsh7th/cmp-omni
        --         { "hrsh7th/cmp-omni" },
        -- { "tzachar/cmp-tabnine", run = "./install.sh" },
        { "rafamadriz/friendly-snippets" },
        { "L3MON4D3/LuaSnip" },
        { "hrsh7th/cmp-nvim-lsp-signature-help" },
        { "rcarriga/cmp-dap" },
        -- https://github.com/bydlw98/cmp-env
        { "bydlw98/cmp-env" },
        -- https://github.com/hrsh7th/cmp-calc
        { "hrsh7th/cmp-calc" },
      }
    end,
    setup = {
      cmp_git = {
        name = "git",
        -- defaults
        filetypes = { "gitcommit" },
        remotes = { "upstream", "origin" },
      },
      ["cmp-npm"] = {
        name = "npm",
        filetypes = { "json" },
      },
    },
    configure = function()
      lvim.extensions.cmp.to_setup = {
        sources = {
          { name = "nvim_lsp" },
          { name = "path" },
          -- { name = "nvim_lsp_signature_help" },
          { name = "luasnip" },
          { name = "nvim_lua" },
          -- { name = "omni" },
          { name = "buffer" },
          -- { name = "fuzzy_buffer" },

          { name = "calc" },
          { name = "env" },

          { name = "git" },
          { name = "npm" },

          { name = "rg", option = { additional_arguments = "--ignore-case" }, keyword_length = 3 },
        },

        formatting = {
          source_names = {
            nvim_lsp = "(LSP)",
            emoji = "(Emoji)",
            path = "(Path)",
            calc = "(Calc)",
            cmp_tabnine = "(Tabnine)",
            vsnip = "(Snippet)",
            luasnip = "(Snippet)",
            buffer = "(Buffer)",
            git = "(GIT)",
            omni = "(OMNI)",
            npm = "(NPM)",
            rg = "(RG)",
            tmux = "(TMUX)",
            nvim_lsp_signature_help = "(SH)",
          },
        },
      }
    end,
    to_inject = function()
      return {
        cmp = require "cmp",
      }
    end,
    on_setup = function(config)
      for key, e in pairs(config.setup) do
        local extension = require(key)

        extension.setup(e)
      end

      -- setup lua snip
      local utils = require "lvim.utils"
      local paths = {}
      paths[#paths + 1] = join_paths(get_runtime_dir(), "site", "pack", "packer", "start", "friendly-snippets")
      local user_snippets = join_paths(get_config_dir(), "snippets")
      if utils.is_directory(user_snippets) then
        paths[#paths + 1] = user_snippets
      end
      require("luasnip.loaders.from_lua").lazy_load()
      require("luasnip.loaders.from_vscode").lazy_load { paths = paths }
      require("luasnip.loaders.from_snipmate").lazy_load()
    end,
    on_done = function(config)
      local cmp = config.inject.cmp

      -- command line
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline {
          -- Your configuration here.
        },
        sources = {
          { name = "cmdline" },
        },
      })

      -- fuzzy buffer
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline {
          -- Your configuration here.
        },
        sources = cmp.config.sources {
          { name = "fuzzy_buffer" },
        },
      })

      cmp.setup.cmdline("?", {
        mapping = cmp.mapping.preset.cmdline {
          -- Your configuration here.
        },
        sources = cmp.config.sources {
          { name = "fuzzy_buffer" },
        },
      })

      -- dap
      cmp.setup.filetype({ "dap-repl", "dapui_watches" }, {
        sources = {
          { name = "dap" },
        },
      })
    end,
  })
end

return M
