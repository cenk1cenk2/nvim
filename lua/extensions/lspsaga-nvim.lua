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
        "lspsagafinder",
        "lspsagarename",
        "sagarename",
        "sagaoutline",
        "sagafinder",
      })
    end,
    setup = {
      lightbulb = {
        enable = false,
        enable_in_insert = false,
        sign = true,
        update_time = 1000,
        virtual_text = false,
      },
      code_action = {
        num_shortcut = true,
        show_server_name = true,
        extend_gitsigns = false,
        keys = {
          -- string | table type
          quit = "q",
          exec = "<CR>",
        },
      },
      finder = {
        open = "<CR>",
        vsplit = "s",
        split = "h",
        quit = "q",
        scroll_down = "<C-f>",
        scroll_up = "<C-b>", -- quit can be a table
      },
      diagnostic = {
        -- maybe disable this later on
        -- https://www.reddit.com/r/neovim/comments/11o68vz/text_appearing_on_the_corner_of_the_screen/?utm_source=share&utm_medium=android_app&utm_name=androidcss&utm_term=2&utm_content=share_button
        on_insert = true,
        on_insert_follow = true,
        insert_winblend = 0,
        twice_into = true,
        show_code_action = false,
        show_source = true,
        keys = {
          exec_action = "o",
          quit = "q",
        },
      },
      rename = {
        quit = "<C-c>",
        exec = "<CR>",
        in_select = false,
      },
      -- show symbols in winbar must nightly
      symbol_in_winbar = {
        in_custom = false,
        enable = true,
        separator = (" %s "):format(lvim.ui.icons.ui.ChevronShortRight),
        show_file = true,
        folder_level = 1,
      },
      ui = {
        -- currently only round theme
        theme = "round",
        -- border type can be single,double,rounded,solid,shadow.
        border = lvim.ui.border,
        winblend = 0,
        expand = lvim.ui.icons.ui.ChevronShortLeft,
        collaspe = lvim.ui.icons.ui.ChevronShortDown,
        preview = lvim.ui.icons.ui.FindFile,
        code_action = "💡",
        diagnostic = lvim.ui.icons.ui.Bug,
        incoming = " ",
        outgoing = " ",
        colors = {
          --float window normal bakcground color
          normal_bg = lvim.ui.colors.bg[200],
          --title background color
          title_bg = lvim.ui.colors.yellow[300],
          red = lvim.ui.colors.red[600],
          magenta = lvim.ui.colors.magenta[600],
          orange = lvim.ui.colors.orange[600],
          yellow = lvim.ui.colors.yellow[600],
          green = lvim.ui.colors.green[600],
          cyan = lvim.ui.colors.cyan[600],
          blue = lvim.ui.colors.blue[600],
          purple = lvim.ui.colors.purple[600],
          white = lvim.ui.colors.white,
          black = lvim.ui.colors.black,
        },
        kind = {},
      },
    },
    on_setup = function(config)
      require("lspsaga").setup(config.setup)
    end,
    on_done = function(_, fn)
      lvim.lsp.wrapper.code_action = function()
        vim.cmd("Lspsaga code_action")
      end
      lvim.lsp.wrapper.hover = function()
        if fn.is_extension_enabled("nvim_ufo") then
          local winid = require("ufo").peekFoldedLinesUnderCursor()
          if not winid then
            vim.cmd("Lspsaga hover_doc")
          end
        else
          vim.cmd("Lspsaga hover_doc")
        end
      end
      lvim.lsp.wrapper.rename = function()
        vim.cmd("Lspsaga rename")
      end
      lvim.lsp.wrapper.goto_next = function()
        vim.cmd("Lspsaga diagnostic_jump_next")
        -- require("lspsaga.diagnostic").goto_next({ severity = vim.diagnostic.severity.ERROR })
      end
      lvim.lsp.wrapper.goto_prev = function()
        vim.cmd("Lspsaga diagnostic_jump_prev")
        -- require("lspsaga.diagnostic").goto_prev({ severity = vim.diagnostic.severity.ERROR })
      end
      lvim.lsp.wrapper.show_line_diagnostics = function()
        vim.cmd("Lspsaga show_line_diagnostics")
      end
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
