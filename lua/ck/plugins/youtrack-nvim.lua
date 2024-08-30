-- https://github.com/ruslan-korneev/youtrack.nvim
local M = {}

M.name = "ruslan-korneev/youtrack.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, false, {
    plugin = function()
      ---@type Plugin
      return {
        "ruslan-korneev/youtrack.nvim",
      }
    end,
    configure = function(_, fn)
      fn.setup_callback(require("ck.plugins.telescope").name, function(c)
        c.extensions.youtrack = {
          url = vim.env["YOUTRACK_URL"],
          token = vim.env["YOUTRACK_TOKEN"],
          query = "for: me #Unresolved ",
        }

        return c
      end)
    end,
    on_setup = function()
      require("telescope").load_extension("youtrack")
    end,
    wk = function(_, categories, fn)
      ---@type WKMappings
      return {
        {
          fn.wk_keystroke({ categories.FIND, "i" }),
          function()
            require("telescope").extensions.youtrack.youtrack({ insert_mode = true })
          end,
          desc = "Youtrack issues",
        },
      }
    end,
  })
end

return M
