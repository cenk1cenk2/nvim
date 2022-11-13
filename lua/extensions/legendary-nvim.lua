-- https://github.com/mrjones2014/legendary.nvim
local M = {}

local extension_name = "legendary_nvim"

function M.config()
  require("utils.setup").define_extension(extension_name, false, {
    packer = function(config)
      return {
        "mrjones2014/legendary.nvim",
        config = function()
          require("utils.setup").packer_config "legendary_nvim"
        end,
        disable = not config.active,
      }
    end,
    setup = function()
      return {
        -- Initial keymaps to bind
        keymaps = {},
        -- Initial commands to bind
        commands = {},
        -- Initial augroups/autocmds to bind
        autocmds = {},
        -- Initial functions to bidn
        functions = {},
        -- Customize the prompt that appears on your vim.ui.select() handler
        -- Can be a string or a function that returns a string.
        select_prompt = " legendary.nvim ",
        -- Character to use to separate columns in the UI
        col_separator_char = "│",
        -- Optionally pass a custom formatter function. This function
        -- receives the item as a parameter and the mode that legendary
        -- was triggered from (e.g. `function(item, mode): string[]`)
        -- and must return a table of non-nil string values for display.
        -- It must return the same number of values for each item to work correctly.
        -- The values will be used as column values when formatted.
        -- See function `default_format(item)` in
        -- `lua/legendary/ui/format.lua` to see default implementation.
        default_item_formatter = nil,
        -- Include builtins by default, set to false to disable
        include_builtin = false,
        -- Include the commands that legendary.nvim creates itself
        -- in the legend by default, set to false to disable
        include_legendary_cmds = false,
        -- Sort most recently used items to the top of the list
        -- so they can be quickly re-triggered when opening legendary again
        most_recent_items_at_top = true,
        which_key = {
          -- Automatically add which-key tables to legendary
          -- see ./doc/WHICH_KEY.md for more details
          auto_register = false,
          -- you can put which-key.nvim tables here,
          -- or alternatively have them auto-register,
          -- see ./doc/WHICH_KEY.md
          -- mappings = lvim.wk.mappings,
          -- opts = fn.fetch_current_config("wk").opts,
          -- controls whether legendary.nvim actually binds they keymaps,
          -- or if you want to let which-key.nvim handle the bindings.
          -- if not passed, true by default
          do_binding = false,
        },
        -- Directory used for caches
        cache_path = string.format("%s/legendary/", vim.fn.stdpath "cache"),
      }
    end,
    on_setup = function(config)
      require("legendary").setup(config.setup)
    end,
  })
end

return M
