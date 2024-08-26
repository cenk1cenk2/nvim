-- https://github.com/miversen33/netman.nvim
local M = {}

M.name = "miversen33/netman.nvim"

function M.config()
  require("ck.setup").define_plugin(M.name, true, {
    plugin = function()
      ---@type Plugin
      return {
        "miversen33/netman.nvim",
        cmd = { "Neotree source=remote" },
      }
    end,
    configure = function(_, fn)
      fn.setup_callback(require("ck.plugins.neotree-nvim").name, function(c)
        table.insert(c.sources, "netman.ui.neo-tree")
        table.insert(c.source_selector.sources, { source = "netman.ui.neo-tree", display_name = (" %s Remote "):format(nvim.ui.icons.kind.Struct) })

        return c
      end)
    end,
    on_setup = function()
      require("netman").setup()
    end,
  })
end

return M
