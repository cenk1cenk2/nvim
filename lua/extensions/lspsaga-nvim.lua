-- https://github.com/nvimdev/lspsaga.nvim
local M = {}

M.name = "nvimdev/lspsaga.nvim"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "nvimdev/lspsaga.nvim",
        event = "LspAttach",
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
    on_done = function(_, fn)
      lvim.lsp.wrapper.code_action = function()
        vim.cmd("Lspsaga code_action")
        require("lspsaga.codeaction").pending_request = false
      end
      lvim.lsp.wrapper.hover = function()
        if is_extension_enabled(get_extension_name("extensions.nvim-ufo")) then
          local winid = require("ufo").peekFoldedLinesUnderCursor()
          if not winid then
            vim.cmd("Lspsaga hover_doc")
          end
        else
          vim.cmd("Lspsaga hover_doc")
        end
        require("lspsaga.hover").pending_request = false
      end
      lvim.lsp.wrapper.rename = function()
        vim.cmd("Lspsaga rename")
      end
      lvim.lsp.wrapper.diagnostics_goto_next = function(opts)
        opts = opts or {}

        require("lspsaga.diagnostic"):goto_next(opts)
      end
      lvim.lsp.wrapper.diagnostics_goto_prev = function(opts)
        opts = opts or {}

        require("lspsaga.diagnostic"):goto_prev(opts)
      end
      lvim.lsp.wrapper.show_line_diagnostics = function()
        vim.cmd("Lspsaga show_line_diagnostics")
      end
      lvim.lsp.wrapper.incoming_calls = function()
        vim.cmd("Lspsaga incoming_calls")
        require("lspsaga.callhierarchy").pending_request = false
      end
      lvim.lsp.wrapper.outgoing_calls = function()
        vim.cmd("Lspsaga outgoing_calls")
        require("lspsaga.callhierarchy").pending_request = false
      end
    end,
    setup = function()
      return {
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
          keys = {
            edit = "<CR>",
            vsplit = "v",
            split = "x",
            quit = "q",
            scroll_down = "<C-f>",
            scroll_up = "<C-b>", -- quit can be a table
          },
        },
        definition = {
          keys = {
            edit = "<C-c>o",
            vsplit = "<C-c>v",
            split = "<C-c>x",
            quit = "q",
          },
        },
        diagnostic = {
          -- maybe disable this later on
          -- https://www.reddit.com/r/neovim/comments/11o68vz/text_appearing_on_the_corner_of_the_screen/?utm_source=share&utm_medium=android_app&utm_name=androidcss&utm_term=2&utm_content=share_button
          on_insert = false,
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
          respect_root = true,
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
      }
    end,
    on_setup = function(c)
      require("lspsaga").setup(c)
    end,
    keymaps = function()
      return {
        {
          "ge",
          ":Lspsaga finder<CR>",
          desc = "finder",
          mode = { "n" },
        },
        {
          "gw",
          ":Lspsaga peek_definition<CR>",
          desc = "peek",
          mode = { "n" },
        },
      }
    end,
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
