-- https://github.com/hrsh7th/nvim-cmp
local M = {}

M.name = "hrsh7th/nvim-cmp"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      return {
        "hrsh7th/nvim-cmp",
        lazy = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
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
          -- { "tzachar/cmp-tabnine", build = "./install.sh" },
          { "rafamadriz/friendly-snippets" },
          { "L3MON4D3/LuaSnip" },
          { "hrsh7th/cmp-nvim-lsp-signature-help" },
          { "rcarriga/cmp-dap" },
          -- https://github.com/bydlw98/cmp-env
          -- { "bydlw98/cmp-env" },
          -- https://github.com/hrsh7th/cmp-calc
          { "hrsh7th/cmp-calc" },
          -- { "zbirenbaum/copilot-cmp" },
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
          return vim.api.nvim_get_option_value("buftype", { buf = 0 }) ~= "prompt" or require("cmp_dap").is_dap_buffer()
        end,
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
            nvim_lsp = "LSP",
            lazydev = "LD",
            emoji = "Emoji",
            path = "Path",
            calc = "Calc",
            cmp_tabnine = "T9",
            vsnip = "Snip",
            luasnip = "Snip",
            buffer = "Buff",
            fuzzy_buffer = "FZF",
            git = "GIT",
            omni = "OMNI",
            npm = "NPM",
            rg = "RG",
            tmux = "TMUX",
            copilot = "CoPi",
            cmdline = "CMD",
            noice_popupmenu = "CMD",
            ["vim-dadbod-completion"] = "DB",
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
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "lazydev", group_index = 0 },
          { name = "vim-dadbod-completion" },
          -- { name = "nvim_lsp_signature_help" },
          { name = "luasnip" },
          { name = "calc" },
          -- { name = "copilot" },
          { name = "path" },
          -- { name = "omni" },
          { name = "buffer" },
          -- { name = "fuzzy_buffer" },

          -- { name = "env" },

          { name = "git" },
          { name = "npm" },

          { name = "rg", option = { additional_arguments = "--ignore-case" }, keyword_length = 3 },
        }),
        matching = {
          disallow_fuzzy_matching = false,
          disallow_fullfuzzy_matching = false,
          disallow_partial_fuzzy_matching = true,
          disallow_partial_matching = false,
          disallow_prefix_unmatching = false,
          disallow_same_order_fuzzy_matching = false,
        },
        sorting = {
          priority_weight = 1.0,
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            function(entry1, entry2)
              local _, entry1_under = entry1.completion_item.label:find("^_+")
              local _, entry2_under = entry2.completion_item.label:find("^_+")
              entry1_under = entry1_under or 0
              entry2_under = entry2_under or 0
              if entry1_under > entry2_under then
                return false
              elseif entry1_under < entry2_under then
                return true
              end
            end,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
          },
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

      -- extensions
      for name, e in pairs(M.per_extension) do
        local extension = require(name)

        extension.setup(e)
      end

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
      local setup = require("ck.setup")

      for key, value in pairs(M.per_ft) do
        setup.create_autocmds({
          {
            event = "FileType",
            group = "_cmp_per_ft",
            pattern = key,
            callback = function()
              cmp.setup.buffer(value)
            end,
          },
        })
      end

      -- command line
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline({}),
        sources = {
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

      -- dap
      cmp.setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
        sources = {
          { name = "dap" },
        },
      })
    end,
  })
end

function M.has_words_before()
  if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" then
    return false
  end

  local line, col = unpack(vim.api.nvim_win_get_cursor(0))

  return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

M.per_ft = {}

M.per_extension = {
  ["cmp_git"] = {
    name = "git",
    -- defaults
    filetypes = { "gitcommit" },
    remotes = { "upstream", "origin" },
  },
  ["cmp-npm"] = {
    name = "npm",
    filetypes = { "json" },
  },
}

M.get_setup = require("ck.setup").fn.get_setup_wrapper(M.name)

return M