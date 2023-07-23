-- https://github.com/SmiteshP/nvim-navbuddy
local M = {}

local extension_name = "nvim_navbuddy"

function M.config()
  require("utils.setup").define_extension(extension_name, true, {
    plugin = function()
      return {
        "SmiteshP/nvim-navbuddy",
        event = "LspAttach",
        dependencies = {
          "neovim/nvim-lspconfig",
          "SmiteshP/nvim-navic",
          "MunifTanjim/nui.nvim",
        },
      }
    end,
    setup = function()
      local actions = require("nvim-navbuddy.actions")

      return {
        window = {
          border = lvim.ui.border, -- "rounded", "double", "solid", "none"
          -- or an array with eight chars building up the border in a clockwise fashion
          -- starting with the top-left corner. eg: { "╔", "═" ,"╗", "║", "╝", "═", "╚", "║" }.
          size = "60%",
          position = "50%",
          scrolloff = nil, -- scrolloff value within navbuddy window
          sections = {
            left = {
              size = "20%",
              border = nil, -- You can set border style for each section individually as well.
            },
            mid = {
              size = "40%",
              border = nil,
            },
            right = {
              -- No size option for right most section. It fills to
              -- remaining area.
              border = nil,
            },
          },
        },
        icons = lvim.ui.icons.kind,
        mappings = {
          ["<esc>"] = actions.close(), -- Close and cursor to original location
          ["q"] = actions.close(),

          ["j"] = actions.next_sibling(), -- down
          ["k"] = actions.previous_sibling(), -- up

          ["h"] = actions.parent(), -- Move to left panel
          ["l"] = actions.children(), -- Move to right panel

          ["v"] = actions.visual_name(), -- Visual selection of name
          ["V"] = actions.visual_scope(), -- Visual selection of scope

          ["y"] = actions.yank_name(), -- Yank the name to system clipboard "+
          ["Y"] = actions.yank_scope(), -- Yank the scope to system clipboard "+

          ["i"] = actions.insert_name(), -- Insert at start of name
          ["I"] = actions.insert_scope(), -- Insert at start of scope

          ["a"] = actions.append_name(), -- Insert at end of name
          ["A"] = actions.append_scope(), -- Insert at end of scope

          ["r"] = actions.rename(), -- Rename currently focused symbol

          ["D"] = actions.delete(), -- Delete scope

          ["f"] = actions.fold_create(), -- Create fold of current scope
          ["F"] = actions.fold_delete(), -- Delete fold of current scope

          ["C"] = actions.comment(), -- Comment out current scope

          ["<enter>"] = actions.select(), -- Goto selected symbol
          ["o"] = actions.select(),

          ["J"] = actions.move_down(), -- Move focused node down
          ["K"] = actions.move_up(), -- Move focused node up
        },
        lsp = {
          auto_attach = true, -- If set to true, you don't need to manually use attach function
          preference = nil, -- list of lsp server names in order of preference
        },
        source_buffer = {
          follow_node = true, -- Keep the current node in focus on the source buffer
          highlight = true, -- Highlight the currently focused node
          reorient = "smart", -- "smart", "top", "mid" or "none"
          scrolloff = nil, -- scrolloff value when navbuddy is open
        },
      }
    end,
    on_setup = function(config)
      require("nvim-navbuddy").setup(config.setup)
    end,
    wk = function(_, categories)
      return {
        [categories.LSP] = {
          o = {
            function()
              require("nvim-navbuddy").open()
            end,
            "toggle outline",
          },
        },
      }
    end,
  })
end

return M
