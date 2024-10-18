-- https://github.com/nvimdev/lspsaga.nvim
local M = {}

M.name = "nvimdev/lspsaga.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
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

      ---@diagnostic disable-next-line: duplicate-set-field
      nvim.lsp.fn.code_action = function()
        vim.cmd("Lspsaga code_action")
        require("lspsaga.codeaction").pending_request = false
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      nvim.lsp.fn.hover = function()
        if is_enabled(require("ck.plugins.nvim-ufo").name) then
          local winid = require("ufo").peekFoldedLinesUnderCursor()
          if not winid then
            vim.cmd("Lspsaga hover_doc")
          end
        else
          vim.cmd("Lspsaga hover_doc")
        end
        require("lspsaga.hover").pending_request = false
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      nvim.lsp.fn.rename = function()
        vim.cmd("Lspsaga rename")
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      nvim.lsp.fn.jump = function(opts)
        opts = opts or {}

        if opts.count == -1 then
          require("lspsaga.diagnostic"):goto_prev(opts)
        else
          require("lspsaga.diagnostic"):goto_next(opts)
        end
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      nvim.lsp.fn.show_line_diagnostics = function()
        vim.cmd("Lspsaga show_line_diagnostics")
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      nvim.lsp.fn.incoming_calls = function()
        vim.cmd("Lspsaga incoming_calls")
        require("lspsaga.callhierarchy").pending_request = false
      end

      ---@diagnostic disable-next-line: duplicate-set-field
      nvim.lsp.fn.outgoing_calls = function()
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
          separator = (" %s "):format(nvim.ui.icons.ui.ChevronShortRight),
          show_file = true,
          folder_level = 1,
          respect_root = true,
        },
        ui = {
          -- currently only round theme
          theme = "round",
          -- border type can be single,double,rounded,solid,shadow.
          border = nvim.ui.border,
          winblend = 0,
          expand = nvim.ui.icons.ui.ChevronShortLeft,
          collaspe = nvim.ui.icons.ui.ChevronShortDown,
          preview = nvim.ui.icons.ui.FindFile,
          code_action = "💡",
          diagnostic = nvim.ui.icons.ui.Bug,
          incoming = " ",
          outgoing = " ",
          colors = {
            --float window normal bakcground color
            normal_bg = nvim.ui.colors.bg[200],
            --title background color
            title_bg = nvim.ui.colors.yellow[300],
            red = nvim.ui.colors.red[600],
            magenta = nvim.ui.colors.magenta[600],
            orange = nvim.ui.colors.orange[600],
            yellow = nvim.ui.colors.yellow[600],
            green = nvim.ui.colors.green[600],
            cyan = nvim.ui.colors.cyan[600],
            blue = nvim.ui.colors.blue[600],
            purple = nvim.ui.colors.purple[600],
            white = nvim.ui.colors.white,
            black = nvim.ui.colors.black,
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
          "gW",
          ":Lspsaga peek_definition<CR>",
          desc = "peek",
          mode = { "n" },
        },
      }
    end,
    -- wk = function(_, categories)
    --  ---@type WKMappings
    --   return {
    --     [categories.LSP] = {
    --       ["o"] = { ":LSoutlineToggle<CR>", "file outline" },
    --     },
    --   }
    -- end,
  })
end

return M
