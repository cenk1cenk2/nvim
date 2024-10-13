-- https://github.com/hrsh7th/nvim-cmp
local M = {}

M.name = "hrsh7th/nvim-cmp"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        -- "hrsh7th/nvim-cmp",
        -- https://github.com/iguanacucumber/magazine.nvim
        "iguanacucumber/magazine.nvim",
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
          { "hrsh7th/cmp-nvim-lsp" },
          { "hrsh7th/cmp-buffer" },
          { "hrsh7th/cmp-path" },
          { "saadparwaiz1/cmp_luasnip" },
          { "hrsh7th/cmp-nvim-lua" },
          { "hrsh7th/cmp-vsnip" },
          -- https://github.com/petertriho/cmp-git
          {
            "petertriho/cmp-git",
            config = function()
              require("cmp_git").setup({
                filetypes = { "gitcommit" },
                remotes = { "upstream", "origin" },
                gitlab = {
                  hosts = {
                    "gitlab.kilic.dev",
                    "gitlab.common.riag.digital",
                  },
                },
              })
            end,
          },
          -- https://github.com/David-Kunz/cmp-npm
          {
            "David-Kunz/cmp-npm",
            config = function()
              require("cmp-npm").setup({
                filetypes = { "json" },
              })
            end,
          },
          -- https://github.com/hrsh7th/cmp-cmdline
          { "hrsh7th/cmp-cmdline" },
          -- https://github.com/tamago324/cmp-zsh
          {
            "tamago324/cmp-zsh",
            config = function()
              require("cmp_zsh").setup({
                zshrc = false,
                filetypes = { "zsh", "bash", "sh" },
              })
            end,
          },
          -- https://github.com/davidsierradz/cmp-conventionalcommits
          { "davidsierradz/cmp-conventionalcommits" },
          -- https://github.com/tzachar/cmp-fuzzy-buffer
          { "tzachar/cmp-fuzzy-buffer" },
          { "lukas-reineke/cmp-rg" },
          -- https://github.com/hrsh7th/cmp-omni
          -- { "hrsh7th/cmp-omni" },
          { "https://github.com/wookayin/cmp-omni", branch = "fix-return" },
          { "rafamadriz/friendly-snippets" },
          { "L3MON4D3/LuaSnip" },
          { "hrsh7th/cmp-nvim-lsp-signature-help" },
          -- https://github.com/bydlw98/cmp-env
          -- { "bydlw98/cmp-env" },
          -- https://github.com/hrsh7th/cmp-calc
          { "hrsh7th/cmp-calc" },
          {
            -- https://github.com/Snikimonkd/cmp-go-pkgs
            "Snikimonkd/cmp-go-pkgs",
          },
        },
      }
    end,
    setup = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local compare = cmp.config.compare

      ---@type cmp.ConfigSchema
      return {
        -- required for https://github.com/rcarriga/cmp-dap
        enabled = function()
          return vim.api.nvim_get_option_value("buftype", { buf = 0 }) ~= "prompt"
        end,
        debounce = 0,
        throttle = 0,
        confirm_opts = { behavior = cmp.ConfirmBehavior.Insert, select = false },
        completion = {
          ---@usage The minimum length of a word to complete on.
          keyword_length = 0,
          -- autocomplete = {
          --   cmp.TriggerEvent.TextChanged,
          --   cmp.TriggerEvent.InsertEnter,
          -- },
        },
        experimental = {
          ghost_text = false,
        },
        -- view = {
        --   entries = "native",
        -- },
        formatting = {
          fields = { "kind", "abbr", "menu" },
          max_width = 80,
          kind_icons = nvim.ui.icons.kind,
          source_names = {
            ["vim-dadbod-completion"] = "DB",
            buffer = "Buff",
            calc = "Calc",
            cmdline = "CMD",
            emoji = "Emoji",
            fuzzy_buffer = "FZF",
            git = "GIT",
            go_pkgs = "PKG",
            lazydev = "LD",
            luasnip = "Snip",
            noice_popupmenu = "CMD",
            npm = "NPM",
            nvim_lsp = "LSP",
            omni = "OMNI",
            path = "Path",
            rg = "RG",
            tmux = "TMUX",
            vsnip = "Snip",
          },
          duplicates = {
            buffer = 1,
            path = 1,
            nvim_lsp = 0,
            luasnip = 1,
          },
          duplicates_default = 0,
          format = function(entry, vim_item)
            local c = M.get_setup()

            local max_width = c.formatting.max_width
            if max_width ~= 0 and #vim_item.abbr > max_width then
              vim_item.abbr = string.sub(vim_item.abbr, 1, max_width - 1) .. " " .. nvim.ui.icons.ui.Ellipsis
            end

            vim_item.kind = c.formatting.kind_icons[vim_item.kind] or vim_item.kind

            vim_item.menu = ("[%s]"):format(c.formatting.source_names[entry.source.name] or entry.source.name)

            vim_item.dup = c.formatting.duplicates[entry.source.name] or c.formatting.duplicates_default

            return vim_item
          end,
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered({ border = nvim.ui.border }),
          documentation = cmp.config.window.bordered({ border = nvim.ui.border }),
        },
        sources = cmp.config.sources(M.sources),
        matching = {
          disallow_fuzzy_matching = false,
          disallow_fullfuzzy_matching = false,
          disallow_partial_fuzzy_matching = false,
          disallow_partial_matching = false,
          disallow_prefix_unmatching = false,
          disallow_symbol_nonprefix_matching = false,
        },
        sorting = {
          priority_weight = 1.0,
          -- comparators = {
          --   compare.offset,
          --   compare.exact,
          --   compare.score,
          --   function(entry1, entry2)
          --     local _, entry1_under = entry1.completion_item.label:find("^_+")
          --     local _, entry2_under = entry2.completion_item.label:find("^_+")
          --     entry1_under = entry1_under or 0
          --     entry2_under = entry2_under or 0
          --     if entry1_under > entry2_under then
          --       return false
          --     elseif entry1_under < entry2_under then
          --       return true
          --     end
          --   end,
          --   compare.kind,
          --   compare.sort_text,
          --   compare.length,
          --   compare.order,
          -- },
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), { "i" }),
          ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), { "i" }),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-y>"] = cmp.mapping({
            i = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false }),
            c = function(fallback)
              if cmp.visible() and M.has_words_before() then
                cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
              else
                fallback()
              end
            end,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              local confirm_opts = vim.deepcopy(M.get_setup().confirm_opts) -- avoid mutating the original opts below
              local is_insert_mode = function()
                return vim.api.nvim_get_mode().mode:sub(1, 1) == "i"
              end
              if is_insert_mode() then -- prevent overwriting brackets
                confirm_opts.behavior = cmp.ConfirmBehavior.Insert
              end
              if cmp.confirm(confirm_opts) then
                return -- success, exit early
              end
            end

            -- if not exited early, always fallback
            fallback()
          end),
          ["<C-l>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.complete_common_string()
            else
              fallback()
            end
          end, { "i", "c" }),
        }),
      }
    end,
    on_setup = function(c)
      require("cmp").setup(c)

      -- setup lua snip
      local paths = {}

      table.insert(paths, join_paths(require("ck.loader").plugins_dir, "friendly-snippets"))

      local user_snippets = join_paths(get_config_dir(), "snippets")
      if is_directory(user_snippets) then
        table.insert(paths, user_snippets)
      end

      require("luasnip.loaders.from_lua").lazy_load({ paths = paths })
      require("luasnip.loaders.from_vscode").lazy_load({ paths = paths })
      require("luasnip.loaders.from_snipmate").lazy_load()
    end,
    on_done = function()
      local cmp = require("cmp")

      -- command line
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline({}),
        sources = {
          { name = "zsh" },
          { name = "cmdline" },
        },
      })

      -- fuzzy buffer
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline({}),
        sources = cmp.config.sources({
          { name = "fuzzy_buffer" },
        }),
      })

      cmp.setup.cmdline("?", {
        mapping = cmp.mapping.preset.cmdline({}),
        sources = cmp.config.sources({
          { name = "fuzzy_buffer" },
        }),
      })

      -- vim.ui
      cmp.setup.cmdline("@", {
        sources = {
          { name = "cmdline" },
          { name = "path" },
        },
      })
    end,
  })
end

---@type cmp.SourceConfig[]
M.sources = {
  { name = "nvim_lsp", keyword_length = 0 },
  { name = "lazydev" },
  { name = "zsh" },
  { name = "vim-dadbod-completion" },
  { name = "go_pkgs" },
  -- { name = "nvim_lsp_signature_help" },
  { name = "luasnip" },
  { name = "calc" },
  { name = "path" },
  { name = "omni", option = { disable_omnifuncs = { "v:lua.vim.lsp.omnifunc" } } },
  { name = "buffer", keyword_length = 3 },
  -- { name = "fuzzy_buffer" },

  -- { name = "env" },

  { name = "git" },
  { name = "npm" },

  { name = "rg", option = { additional_arguments = "--ignore-case" }, keyword_length = 3 },
}

function M.has_words_before()
  if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" then
    return false
  end

  local line, col = unpack(vim.api.nvim_win_get_cursor(0))

  return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

M.get_setup = require("ck.setup").fn.get_setup_wrapper(M.name)

return M
