-- https://github.com/stevearc/quicker.nvim
local M = {}

M.name = "stevearc/quicker.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "stevearc/quicker.nvim",
        ft = { "qf" },
      }
    end,
    setup = function()
      ---@type quicker.SetupOptions
      return {
        edit = {
          enabled = true,
        },
        type_icons = {
          E = nvim.ui.icons.diagnostics.Error,
          W = nvim.ui.icons.diagnostics.Warning,
          I = nvim.ui.icons.diagnostics.Information,
          N = nvim.ui.icons.diagnostics.Dot,
          H = nvim.ui.icons.diagnostics.Hint,
        },
        keys = {
          {
            ">",
            function()
              require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
            end,
            desc = "Expand quickfix context",
          },
          {
            "<",
            function()
              require("quicker").collapse()
            end,
            desc = "Collapse quickfix context",
          },
          {
            "R",
            function()
              require("quicker").refresh()
            end,
            desc = "Refresh quickfix context",
          },
        },
        max_filename_width = function()
          return math.floor(math.min(40, vim.o.columns / 8))
        end,
      }
    end,
    on_setup = function(c)
      require("quicker").setup(c)
    end,
    keymaps = function()
      ---@type KeymapMappings
      return {
        {
          "<C-y>",
          function()
            require("quicker").toggle({ focus = true })
          end,
          desc = "quickfix [quicker]",
          mode = { "n", "v", "x" },
        },

        {
          "<C-S-Y>",
          function()
            require("quicker").toggle({ focus = true, loclist = true })
          end,
          desc = "location list [quicker]",
          mode = { "n", "v", "x" },
        },
      }
    end,
  })
end

return M
