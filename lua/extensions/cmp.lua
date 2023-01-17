-- https://github.com/hrsh7th/nvim-cmp
local M = {}

local extension_name = "cmp"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
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
          { "bydlw98/cmp-env" },
          -- https://github.com/hrsh7th/cmp-calc
          { "hrsh7th/cmp-calc" },
        },
      }
    end,
    inject_to_configure = function()
      return {
        cmp = require("cmp"),
        luasnip = require("luasnip"),
      }
    end,
    setup = function(config)
      local cmp = config.inject.cmp
      local luasnip = config.inject.luasnip
      -- local jumpable = M.jumpable
      local has_words_before = M.has_words_before

      return {
        confirm_opts = { behavior = cmp.ConfirmBehavior.Insert, select = false },
        completion = {
          ---@usage The minimum length of a word to complete on.
          keyword_length = 1,
        },
        experimental = {
          ghost_text = false,
        },
        -- view = {
        --   entries = "native",
        -- },
        formatting = {
          fields = { "kind", "abbr", "menu" },
          max_width = 40,
          kind_icons = lvim.ui.icons.kind,
          source_names = {
            nvim_lsp = "LSP",
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
          },
          duplicates = {
            buffer = 1,
            path = 1,
            nvim_lsp = 0,
            luasnip = 1,
          },
          duplicates_default = 0,
          format = function(entry, vim_item)
            local current_setup = M.current_setup()

            local max_width = current_setup.formatting.max_width
            if max_width ~= 0 and #vim_item.abbr > max_width then
              vim_item.abbr = string.sub(vim_item.abbr, 1, max_width - 1) .. " " .. lvim.ui.icons.ui.Ellipsis
            end

            vim_item.kind = current_setup.formatting.kind_icons[vim_item.kind]

            vim_item.menu = ("[%s]"):format(current_setup.formatting.source_names[entry.source.name] or entry.source.name)

            vim_item.dup = current_setup.formatting.duplicates[entry.source.name] or current_setup.formatting.duplicates_default

            return vim_item
          end,
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered({ border = lvim.ui.border }),
          documentation = cmp.config.window.bordered({ border = lvim.ui.border }),
        },
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
              if cmp.visible() then
                cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
              else
                fallback()
              end
            end,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            -- elseif jumpable(1) then
            --   luasnip.jump(1)
            elseif has_words_before() then
              -- cmp.complete()
              fallback()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            -- elseif luasnip.jumpable(-1) then
            --   luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              local confirm_opts = vim.deepcopy(M.current_setup().confirm_opts) -- avoid mutating the original opts below
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
            fallback() -- if not exited early, always fallback
          end),
        }),
      }
    end,
    extended_setup = {
      per_ft = {},
      extensions = {
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
      },
    },
    on_setup = function(config)
      require("cmp").setup(config.setup)

      -- extensions
      for name, e in pairs(config.extended_setup.extensions) do
        local extension = require(name)

        extension.setup(e)
      end

      -- setup lua snip
      local utils = require("lvim.utils")
      local paths = {}

      table.insert(paths, join_paths(require("lvim.plugin-loader").plugins_dir, "friendly-snippets"))

      local user_snippets = join_paths(get_config_dir(), "snippets")
      if utils.is_directory(user_snippets) then
        table.insert(paths, user_snippets)
      end

      require("luasnip.loaders.from_lua").lazy_load()
      require("luasnip.loaders.from_vscode").lazy_load({ paths = paths })
      require("luasnip.loaders.from_snipmate").lazy_load()
    end,
    on_done = function(config)
      local cmp = config.inject.cmp
      local setup = require("utils.setup")

      for key, value in pairs(setup.evaluate_property(config.extended_setup.per_ft, config)) do
        setup.define_autocmds({
          {
            { "FileType" },
            {
              group = "_cmp_per_ft",
              pattern = key,
              callback = function()
                cmp.setup.buffer(value)
              end,
            },
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

      -- dap
      cmp.setup.filetype({ "dap-repl", "dapui_watches" }, {
        sources = {
          { name = "dap" },
        },
      })
    end,
  })
end

M.current_setup = require("utils.setup").fn.get_current_setup_wrapper(extension_name)

function M.has_words_before()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

function M.jumpable(dir)
  local luasnip_ok, luasnip = pcall(require, "luasnip")
  if not luasnip_ok then
    return false
  end

  local win_get_cursor = vim.api.nvim_win_get_cursor
  local get_current_buf = vim.api.nvim_get_current_buf

  ---sets the current buffer's luasnip to the one nearest the cursor
  ---@return boolean true if a node is found, false otherwise
  local function seek_luasnip_cursor_node()
    -- TODO(kylo252): upstream this
    -- for outdated versions of luasnip
    if not luasnip.session.current_nodes then
      return false
    end

    local node = luasnip.session.current_nodes[get_current_buf()]
    if not node then
      return false
    end

    local snippet = node.parent.snippet
    local exit_node = snippet.insert_nodes[0]

    local pos = win_get_cursor(0)
    pos[1] = pos[1] - 1

    -- exit early if we're past the exit node
    if exit_node then
      local exit_pos_end = exit_node.mark:pos_end()
      if (pos[1] > exit_pos_end[1]) or (pos[1] == exit_pos_end[1] and pos[2] > exit_pos_end[2]) then
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil

        return false
      end
    end

    node = snippet.inner_first:jump_into(1, true)
    while node ~= nil and node.next ~= nil and node ~= snippet do
      local n_next = node.next
      local next_pos = n_next and n_next.mark:pos_begin()
      local candidate = n_next ~= snippet and next_pos and (pos[1] < next_pos[1]) or (pos[1] == next_pos[1] and pos[2] < next_pos[2])

      -- Past unmarked exit node, exit early
      if n_next == nil or n_next == snippet.next then
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil

        return false
      end

      if candidate then
        luasnip.session.current_nodes[get_current_buf()] = node
        return true
      end

      local ok
      ok, node = pcall(node.jump_from, node, 1, true) -- no_move until last stop
      if not ok then
        snippet:remove_from_jumplist()
        luasnip.session.current_nodes[get_current_buf()] = nil

        return false
      end
    end

    -- No candidate, but have an exit node
    if exit_node then
      -- to jump to the exit node, seek to snippet
      luasnip.session.current_nodes[get_current_buf()] = snippet
      return true
    end

    -- No exit node, exit from snippet
    snippet:remove_from_jumplist()
    luasnip.session.current_nodes[get_current_buf()] = nil
    return false
  end

  if dir == -1 then
    return luasnip.in_snippet() and luasnip.jumpable(-1)
  else
    return luasnip.in_snippet() and seek_luasnip_cursor_node() and luasnip.jumpable(1)
  end
end

return M
