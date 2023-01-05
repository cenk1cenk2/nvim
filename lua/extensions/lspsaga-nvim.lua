-- https://github.com/glepnir/lspsaga.nvim
local M = {}

local extension_name = "lspsaga_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "glepnir/lspsaga.nvim",
        event = "BufReadPost",
      }
    end,
    configure = function(_, fn)
      fn.add_disabled_filetypes({
        "lspsagaoutline",
        "lspsagarename",
      })
    end,
    inject_to_configure = function()
      return {
        lspsaga_diagnostic = require("lspsaga.diagnostic"),
      }
    end,
    setup = {
      -- Error,Warn,Info,Hint
      -- diagnostic_header = function(entry)
      --   print(vim.inspect(entry.source))
      --
      --   local icon = "ﴞ"
      --   if entry.severity == vim.diagnostic.severity.ERROR then
      --     icon = ""
      --   elseif entry.severity == vim.diagnostic.severity.WARN then
      --     icon = ""
      --   elseif entry.severity == vim.diagnostic.severity.INFO then
      --     icon = ""
      --   elseif entry.severity == vim.diagnostic.severity.HINT then
      --     icon = "ﴞ"
      --   end
      --
      --   return string.format("%s [ %s ]: ", icon, entry.source)
      -- end,
      -- use emoji lightbulb in default
      code_action_icon = lvim.ui.icons.ui.LightbulbColored,
      -- if true can press number to execute the codeaction in codeaction window
      code_action_num_shortcut = true,
      -- same as nvim-lightbulb but async
      code_action_lightbulb = {
        enable = false,
        enable_in_insert = false,
        cache_code_action = false,
        sign = true,
        update_time = 1000,
        sign_priority = 20,
        virtual_text = false,
      },
      -- preview lines of lsp_finder and definition preview
      max_preview_lines = 10,
      finder_action_keys = {
        open = "<CR>",
        vsplit = "s",
        split = "h",
        quit = "q",
        scroll_down = "<C-f>",
        scroll_up = "<C-b>", -- quit can be a table
      },
      code_action_keys = {
        quit = "<C-c>",
        exec = "<CR>",
      },
      -- show symbols in winbar must nightly
      symbol_in_winbar = {
        in_custom = false,
        enable = true,
        separator = (" %s "):format(lvim.ui.icons.ui.ChevronShortRight),
        show_file = true,
      },
      rename_action_quit = "<C-c>",
      rename_in_select = false,
      -- lvim.ui.border "double" "rounded" "bold" "plus"
      border_style = lvim.ui.border,
      --the range of 0 for fully opaque window (disabled) to 100 for fully
      --transparent background. Values between 0-30 are typically most useful.
      saga_winblend = 0,
      -- when cursor in saga window you config these to move
      move_in_saga = { prev = "<C-p>", next = "<C-n>" },
      -- if you don't use nvim-lspconfig you must pass your server name and
      -- the related filetypes into this table
      -- like server_filetype_map = {metals = {'sbt', 'scala'}}
      server_filetype_map = {},
      -- show outline
      show_outline = {
        win_position = "right",
        -- set the special filetype in there which in left like nvimtree neotree defx
        left_with = "",
        win_width = 40,
        auto_enter = true,
        auto_preview = true,
        virt_text = "┃",
        jump_key = "<CR>",
        -- auto refresh when change buffer
        auto_refresh = true,
      },
    },
    on_setup = function(config)
      require("lspsaga").init_lsp_saga(config.setup)
    end,
    on_done = function(config)
      local lspsaga_diagnostic = config.inject.lspsaga_diagnostic

      lvim.lsp_wrapper.code_action = function()
        vim.cmd("Lspsaga code_action")
      end
      lvim.lsp_wrapper.range_code_action = function()
        vim.cmd("Lspsaga code_action")
      end
      -- lvim.lsp_wrapper.hover = function()
      --   vim.cmd "Lspsaga hover_doc"
      -- end
      lvim.lsp_wrapper.rename = function()
        vim.cmd("Lspsaga rename")
      end
      lvim.lsp_wrapper.goto_next = function()
        lspsaga_diagnostic.goto_next()
      end
      lvim.lsp_wrapper.goto_prev = function()
        lspsaga_diagnostic.goto_prev()
      end
      -- lvim.lsp_wrapper.show_line_diagnostics = function()
      --   lspsaga_diagnostic.show_line_diagnostics()
      -- end
    end,
    keymaps = {
      n = {
        ["ge"] = { ":Lspsaga lsp_finder<CR>", { desc = "finder" } },
        ["gw"] = { ":Lspsaga peek_definition<CR>", { desc = "peek" } },
      },
    },
    -- wk = function(_, categories)
    --   return {
    --     [categories.LSP] = {
    --       ["o"] = { ":LSoutlineToggle<CR>", "file outline" },
    --     },
    --   }
    -- end,
  })
end

return M
