-- https://github.com/stevearc/quicker.nvim
local M = {}

M.name = "stevearc/quicker.nvim"

function M.config()
  require("utils.setup").define_extension(M.name, true, {
    plugin = function()
      return {
        "stevearc/quicker.nvim",
        ft = { "qf" },
      }
    end,
    setup = function()
      return {
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
          return math.floor(math.min(80, vim.o.columns / 4))
        end,
      }
    end,
    on_setup = function(c)
      require("quicker").setup(c)
    end,
    keys = function()
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
          "<M-y>",
          function()
            require("quicker").toggle({ focus = true, loclist = true })
          end,
          desc = "quickfix [quicker]",
          mode = { "n", "v", "x" },
        },
      }
    end,
  })
end

return M
